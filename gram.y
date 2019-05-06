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
varData *findVar(string varName, bool searchParent);
void setExprConType(nodeType * p);
void getNodeContype(conType *firstType,conType *secondType,nodeType *first, nodeType *second);
void compareType(int oper,nodeType *first, nodeType *second);
void handleAssignment(nodeType *p);
void handleDiv(nodeType *p);
void freeNode(nodeType *p);
//int ex(nodeType *p);
int yylex(void);

char temp[]= "c";
varData v;
FILE * stderr;  // for logging errors
void yyerror(std::string s);
vector<map<string,varData>> sym;

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

%left '|'
%left '&'
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
        | declaration ';'              { $$ = $1; }
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
			 
			 INT_TYPE VARIABLE  { $$ = id($2,typeInt);}
			| FLOAT_TYPE VARIABLE { $$ = id($2,typeFloat);}
			| STRING_TYPE VARIABLE { $$ = id($2,typeString);}
			| BOOL_TYPE VARIABLE  { $$ = id($2,typeBool);}
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
        | expr '&' expr         { $$ = opr('&', 2, $1, $3); }
        | expr '|' expr         { $$ = opr('|', 2, $1, $3); }
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
    
    string ss(s);
    
    varData* existVar = findVar(ss,vType >= 4);
    
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
        varData var;
		var.used = false;
		var.initialized = false;
        var.varType = vType;
        var.varName = s;
        var.null = false;
		sym[sym.size()-1].insert(std::pair<string,varData>(ss,var));

    }
    //fprintf(stdout, "after set %d: %s\n", yylineno, sym[sym.size()-1][s].varName);
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
    else if(p->opr.oper == '<' || p->opr.oper == '>' || p->opr.oper == GE
            || p->opr.oper == LE ||  p->opr.oper == NE ||  p->opr.oper == EQ )
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


    if(p->opr.oper == '=') {
        handleAssignment(p);
    }

//    if(p->opr.oper == '/'){
//       handleDiv(p);
//    }

    if(nops >1) {
        compareType(oper, p->opr.op[0], p->opr.op[1]);
    }
    if(nops ==1) {
        compareType(oper, p->opr.op[0], NULL);
    }

    setExprConType(p);
//    printf("operation %c with type %d\n",oper,p->opr.operType);

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

varData* findVar(string varName, bool searchParent){

    //printf("find var1\n");
    int depth = searchParent ? 0 : sym.size() -1;
    for(int i=sym.size() -1; i >= 0; i--){  /*first search in the same scope*/
    int size=sym[i].size();
    //fprintf(stdout, "in for loop %d: %s\n",size , varName.c_str());
        if(sym[i].find(varName) != sym[i].end()) 
                {
					//printf("find var\n");
					return &sym[i][varName];
                }
    }
    return &v; /*search in parent scope*/

}

void getNodeContype(conType *firstType,conType *secondType,nodeType *first, nodeType *second){

    switch (first->type) {
        case typeCon: {
            *firstType = first->con.conT;
            break;
        }
        case typeId: {
            string ss(first->id.keyName);
            *firstType = findVar(ss, true)->varType;
            break;
        }
        default: /*case typeOpr*/{
            *firstType = first->opr.operType;
            break;
        }
    }

    if(second != NULL) {
        switch (second->type) {
            case typeCon: {
                *secondType = second->con.conT;
                break;
            }
            case typeId: {
                string ss(second->id.keyName);
                *secondType = findVar(ss, true)->varType;
                break;
            }
            default: {/*case typeOpr*/
                *secondType = second->opr.operType;
                break;
            }
        }
    }
}

/**
 * Compares the types of two nodes taking into consideration the operation
 * @param oper operation performed on the nodes
 * @param first one of the operands
 * @param second the other operand
 */

