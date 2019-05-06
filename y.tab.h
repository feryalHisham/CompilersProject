/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    INTEGER = 258,
    INT_TYPE = 259,
    FLOAT_TYPE = 260,
    STRING_TYPE = 261,
    BOOL_TYPE = 262,
    STRING = 263,
    FLOAT = 264,
    BOOL = 265,
    VARIABLE = 266,
    WHILE = 267,
    IF = 268,
    PRINT = 269,
    CONST = 270,
    DO = 271,
    FOR = 272,
    IFX = 273,
    ELSE = 274,
    GE = 275,
    LE = 276,
    EQ = 277,
    NE = 278,
    UMINUS = 279
  };
#endif
/* Tokens.  */
#define INTEGER 258
#define INT_TYPE 259
#define FLOAT_TYPE 260
#define STRING_TYPE 261
#define BOOL_TYPE 262
#define STRING 263
#define FLOAT 264
#define BOOL 265
#define VARIABLE 266
#define WHILE 267
#define IF 268
#define PRINT 269
#define CONST 270
#define DO 271
#define FOR 272
#define IFX 273
#define ELSE 274
#define GE 275
#define LE 276
#define EQ 277
#define NE 278
#define UMINUS 279

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 36 "gram.y" /* yacc.c:1909  */

    int iValue;                 /* integer value */
    char sIndex;                /* symbol table index */
    char* sValue;               /* string value */
    float fValue;               /* float value */
    bool bValue;
    nodeType *nPtr;             /* node pointer */

#line 111 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
