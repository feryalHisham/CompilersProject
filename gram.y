%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "typesStructs.h"



/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(char *s,int vType);
nodeType *con(int valI,float valF,char* valS,bool valB, conType conT);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);


FILE * yyin; // input file for lex
FILE * stderr;  // for logging errors
void yyerror(char *s);
varData sym[100][50];                    /* symbol table */
int noOfScopes;
%}

%union {
    int iValue;                 /* integer value */
    char sIndex;                /* symbol table index */
    char* sValue;               /* string value */
    float fValue;               /* float value */
    bool bValue;
    nodeType *nPtr;             /* node pointer */
};

%token <iValue> INTEGER INT_TYPE FLOAT_TYPE STRING_TYPE BOOL_TYPE
%token <sValue> STRING
%token <fValue> FLOAT
%token <bValue> BOOL
%token <sValue> VARIABLE
%token WHILE IF PRINT 
%nonassoc IFX
%nonassoc ELSE



%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> stmt declaration expr stmt_list

%%

program:
        function                { exit(0); }
        ;

function:
          function stmt         { ex($2); freeNode($2); }
        | /* NULL */
        ;

stmt:	PRINT expr ';'                 { $$ = opr(PRINT, 1, $2); }
        | declaration                  { $$ = $1; }
	| declaration '=' expr ';'       {$$ = opr('=', 2, $1, $3);}
        | VARIABLE '=' expr ';'          { $$ = opr('=', 2, id($1,1), $3); }
        | WHILE '(' expr ')' stmt        { $$ = opr(WHILE, 2, $3, $5); }
        | IF '(' expr ')' stmt %prec IFX { $$ = opr(IF, 2, $3, $5); }
        | IF '(' expr ')' stmt ELSE stmt { $$ = opr(IF, 3, $3, $5, $7); }
        | '{' stmt_list '}'              { $$ = $2; }
        ;

stmt_list:
          stmt                  { $$ = $1; }
        | stmt_list stmt        { $$ = opr(';', 2, $1, $2); }
        ;

declaration:  
			 INT_TYPE VARIABLE     { $$ = id($2,$1);}
			| INT_TYPE VARIABLE ';' { $$ = id($2,$1);}
			| FLOAT_TYPE VARIABLE { $$ = id($2,$1);}
			| FLOAT_TYPE VARIABLE ';' { $$ = id($2,$1);}
			| STRING_TYPE VARIABLE { $$ = id($2,$1);}
			| STRING_TYPE VARIABLE ';' { $$ = id($2,$1);}
			| BOOL_TYPE VARIABLE { $$ = id($2,$1);}
			| BOOL_TYPE VARIABLE ';' { $$ = id($2,$1);}
	          ;     

expr:
          INTEGER               { $$ = con($1, 0.0, "", true, typeInt); }
		| FLOAT 				{ $$ = con(0, $1, "", true, typeFloat); }
		| STRING				{ $$ = con(0, 0.0, $1, true, typeString); }
		| BOOL					{ $$ = con(0, 0.0, "", $1, typeBool); }
        | VARIABLE              { $$ = id($1,1); }
        | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
        | expr '+' expr         { $$ = opr('+', 2, $1, $3); }
        | expr '-' expr         { $$ = opr('-', 2, $1, $3); }
        | expr '*' expr         { $$ = opr('*', 2, $1, $3); }
        | expr '/' expr         { $$ = opr('/', 2, $1, $3); }
        | expr '<' expr         { $$ = opr('<', 2, $1, $3); }
        | expr '>' expr         { $$ = opr('>', 2, $1, $3); }
        | expr GE expr          { $$ = opr(GE, 2, $1, $3); }
        | expr LE expr          { $$ = opr(LE, 2, $1, $3); }
        | expr NE expr          { $$ = opr(NE, 2, $1, $3); }
        | expr EQ expr          { $$ = opr(EQ, 2, $1, $3); }
        | '(' expr ')'          { $$ = $2; }
        ;

%%

nodeType *con(int valI,float valF,char* valS,bool valB, conType conT) {
     nodeType *p;
    
    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->exType = typeOther;
    p->con.conT=conT;	
  
    switch(conT){
		case typeInt:
			p->con.valueInt = valI;
		break;
		case typeFloat:
			p->con.valueFloat = valF;
		break;
		case typeString:
			p->con.valueString = valS;
		break;
		default:
			p->con.valueBool = valB;
    }

    return p;
}

nodeType *id(char *s,int vType) {
    nodeType *p;


    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    
    /* copy information */
    p->type = typeId;
    p->id.keyName = s;
    p->id.scopeIndex = noOfScopes;
    p->id.varIndex = ++sym[noOfScopes][0].valueInt;
    p->exType = typeOther;
    
    varData var;
    var.varType=vType;
    var.varName=s;
    sym[p->id.scopeIndex][p->id.varIndex] = var;
    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;

    if(p->opr.oper == '+' || p->opr.oper == '-' || p->opr.oper == '*' || p->opr.oper == '/' )
    	p->exType = typeMath;
    else if(p->opr.oper == '<' || p->opr.oper == '>' || p->opr.oper == GE || p->opr.oper == LE ||  p->opr.oper == NE ||  p->opr.oper == EQ )
	p->exType = typeLog;
    else
	p->exType = typeOther;

    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);

    if(p->exType == typeMath)
	{
    	for (i = 0; i < nops; i++)
	   if(p->opr.op[i]->exType == typeLog)
		yyerror("Can't include non Mathmatical expression.");
	}

    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

void yyerror(char *s) {
    //fprintf(stdout, "%s\n", s);
    fprintf(stdout, "line %d: %s\n", yylineno, s);
    exit(0);
}


int main(void) {
    noOfScopes=1;
    yyin = fopen("myProgram.txt", "r"); // The input file for lex, the default is stdin
    yyparse();
    fclose(yyin);
    return 0;

}
