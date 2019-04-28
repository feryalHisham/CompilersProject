# CompilersProject
Compilers and Languages Group Project

First, you need to install lex and yacc.
For Ubuntu: sudo apt install bison flex

To run:

yacc -d gram.y

lex pattern.l

cc lex.yy.c y.tab.c compiler.c -o compiler.out

./cmpiler.out

The source code is provided in myProgram.txt
