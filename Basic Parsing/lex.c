#include "lex.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>

char* yytext = ""; /* Lexeme (not '\0'
                      terminated)              */
int yyleng   = 0;  /* Lexeme length.           */
int yylineno = 0;  /* Input line number        */

int lex(void){

   static char input_buffer[1024];
   char        *current;

   current = yytext + yyleng; /* Skip current
                                 lexeme        */
    // printf("%s\n", current);

   while(1){       /* Get the next one         */
      while(!*current ){
         /* Get new lines, skipping any leading
         * white space on the line,
         * until a nonblank line is found.
         */

         current = input_buffer;
         if(!gets(input_buffer)){
            *current = '\0' ;

            return EOI;
         }
         ++yylineno;
         while(isspace(*current))
            ++current;
      }
      for(; *current; ++current){
         /* Get the next token */
         yytext = current;
         yyleng = 1;
         switch( *current ){
           case ';':
            return SEMI;
           case '+':
            return PLUS;
           case '-':
            return MINUS;
           case '*':
            return TIMES;
           case '/':
            return DIV;
           case '(':
            return LP;
           case ')':
            return RP;
           case '=':
            return EQ;
           case '<':
            return LT;
           case '>':
            return GT;
           case '\n':
           case '\t':
           case ' ' :
            break;
           default:
            if(*current == ':'){
              ++current;
              ++current;
              yyleng = current - yytext;
              return ASSIGN;
            }
            if(!isalnum(*current))
							 fprintf(stderr, "Not alphanumeric <%c>\n", *current);
						else{
						 while(isalnum(*current))
								++current;
						 yyleng = current - yytext;
						 char subbuff[yyleng+1];
						 memcpy( subbuff, yytext, yyleng );
						 subbuff[yyleng] = '\0';
						 if(strcmp(subbuff, "if") == 0)
						 {
								return IF;
						 }
						 else if(strcmp(subbuff, "then") == 0)
						 {
								return THEN;
						 }
						 else if(strcmp(subbuff, "while") == 0)
						 {
								return WHILE;
						 }
						 else if(strcmp(subbuff, "do") == 0)
						 {
								return DO;
						 }
						 else if(strcmp(subbuff, "begin") == 0)
						 {
								return BEGIN;
						 }
						 else if(strcmp(subbuff, "end") == 0)
						 {
								return END;
						 }
             else if(isdigit(subbuff[0]))
             {
               return NUM;
             }
						 return ID;
						}
              break;
         }
      }
   }
}


static int Lookahead = -1; /* Lookahead token  */

int match(int token){
   /* Return true if "token" matches the
      current lookahead symbol.                */

   if(Lookahead == -1){
      Lookahead = lex();
      // printf("%d\n", Lookahead);
   }

   return token == Lookahead;
}

void advance(void){
/* Advance the lookahead to the next
   input symbol.                               */

    Lookahead = lex();
    // printf("%d\n", Lookahead);
}
