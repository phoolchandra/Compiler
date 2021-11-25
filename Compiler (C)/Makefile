all:
	bison -d -v parser1.y
	flex lexer1.lex
	g++ -g -std=c++11 lex.yy.c parser1.tab.c parser1.tab.h -o main1 -lfl
	./main1 < test.c
	bison -d -v -t parser2.y
	flex lexer2.lex
	g++ lex.yy.c parser2.tab.c parser2.tab.h -o main2 -lfl
	./main2 < intermediate.txt