%{
#include <stdlib.h>
#include "typesStructs.h"
#include "y.tab.h"
//int yylineno;
void yyerror(char *);
%}

%%

[a-z]       {
                yylval.sIndex = *yytext - 'a';
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

">="            return GE;
"<="            return LE;
"=="            return EQ;
"!="            return NE;
"while"         return WHILE;
"if"            return IF;
"else"          return ELSE;
"print"         return PRINT;

"int"           return INT_TYPE;
"float"         return FLOAT_TYPE;
"string"	return STRING_TYPE;
"bool" 		return BOOL_TYPE;

[ \t]+ 	;			/* ignore whitespace */
[\n]			{++yylineno;}
.               yyerror("Unknown character");
%%
int yywrap(void) {
    return 1;
}
