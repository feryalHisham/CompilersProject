%{

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
//#include "typesStructs.h"
#include "compiler.h"
#include <string.h>
#include <string>

using namespace std;


/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(char *s,conType vType);
nodeType *con(int valI,float valF,char* valS,bool valB, conType conT);
varData *findVar(char* varName, bool searchParent);
void freeNode(nodeType *p);
//int ex(nodeType *p);
int yylex(void);

char temp[]= "c";
varData v;
FILE * stderr;  // for logging errors
void yyerror(std::string s);
vector<map<char*,varData>> sym;

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


    /* allocate node */
    if ((p = (nodeType *)malloc(sizeof(nodeType))) == NULL)
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

nodeType *id(char *s,conType vType) {
    nodeType *p;

    /* allocate node */
    if ((p = (nodeType *)malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");

	
    varData* existVar = findVar(s,vType >= 4);
    
    if(existVar->null != true && vType < 4) { 
        yyerror("Variable declared before.");
    }
	// x = y;
    if(existVar->null && vType >= 4 ){
        yyerror("Variable is not declared.");
    }
	// = y
    else if(vType == VAR_AS_EXPR)
    {
		if(existVar->initialized == false)
			yyerror("Variable is not initialized.");
		else
			existVar->used = true; // Check this.
    }

    /* copy information */
    p->type = typeId;
    p->id.keyName = s;
    p->exType = typeOther;


    if(existVar->null && vType < 4 ){
        printf("set varDAta1\n");
        varData var;
		var.used = false;
		var.initialized = false;
        var.varType = vType;
        var.varName = s;
        var.null = false;
		sym[sym.size()-1].insert(std::pair<char*,varData>(s,var));
        fprintf(stdout, "after set %d: %s\n", yylineno, sym[sym.size()-1][s].varName);
	    printf("set varDAta2\n");
    }
            fprintf(stdout, "after set %d: %s\n", yylineno, sym[sym.size()-1][s].varName);
    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;

    /* allocate node, extending op array */
    if ((p = (nodeType *)malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
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
		yyerror("Can't include non Mathematical expression.");
	}

    va_end(ap);
    //printf("opr\n");
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
    fprintf(stdout, "line %d: %s\n", yylineno, s.c_str());
    exit(0);
}

varData* findVar(char* varName, bool searchParent){

    printf("find var1\n");
    int depth = searchParent ? 0 : sym.size() -1;
    fprintf(stdout, "line %d: %s\n", yylineno, varName);
    for(int i=sym.size() -1; i >= 0; i--){  /*first search in the same scope*/
    fprintf(stdout, "in for loop %d: %s\n", i, sym[i][varName].varName);
        if(sym[i].find(varName) != sym[i].end()) 
                {
					printf("find var\n");
					return &sym[i][varName];
                }
    }
    printf("find var2\n");
    return &v; /*search in parent scope*/

}

int main(void) {
    v.null = true;
	sym.push_back(map<char*,varData>());
    extern FILE * yyin;
    yyin = fopen("myProgram.txt", "r"); // The input file for lex, the default is stdin
    yyparse();
    fclose(yyin);
    return 0;

}
