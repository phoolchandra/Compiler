#define EOI		0	/* End of input			*/
#define SEMI		1	/* ; 				*/
#define PLUS 		2	/* + 				*/
#define MINUS       3   /* -                */
#define TIMES		4	/* * 				*/
#define DIV         5   /* /                */
#define LP		6	/* (				*/
#define RP		7	/* )				*/
#define NUM     8	/* Decimal Number or Identifier */
#define ID          9
#define IF          10
#define THEN        11
#define WHILE       12
#define DO          13
#define LT          14
#define GT          15
#define EQ          16
#define ASSIGN          17
#define END         18
#define BEGIN         19

extern char *yytext;		/* in lex.c			*/
extern int yyleng;
extern int yylineno;
