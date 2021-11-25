bison -d -v parser1.y
flex lexer1.lex
g++ -g -std=c++11 lex.yy.c parser1.tab.c parser1.tab.h -o main -lfl