%{
#include <stdlib.h>
#include "typesStructs.h"
#include "y.tab.h"
//int yylineno;
void yyerror(char *);
%}

%%

">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;
"while"         return WHILE;
"if"            return IF;
"else"          return ELSE;
"print"         return PRINT;

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

[-()<>=+*/;{}.] {
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
