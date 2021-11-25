/* Basic parser, shows the structure but there's no code generation */

#include <stdio.h>
#include "lex.h"
#include "lex.c"
void expression(void);
void expr_prime(void);
void term(void);
void term_prime(void);
void factor(void);
void mult_stmt(void);
void exp1(void);
void stmt_list(void);
void statement(void);

void mult_stmt(){
    printf("Mult\n");
    if( ! match(EOI) ){
        statement();
        if( match (SEMI) ){
            advance();
            mult_stmt();
        }else{
            printf("error-mult");
        }
    }
}
void statement()
{
    /*  statements -> expression SEMI
     *             |  expression SEMI statements
     */
    printf("Statement-\n");
    if( match( ID )){
        advance();
        if(match( ASSIGN )){
            advance();
            exp1();
        }else{
            printf("error-id");
        }
    }else if( match(IF) ){
        advance();
        exp1();
        if( match( THEN )){
            advance();
            statement();
        }else{
            printf("error-if");
        }
    }else if( match(WHILE) ){
        advance();
        exp1();
        if( match( DO )){
            advance();
            statement();
        }else{
            printf("error-while");
        }
    }else if( match(BEGIN) ){
        advance();
        stmt_list();
        if( match( END )){
            advance();
        }else{
            printf("error-begin");
        }
    }else{
        printf("error-stmt");
    }
}

void exp1(){
    printf("exp1\n");
    expression();
    if( match(EQ) ){
        advance();
        expression();
    }else if( match(LT) ){
        advance();
        expression();
    }else if( match(GT) ){
        advance();
        expression();
    }
}

void stmt_list(){
    printf("stmt_list\n");
    if( ! match(END) ){
        if( ! match(EOI) ){
            statement();
            if( match(SEMI) ){
                advance();
                stmt_list();
            }else{
                printf("error-semi");
            }
        }else{
            printf("error-end");
        }
    }
}

void expression()
{
    /* expression -> term expression' */
    printf("Expression-\n");
    term();
    expr_prime();
}

void expr_prime()
{
    /* expression' -> PLUS term expression'
     *              | epsilon
     */
    printf("Expr_prime-\n");
    if( match( PLUS ) || match( MINUS ))
    {
        advance();
        term();
        expr_prime();
    }
}

void term()
{
    /* term -> factor term' */
    printf("Term-\n");
    factor();
    term_prime();
}

void term_prime()
{
    /* term' -> TIMES factor term'
     *       |   epsilon
     */
    printf("Term_prime-\n");
    if( match( TIMES ) || match ( DIV ) )
    {
        advance();
        factor();
        term_prime();
    }
}

void factor()
{
    /* factor   ->    NUM_OR_ID
     *          |     LP expression RP
     */
    printf("Factor-\n");
    if( match(NUM) || match(ID) ){
        advance();
    }

    else if( match(LP) )
    {
        advance();
        expression();
        if( match(RP) )
            advance();
        else
            fprintf( stderr, "%d: Mismatched parenthesis\n", yylineno);
    }
    else
	    fprintf( stderr, "%d Number or identifier expected\n", yylineno );
}
