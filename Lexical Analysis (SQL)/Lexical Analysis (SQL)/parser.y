%{
#include <stdio.h>
void yyerror(char *s){
	printf ("Invalid Syntax\n");
}
%}
%union{ char * stringVal; }
%token <stringVal> SELECT LT GT LE GE EQ OB CB PROJECT CARTESIAN NAME EQUI AND OR COMMA DOT SEMI NEQ STRING DIGIT
%start STATEMENTS
%%
STATEMENTS :            STATEMENT STATEMENTS   {}
                    |   STATEMENT              {}

STATEMENT :             SELECT LT CONDITIONS GT OB NAME CB SEMI {printf("Valid Syntax\n");}
                    |   PROJECT LT ATTR_LIST GT OB NAME CB SEMI {printf("Valid Syntax\n");}
                    |   OB NAME CB CARTESIAN OB NAME CB SEMI    {printf("Valid Syntax\n");}
                    |   OB NAME CB EQUI LT EQUI_CONDITION GT OB NAME CB SEMI    {printf("Valid Syntax\n");}
                    |   error SEMI { yyerrok; }


CONDITIONS :            CONDITION AND CONDITIONS        {}
                    |   CONDITION OR CONDITIONS         {}       
                    |   CONDITION                       {}

CONDITION  :     		NAME EQ STRING 	        {}
					|	NAME NEQ STRING			{}
                    |   NAME EQ NAME            {}
                    |	NAME NEQ NAME			{}
                    |   NAME LT NAME            {}
                    |   NAME GT NAME            {}
                    |   NAME LE NAME            {}
                    |   NAME GE NAME            {}
                    |   NAME LT DIGIT            {}
                    |   NAME GT DIGIT            {}
                    |   NAME LE DIGIT            {}
                    |   NAME GE DIGIT            {}
                    |   NAME EQ DIGIT			{}
                    |	NAME NEQ DIGIT			{}

ATTR_LIST  :            NAME COMMA ATTR_LIST            {}
                    |   NAME                            {}

EQUI_CONDITION :        NAME DOT NAME EQ NAME DOT NAME  {}
					|	NAME DOT NAME NEQ NAME DOT NAME  {}

%%

int main(){
    yyparse();
    return 0;
}