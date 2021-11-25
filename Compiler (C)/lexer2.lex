%{

#include<stdio.h>
#include<iostream>
#include "parser2.tab.h"
using namespace std;

%}
%%
"NULL"													{return(NULLL);}
"read"													{return(READD);}
"print"													{return(PRINTT);}
"decl"													{return(DECL);}
"func"													{return(FUNC);}
"begin"													{return(BEGINN);}
"return"												{return(RETURN);}
"end"													{return(END);}
"param"													{return(PARAM);}
"refparam"												{return(REFPARAM);}
"call"													{return(CALL);}
"args"													{return(ARGS);}
"if" 													{return(IF);}
"goto" 													{return(GOTO);}
\"(\\.|[^\"])*\"										{return(STRINGG);}
[a-zA-z]+[a-zA-z0-9._]*[(][a-zA-z0-9._]+[)]				{return(ID);}
[a-zA-z]+[a-zA-z0-9._]* 								{return(ID);}
"==" 													{return(ARITH_REL_OPS);}
"<="													{return(ARITH_REL_OPS);}
">="													{return(ARITH_REL_OPS);}
"!="													{return(ARITH_REL_OPS);}
[-+*/<>] 												{return(ARITH_REL_OPS);}
[0-9]+ 													{return(INT);}
[-][0-9]+												{return(INT);}
[0-9]+[.][0-9]+											{return(FLOAT);}
[-][0-9]+[.][0-9]+										{return(FLOAT);}
[=] 													{return(EQ);}
[a-zA-z]+[a-zA-z0-9]*[:] 								{return(LABEL);}

(.|\n)								
%%

int yywrap()
{
	return 1;
}
