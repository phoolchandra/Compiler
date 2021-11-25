%{
	#include <bits/stdc++.h>
	#include "parser1.tab.h"
	using namespace std;
%}

%option yylineno
%option noyywrap
%s HASH

lineComment     "//".*
blockComment    "/*"((("*"[^/])?)|[^*])*"*/"
SEMI	";"
EQUAL	"="
ADD		"+"
SUB		"-"
MUL		"*"
DIV		"/"
GT		">"
LT		"<"
GE		">="
LE		"<="
EQ		"=="
NE 		("!=")
OR 		"||"
AND 	"&&"
LC		"{"
RC		"}"
LB		"("
RB		")"
LBP		"["
RBP		"]"
COMMA 	","
MAIN	"main"
INT		"int"
VOID	"void"
FLOAT 	"float"
RETURN 	"return"
IF 		"if"
FOR		"for"
WHILE	"while"
ELSE	"else"
BREAK   "break"
PRINT 	"printf"
READ	"scanf"
CONTINUE 	"continue"
SWITCH		"switch"
CASE 		"case"
DEFAULT 	"default"
COLON 		":"
INTEGERS 						([0-9]+)
FLOATING_POINTS					([0-9]+\.[0-9]+)
LIBRARY 						(\#include[ \n\t]*\<.+\>)|((\#include[ \t\n]*\".+\"))
ID								([A-Za-z_]([A-Za-z0-9_])*)
WHITE_SPACES 					([ \t]+)
NEW_LINE 						([\n])
STRING							\"(\\.|[^\"])*\"

%%
{lineComment}   {}
{blockComment}  {}
{SEMI}			{return SEMI;}
{EQUAL}			{return EQUAL;}
{ADD} 			{return ADD;}
{SUB} 			{return SUB;}
{MUL} 			{return MUL;}
{DIV} 			{return DIV;}
{GT} 			{return GT;}
{LT} 			{return LT;}
{GE} 			{return GE;}
{LE} 			{return LE;}
{EQ} 			{return EQ;}
{NE} 			{return NE;}
{MAIN} 			{return MAIN;}
{INT} 			{return INT;}
{VOID} 			{return VOID;}
{FLOAT} 		{return FLOAT;}
{RETURN} 		{return RETURN;}
{OR} 			{return OR;}
{AND} 			{return AND;}
{IF} 			{return IF;}
{FOR} 			{return FOR;}
{WHILE} 		{return WHILE;}
{ELSE} 			{return ELSE;}
{BREAK} 		{return BREAK;}
{CONTINUE} 		{return CONTINUE;}
{LC}			{return LC;}
{RC}			{return RC;}
{LB}			{return LB;}
{RB}			{return RB;}
{LBP}			{return LBP;}
{RBP}			{return RBP;}
{COMMA}			{return COMMA;}
{SWITCH}    	{return SWITCH;}
{CASE}     	 	{return CASE;}
{DEFAULT} 	  	{return DEFAULT;}
{COLON}    		{return COLON;}
{PRINT}			{return PRINT;}
{STRING}		{yylval.stringVal = strdup(yytext);return STRING;}
{READ}			{return READ;}	

{INTEGERS}				{yylval.stringVal = strdup(yytext);return INTEGERS;}
{LIBRARY}				{yylval.stringVal = strdup(yytext);return LIBRARY;}
{FLOATING_POINTS}		{yylval.stringVal = strdup(yytext);return FLOATING_POINTS;}
{ID}					{yylval.stringVal = strdup(yytext);return ID;}

{NEW_LINE} 			{}
{WHITE_SPACES}		{}

.					{cerr<< "TOKEN CANNOT BE MATCHED :\t"<< yytext <<"\t"<<endl;}

%%
