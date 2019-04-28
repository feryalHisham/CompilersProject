%{
#include <stdlib.h>
#include "typesStructs.h"
#include "y.tab.h"
int yylineno;
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

[-()<>=+*/;{}.] {
                return *yytext;
             }
\"[^"\n]*["\n] {
             								yylval.sValue = strdup(yytext+1);
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

[ \t]+ 	;			/* ignore whitespace */
[\n]			{++yylineno;}
.               yyerror("Unknown character");
%%
int yywrap(void) {
    return 1;
}
