%option noyywrap
%{
	#include <stdio.h>
	#include "parser.tab.h"
%}

%s HASH

%%
"SELECT"                {yylval.stringVal = strdup(yytext);return SELECT;}
"<"                    {yylval.stringVal = strdup(yytext);return LT;}
">"                    {yylval.stringVal = strdup(yytext);return GT;}
"("					{yylval.stringVal = strdup(yytext);return OB;}
")"					{yylval.stringVal = strdup(yytext);return CB;}
"PROJECT"				{yylval.stringVal = strdup(yytext);return PROJECT;}
"CARTESIAN_PRODUCT"				{yylval.stringVal = strdup(yytext);return CARTESIAN;}
"EQUI_JOIN"					{yylval.stringVal = strdup(yytext);return EQUI;}
"AND"					{yylval.stringVal = strdup(yytext);return AND;}
"OR"					{yylval.stringVal = strdup(yytext);return OR;}
[a-zA-Z_][a-zA-Z0-9_]*	{yylval.stringVal = strdup(yytext);return NAME;}
[0-9]+						{yylval.stringVal = strdup(yytext);return DIGIT;}
"'"[a-zA-Z0-9_ ]*"'"			{yylval.stringVal = strdup(yytext);return STRING;}
"="                    {yylval.stringVal = strdup(yytext);return EQ;}
"<="                    {yylval.stringVal = strdup(yytext);return LE;}
">="                    {yylval.stringVal = strdup(yytext);return GE;}
","                 {yylval.stringVal = strdup(yytext);return COMMA;}
"."                   {yylval.stringVal = strdup(yytext);return DOT;}
[ \n\t]+                {}
";"					{yylval.stringVal = strdup(yytext);return SEMI;}
.                       {printf("error\n");}
"!="					{yylval.stringVal = strdup(yytext);return NEQ;}

%%