void compareType(int oper,nodeType *first, nodeType *second){

    conType firstType;
    conType secondType;

    getNodeContype(&firstType,&secondType,first,NULL);

    if(oper == WHILE){

        if(firstType != typeBool){
            yyerror("While argument must be of type Boolean");
        }
    }

    if(oper == IF){

        if(firstType != typeBool){
            yyerror("if argument must be of type Boolean");
        }
    }

    conType caseArgumentType;

//
//    if(oper == SWITCH){
//
//        if(first->type == typeCon){
//            yyerror("switch argument cannot constant");
//        }
//
//        else {
//
//
//            while (second->opr.nops == 3) /*case then case*/{
//                getNodeContype(&caseArgumentType,secondType,second->opr.op[0],NULL);
//                second = second->opr.op[2];
//                if(firstType != caseArgumentType){
//                    yyerror(" switch argument and case argument mismatch");
//                }
//
//            }
//
//            /*last case*/
//
//            getNodeContype(&caseArgumentType,secondType,second->opr.op[0],NULL);
//            if(firstType != caseArgumentType){
//                yyerror(" switch argument and case argument mismatch");
//            }
//
//        }
//
//    }

    if(oper == UMINUS){
        if(firstType == typeString){
            yyerror("Negation can't be applied on Strings");
        }

        if(firstType == typeBool){
            yyerror("Negation can't be applied on Boolean expressions");
        }

    }

    getNodeContype(&firstType,&secondType,first,second);

    if(oper == '+' || oper == '-' || oper == '*' || oper == '/'){

        if(firstType == typeString || secondType == typeString){

            yyerror("Can't apply mathematical operations on Strings.");
        }

        if(firstType == typeBool || secondType == typeBool){
            yyerror("Can't apply mathematical operations on Boolean expressions.");
        }

    }
    if( oper == '<' || oper == '>' || oper == GE || oper == LE  ){

        if(firstType == typeString || firstType == typeBool || secondType == typeString || secondType == typeBool )
            yyerror(" Can't perform this comparison operation on a String or Boolean.");
    }

    if(oper == '&' || oper == '|'){

        if(firstType != typeBool || secondType != typeBool)
            yyerror("Can't perform & operation or | operation on non Boolean.");
    }

    if(oper == EQ || oper == NE){
        if(firstType == typeString && secondType != typeString)
            yyerror("Can't compare a String with a non String.");
        if(firstType == typeBool && secondType != typeBool){
            yyerror("Can't compare Boolean expression with non Boolean one.");

        }
    }

    if(oper == '='){

        if(firstType != secondType){
            yyerror("Can't cast from one type to another");
        }
    }


}


void setExprConType(nodeType * p){


    conType firstType;
    conType secondType;

    if(p->opr.oper == UMINUS) {

        getNodeContype(&firstType,&secondType,p->opr.op[0],NULL);
        p->opr.operType = firstType;
        return;

    }

    getNodeContype(&firstType,&secondType,(nodeType*)p->opr.op[0],(nodeType*)p->opr.op[1]);


    if(p->opr.oper == '+' || p->opr.oper == '-' || p->opr.oper == '*') {
        if (firstType == typeFloat || secondType == typeFloat) {
            p->opr.operType = typeFloat;
        }
        else p->opr.operType = typeInt;
        }

    else if( p->opr.oper == '/') p->opr.operType = typeFloat;

    else if( p->opr.oper == '<' || p->opr.oper == '>' || p->opr.oper == GE || p->opr.oper == LE ||
            p->opr.oper == EQ || p->opr.oper == NE || p->opr.oper == '&' || p->opr.oper == '|')
    {
        p->opr.operType = typeBool;
    }


    return;
}

void handleAssignment(nodeType *p){

    //check constants
    nodeTypeTag *pid = p->opr.op[0];
    char* s = p->opr.op[0]->id.keyName;
    if(s!=NULL){  /*why??*/
        string ss(s);
        varData *lvalue = findVar(ss,true);
        lvalue->initialized = true;
    }

}
void handleDiv(nodeType *p){
    if(p->opr.op[1]->type == typeCon){
        if(p->opr.op[1]->con.conT == typeInt && p->opr.op[1]->con.valueInt == 0
        || p->opr.op[1]->con.conT == typeFloat && p->opr.op[1]->con.valueFloat == 0.0){
            yyerror("Division by zero!");
        }
    }
}


int main(void) {
    v.null = true;
	sym.push_back(map<string,varData>());
    extern FILE * yyin;
    yyin = fopen("myProgram.txt", "r"); // The input file for lex, the default is stdin
    yyparse();
    fclose(yyin);
    return 0;

}
