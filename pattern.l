%{

#include <stdlib.h>
#include "typesStructs.h"
#include <string>
#include "y.tab.h"
//int yylineno;
void yyerror(std::string);
void checkForUnusedVariables();
void yyerrorUnused(std::string,int lineNo);
using namespace std;
%}

%%

">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;
"while"         return WHILE;
"do"			return DO;
"for"			return FOR;
"if"            return IF;
"else"          return ELSE;
"print"         return PRINT;
"const" 		return CONST;

"int"           { yylval.iValue=0;
		return INT_TYPE;
                }
"float"         {
		 yylval.iValue=1;
		return FLOAT_TYPE;
		}
"string"	{
		 yylval.iValue=2;
		return STRING_TYPE;
		}
"bool" 		{
		 yylval.iValue=3;
		return BOOL_TYPE;
		}

[a-z]+       {
                yylval.sValue = strdup(yytext);
                return VARIABLE;
            }

0           {
                yylval.iValue = atoi(yytext);
                return INTEGER;
            }

[1-9][0-9]* {
                yylval.iValue = atoi(yytext);
                return INTEGER;
            }
[0-9]+(\.)[0-9]+ {

		yylval.fValue= atof(yytext);
		return FLOAT;
		}
"True" {

		yylval.bValue= true;
		return BOOL;
		}
"False" {
		yylval.bValue= false;
		return BOOL;
		}

[-()<>=+*/;.] {
                //fprintf(stdout, "pattern %s\n", yytext);
                return *yytext;
             }
[{]             {
		sym.push_back(map<string,varData>());
		//int size = sym[sym.size()-1].size();
                //fprintf(stdout, "pattern %s %d\n", yytext,size);
                return *yytext;
		}
[}]		{
		//int size = sym[sym.size()-1].size();
                //fprintf(stdout, "pattern %s %d\n", yytext,size);
                checkForUnusedVariables();
		sym.pop_back();
                return *yytext;
		}
\"[^"\n]*["\n] {
		yylval.sValue = strdup(yytext);
		return STRING;
		}



[ \t]+ 	;			/* ignore whitespace */
[\n]			{++yylineno;}
.               yyerror("Unknown character");
%%
int yywrap(void) {
    return 1;
}


