%{

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
//#include "typesStructs.h"
#include "compiler.h"
#include <string.h>
#include <string>
#include <vector>

/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(char *s,conType vType);
nodeType *con(int valI,float valF,char* valS,bool valB, conType conT);
varData *findVar(char* varName, int scopeIndex);
void freeNode(nodeType *p);
//int ex(nodeType *p);
int yylex(void);

char temp[]= "c";
//FILE * yyin; // input file for lex
FILE * stderr;  // for logging errors
void yyerror(std::string s);
varData sym[MAX_SCOPES][MAX_VARS];                    /* symbol table */
int scopesParent[MAX_SCOPES];
int scopeLevel;
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
        | VARIABLE '=' expr ';'          { $$ = opr('=', 2, id($1,VAR_AS_LVALUE), $3); }
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
			 INT_TYPE VARIABLE     { $$ = id($2,typeInt);}
			| INT_TYPE VARIABLE ';' { $$ = id($2,typeInt);}
			| FLOAT_TYPE VARIABLE { $$ = id($2,typeFloat);}
			| FLOAT_TYPE VARIABLE ';' { $$ = id($2,typeFloat);}
			| STRING_TYPE VARIABLE { $$ = id($2,typeString);}
			| STRING_TYPE VARIABLE ';' { $$ = id($2,typeString);}
			| BOOL_TYPE VARIABLE  { $$ = id($2,typeBool);}
			| BOOL_TYPE VARIABLE ';' { $$ = id($2,typeBool);}
	          ;     

expr:
          INTEGER               { $$ = con($1, 0.0, temp, true, typeInt); }
		| FLOAT 				{ $$ = con(0, $1,temp, true, typeFloat); }
		| STRING				{ $$ = con(0, 0.0, $1, true, typeString); }
		| BOOL					{ $$ = con(0, 0.0, temp, $1, typeBool); }
        | VARIABLE              { $$ = id($1,VAR_AS_EXPR); }
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

    //printf("con\n");

    /* allocate node */
    //if ((p = malloc(sizeof(nodeType))) == NULL)
      //  yyerror("out of memory");
    p = new nodeType;
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

nodeType *id(char *s,conType vType) {
    nodeType *p;

    //printf("id\n");
    /* allocate node */
    //if ((p = malloc(sizeof(nodeType))) == NULL)
      //  yyerror("out of memory");
    p = new nodeType;
    //scopesParent[scopeLevel] = scopeLevel-1;

    varData *existVar = findVar(s,scopeLevel);
    if(existVar != NULL && vType >=0) {  //&& existVar->scopeIndex == scopeLevel
        yyerror("Variable declared before.");
    }
    if(existVar == NULL && vType <0 ){
        yyerror("Variable is not declared.");
    }

    /* copy information */
    p->type = typeId;
    p->id.keyName = s;
    p->id.scopeIndex = scopeLevel;
    p->id.varIndex = sym[scopeLevel][0].valueInt+1;
    p->exType = typeOther;
    //printf("after findVar\n");


    if(existVar == NULL && vType >=0 ){
        varData var;
        var.varType=vType;
        var.varName=s;
        var.scopeIndex = scopeLevel;
        sym[p->id.scopeIndex][p->id.varIndex] = var;
        sym[scopeLevel][0].valueInt++;
    }


    return p;
}

nodeType *opr(int oper, int nops, ...) {
    //printf("opr\n");
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    //if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
      //  yyerror("out of memory");
    p = new nodeType;
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
		yyerror("Can't include non Mathematical expression.");
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

void yyerror(std::string s) {
    //fprintf(stdout, "%s\n", s);
    //fprintf(stdout, "line %d: %s\n", yylineno, s);
    exit(0);
}

varData *findVar(char* varName, int scopeIndex){

    //printf("var name %s scope %d vars %d\n",varName,scopeIndex,sym[scopeIndex][0].valueInt);
    if(scopeIndex == 0)
        return NULL;

    for(int i=1;i<=sym[scopeIndex][0].valueInt;i++){  /*first search in the same scope*/
        if(strcmp(sym[scopeIndex][i].varName ,varName) == 0)
            return &sym[scopeIndex][i];
    }

    return findVar(varName,scopesParent[scopeIndex]); /*search in parent scope*/

}

int main(void) {
    scopeLevel=1;
    extern FILE * yyin;
    yyin = fopen("myProgram.txt", "r"); // The input file for lex, the default is stdin
    yyparse();
    fclose(yyin);
    return 0;

}
