compiled: lex.yy.c y.tab.c
	g++ y.tab.c lex.yy.c -o compiler.out  --std=c++14

lex.yy.c: y.tab.c pattern.l
	lex pattern.l

y.tab.c: gram.y
	yacc -d -v -t gram.y

clean: 
	rm -rf lex.yy.c y.tab.c y.tab.h y.output
