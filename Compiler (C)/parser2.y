%{
#define YYSTYPE char *
#include <iostream>
#include <stdio.h>
#include <string.h>
#include <map>
#include <sstream>
#include <vector>
#include <bits/stdc++.h>
using namespace std;

vector <string> allVar;

int yylex(void);

void yyerror (char const *s) {
   	fprintf (stderr, "%s\n", s);
}

FILE *user_code, *final_code;

extern char *yytext;
int labelID=0;
int globArgsIntReg=0;
int globArgsFloReg=6;
int stringCounter=0;


int stringType(string);
void add_operation(char*, char *, char *);
void sub_operation(char*, char *, char *);
void mul_operation(char*, char *, char *);
void div_operation(char*, char *, char *);
void less_than_op(char*, char *, char *);
void great_than_op(char*, char *, char *);
void equal_op(char*, char *, char *);
void less_eq_op(char*, char *, char *);
void great_eq_op(char*, char *, char *);
void not_eq_op(char*, char *, char *);
void checkNewDeclare(char *);
char * getArrayParam(char *);
char * getArrayName(char *);
%}

%start funcs
%token INT FLOAT ID EQ DECL
%token ARITH_REL_OPS
%token IF GOTO LABEL PRINTT STRINGG READD
%token FUNC BEGINN RETURN END PARAM REFPARAM CALL ARGS NULLL
%%

funcs:				func funcs {}
					| func {}

func:				FUNC BEGINN funcname intm_code FUNC END
					{
						fprintf(user_code,"jr $ra\n");
					} 
funcname:			var_ID
					{
						$$ = $1;
						fprintf(user_code, "\n%s:\n", $$);
					}

intm_code:  		/* empty */
        			| intm_code intm_line /* do nothing */ 

intm_line: 			binary_operation {globArgsFloReg = 6; globArgsIntReg = 0;} 
					| assignment {globArgsFloReg = 6; globArgsIntReg = 0;}
					| jump_Cond {globArgsFloReg = 6; globArgsIntReg = 0;}
					| jump_unCond {globArgsFloReg = 6; globArgsIntReg = 0;}
					| label{globArgsFloReg = 6; globArgsIntReg = 0;}

					| arr_decl_stmt {globArgsFloReg = 6; globArgsIntReg = 0;}
					| args_stmt
					| param_stmt 
					| refparam_stmt {globArgsFloReg = 6; globArgsIntReg = 0;}
					| call_stmt {globArgsFloReg = 6; globArgsIntReg = 0;}
					| return_stmt {globArgsFloReg = 6; globArgsIntReg = 0;}
					| print_stmt {globArgsFloReg = 6; globArgsIntReg = 0;}
					| scan_stmt {globArgsFloReg = 6; globArgsIntReg = 0;}

scan_stmt:			READD var_ID
					{
						string opr($2);
						if(stringType(opr)==3){
							string xx(getArrayParam($2));
							char * zz = getArrayParam($2);
							char * yy = getArrayName($2);
							if(stringType(xx)==0)
								fprintf(user_code,"lw $t3, %s\n", zz);
							else
								fprintf(user_code,"li $t3, %s\n", zz);
							fprintf(user_code, "la $t4, %s\n", yy);

							if(yy[0]=='f'){
								fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								
								fprintf(user_code, "li $v0, 6\n");
								fprintf(user_code, "syscall\n");
								fprintf(user_code, "s.s $f0, 0($t4)\n");
							}
							else{
								fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");

								fprintf(user_code, "li $v0, 5\n");
								fprintf(user_code, "syscall\n");
								fprintf(user_code, "sw $v0, 0($t4)\n");
							}
						}
						else if(stringType(opr)==0){
							checkNewDeclare($2);
							if(opr[0]=='f'){
								fprintf(user_code, "li $v0, 6\n");
								fprintf(user_code, "syscall\n");
								fprintf(user_code, "s.s $f0, %s\n", $2);
							}
							else{
								fprintf(user_code, "li $v0, 5\n");
								fprintf(user_code, "syscall\n");
								fprintf(user_code, "sw $v0, %s\n", $2);
							}
						}
					}

print_stmt:			PRINTT id_or_num
					{
						string opr($2);
						if(stringType(opr)==3){
							string xx(getArrayParam($2));
							char * zz = getArrayParam($2);
							char * yy = getArrayName($2);
							if(stringType(xx)==0)
								fprintf(user_code,"lw $t3, %s\n", zz);
							else
								fprintf(user_code,"li $t3, %s\n", zz);
							fprintf(user_code, "la $t4, %s\n", yy);

							if(yy[0]=='f'){
								fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								fprintf(user_code, "l.s $f12, 0($t4)\n");
								fprintf(user_code, "li $v0, 2\n");
							}
							else{
								fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								fprintf(user_code, "lw $a0, 0($t4)\n");
								fprintf(user_code, "li $v0, 1\n");
							}
						}
						else if(stringType(opr)==0){
							checkNewDeclare($2);
							if(opr[0]=='f'){
								fprintf(user_code,"l.s $f12, %s\n", $2);
								fprintf(user_code, "li $v0, 2\n");
							}
							else{
								fprintf(user_code,"lw $a0, %s\n", $2);
								fprintf(user_code, "li $v0, 1\n");
							}
						}
						else{
							if(stringType(opr)==2){
								fprintf(user_code,"li.s $f12, %s\n", $2);
								fprintf(user_code, "li $v0, 2\n");
							}
							else{
								fprintf(user_code,"li $a0, %s\n", $2);
								fprintf(user_code, "li $v0, 1\n");
							}
						}
						fprintf(user_code, "syscall\n");
					}
					| PRINTT stringgg
					{
						fprintf(final_code,"string%d:\t\t.asciiz %s\n", stringCounter, $2);
						fprintf(user_code, "la $a0, string%d\n", stringCounter);
						stringCounter++;
						fprintf(user_code, "li $v0, 4\n");
						fprintf(user_code, "syscall\n");
					}
 
binary_operation: 	var_ID EQ id_or_num arith_rel_ops id_or_num 
					{
						if(strcmp($4,"+")==0)
							add_operation($1, $3, $5);
						else if(strcmp($4,"-")==0)
							sub_operation($1, $3, $5);
						else if(strcmp($4,"*")==0)
							mul_operation($1, $3, $5);
						else if(strcmp($4,"/")==0)
							div_operation($1, $3, $5);
						else if(strcmp($4,"<")==0)
							less_than_op($1, $3, $5);
						else if(strcmp($4,">")==0)
							great_than_op($1, $3, $5);
						else if(strcmp($4,"==")==0)
							equal_op($1, $3, $5);
						else if(strcmp($4,"<=")==0)
							less_eq_op($1, $3, $5);
						else if(strcmp($4,">=")==0)
							great_eq_op($1, $3, $5);
						else if(strcmp($4,"!=")==0)
							not_eq_op($1, $3, $5);
						
					}
			
id_or_num : 		var_ID { $$ = $1;}
					| num {$$ = $1;}

arith_rel_ops: ARITH_REL_OPS {$$ = strdup(yytext);}	

var_ID: 			ID {$$ = strdup(yytext);}

num: 				INT {$$ = strdup(yytext);}
					| FLOAT {$$ = strdup(yytext);}

stringgg:			STRINGG { $$ = strdup(yytext);}

assignment: 		var_ID EQ var_ID 
					{
						bool floR=false, floOp=false, resArr=false, oprArr=false;
						string res($1);
						string opr($3);
						
						if(res[0]=='f')
							floR=true;
						if(opr[0]=='f')
							floOp=true;
						
						checkNewDeclare($3);
						checkNewDeclare($1);


						if(stringType(opr)==3){
							oprArr=true;
							string xx(getArrayParam($3));
							char * zz = getArrayParam($3);
							char * yy = getArrayName($3);
							if(stringType(xx)==0)
								fprintf(user_code,"lw $t3, %s\n", zz);
							else
								fprintf(user_code,"li $t3, %s\n", zz);
							fprintf(user_code, "la $t4, %s\n", yy);

							if(yy[0]=='f'){
								fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								fprintf(user_code, "l.s $f0, 0($t4)\n");
							}
							else{
								fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								fprintf(user_code, "lw $t0, 0($t4)\n");
							}
						}
						if(stringType(res)==3){
							resArr = true;
							string xx(getArrayParam($1));
							char * zz = getArrayParam($1);
							char * yy = getArrayName($1);
							if(stringType(xx)==0)
								fprintf(user_code,"lw $t3, %s\n", zz);
							else
								fprintf(user_code,"li $t3, %s\n", zz);
							fprintf(user_code, "la $t4, %s\n", yy);

							if(yy[0]=='f'){
								fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
							}
							else{
								fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
							}
						}


						if(!floR && !floOp){
							if(!oprArr)
								fprintf(user_code,"lw $t0, %s\n", $3);
							if(!resArr)
								fprintf(user_code,"sw $t0, %s\n", $1);
							else
								fprintf(user_code,"sw $t0, 0($t4)\n");
						}
						else if(floR && !floOp){
							if(!oprArr){
								fprintf(user_code,"l.s $f0, %s\n", $3);
								fprintf(user_code,"cvt.s.w $f0, $f0\n");
							}
							else{
								fprintf(user_code,"mtc1 $t0, $f0\n");
								fprintf(user_code,"cvt.s.w $f0, $f0\n");
							}
							if(!resArr)
								fprintf(user_code,"s.s $f0, %s\n", $1);
							else
								fprintf(user_code,"s.s $f0, 0($t4)\n");
						}
						else if(floR && floOp){
							if(!oprArr)
								fprintf(user_code,"l.s $f0, %s\n", $3);
							if(!resArr)
								fprintf(user_code,"s.s $f0, %s\n", $1);
							else
								fprintf(user_code,"s.s $f0, 0($t4)\n");
						}
						
					}
					| var_ID EQ num 	
					{
						bool floR=false, floOp=false, resArr=false;
						string res($1);
						string opr($3);

						if(res[0]=='f')
							floR=true;
						if(stringType(opr)==2)
							floOp=true;
						
						checkNewDeclare($1);

						if(stringType(res)==3){
							resArr = true;
							string xx(getArrayParam($1));
							char * zz = getArrayParam($1);
							char * yy = getArrayName($1);
							if(stringType(xx)==0)
								fprintf(user_code,"lw $t3, %s\n", zz);
							else
								fprintf(user_code,"li $t3, %s\n", zz);
							fprintf(user_code, "la $t4, %s\n", yy);

							if(yy[0]=='f'){
								fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
							}
							else{
								fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
							}
						}
						
						if(!floR && !floOp){
							fprintf(user_code,"li $t0, %s\n", $3);
							if(!resArr)
								fprintf(user_code,"sw $t0, %s\n", $1);
							else
								fprintf(user_code,"sw $t0, 0($t4)\n");
						}
						else if(floR && !floOp){
							fprintf(user_code,"li.s $f0, %s.0\n", $3);
							if(!resArr)
								fprintf(user_code,"s.s $f0, %s\n", $1);
							else
								fprintf(user_code,"s.s $f0, 0($t4)\n");
						}
						else if(floR && floOp){
							fprintf(user_code,"li.s $f0, %s\n", $3);
							if(!resArr)
								fprintf(user_code,"s.s $f0, %s\n", $1);
							else
								fprintf(user_code,"s.s $f0, 0($t4)\n");
						}
					}

label : 			LABEL 
					{
						$$ = strdup(yytext);
						fprintf(user_code,"%s\n", $$);
					}

jump_Cond : 		IF var_ID GOTO var_ID
					{
						fprintf(user_code,"lw $t0 %s\n", $2);
						fprintf(user_code,"bne $t0, 0 %s\n",$4);
					}
				   	| IF num GOTO var_ID 
					{
						fprintf(user_code,"li $t0 %s\n", $2);
						fprintf(user_code,"bne $t0, 0 %s\n",$4);
					}

jump_unCond : 		GOTO var_ID
					{
						fprintf(user_code,"b %s\n",$2);
					}

args_stmt	: 		ARGS var_ID 
					{
						string a($2);
						allVar.push_back(a);
						if($2[0]=='f'){
							fprintf(final_code, "%s:\t\t.float 0.0\n", $2);
							fprintf(user_code, "s.s $f%d, %s\n", globArgsFloReg, $2);
							globArgsFloReg++;
						}
						else{
							fprintf(final_code, "%s:\t\t.word 0\n", $2);
							fprintf(user_code, "sw $s%d, %s\n", globArgsIntReg, $2);
							globArgsIntReg++;
						}
					}

arr_decl_stmt:		DECL var_ID
					{
						string arrName(getArrayName($2));
						//string arrSize(getArrayParam($2));
						int n = atoi(getArrayParam($2));
						string ss="";
						if(arrName[0]=='f'){
							for(int i=1;i<n;i++)
								ss += "0.0, ";
							ss += "0.0";
							const char *cstr = ss.c_str();
							fprintf(final_code, "%s:\t\t.float %s\n", getArrayName($2), cstr);
						}
						else{
							for(int i=1;i<n;i++)
								ss += "0, ";
							ss += "0";
							const char *cstr = ss.c_str();
							fprintf(final_code, "%s:\t\t.word %s\n", getArrayName($2), cstr);
						}
					}

param_stmt	: 		PARAM id_or_num
					{
						string a($2);
						if(stringType(a)==3){
							string xx(getArrayParam($2));
							char * zz = getArrayParam($2);
							char * yy = getArrayName($2);
							if(stringType(xx)==0)
								fprintf(user_code,"lw $t3, %s\n", zz);
							else
								fprintf(user_code,"li $t3, %s\n", zz);
							fprintf(user_code, "la $t4, %s\n", yy);

							if(yy[0]=='f'){
								fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								fprintf(user_code, "l.s $f%d, 0($t4)\n",globArgsFloReg);
								globArgsFloReg++;
							}
							else{
								fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								fprintf(user_code, "lw $s%d, 0($t4)\n",globArgsIntReg);
								globArgsIntReg++;
							}
						}
						else if(stringType(a)==0)
						{
							checkNewDeclare($2);
							if(a[0]=='f'){
								fprintf(user_code, "l.s $f%d, %s\n", globArgsFloReg, $2);
								globArgsFloReg++;
							}
							else{
								fprintf(user_code, "lw $s%d, %s\n", globArgsIntReg, $2);
								globArgsIntReg++;
							}
						}
						else if(stringType(a)==1)
						{
							fprintf(user_code, "li $s%d, %s\n", globArgsIntReg, $2);
							globArgsIntReg++;
						}
						else
						{
							fprintf(user_code, "li.s $f%d, %s\n", globArgsFloReg, $2);
							globArgsFloReg++;
						}
					}
return_stmt	: 		RETURN ret_val
					{
						fprintf(user_code,"jr $ra\n" );
					}

ret_val		: 		NULLL {}
					| id_or_num 
					{
						$$ = $1;
						checkNewDeclare($1);
						string a($1);

						if(stringType(a)==3){
							string xx(getArrayParam($1));
							char * zz = getArrayParam($1);
							char * yy = getArrayName($1);
							if(stringType(xx)==0)
								fprintf(user_code,"lw $t3, %s\n", zz);
							else
								fprintf(user_code,"li $t3, %s\n", zz);
							fprintf(user_code, "la $t4, %s\n", yy);

							if(yy[0]=='f'){
								fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								fprintf(user_code, "l.s $f20, 0($t4)\n");
								
							}
							else{
								fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								fprintf(user_code, "lw $s7, 0($t4)\n");
								
							}
						}
						else if(stringType(a)==0){
							
							if(a[0]=='f')
								fprintf(user_code, "l.s $f20, %s\n", $1);
							else
								fprintf(user_code, "lw $s7, %s\n", $1);
						}
						else if(stringType(a)==1)
							fprintf(user_code, "li $s7, %s\n", $1);
						else
							fprintf(user_code, "li.s $f20, %s\n", $1);
					}

refparam_stmt	:	REFPARAM var_ID
					{
						checkNewDeclare($2);
						string a($2);
						if(stringType(a)==3){
							string xx(getArrayParam($2));
							char * zz = getArrayParam($2);
							char * yy = getArrayName($2);
							if(stringType(xx)==0)
								fprintf(user_code,"lw $t3, %s\n", zz);
							else
								fprintf(user_code,"li $t3, %s\n", zz);
							fprintf(user_code, "la $t4, %s\n", yy);

							if(yy[0]=='f'){
								fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								fprintf(user_code, "s.s $f20, 0($t4)\n");
								
							}
							else{
								fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
								fprintf(user_code, "add $t4, $t4, $t3\n");
								fprintf(user_code, "sw $s7, 0($t4)\n");
								
							}
						}
						else{
							if($2[0]=='f')
								fprintf(user_code, "s.s $f20, %s\n", $2);
							else
								fprintf(user_code, "sw $s7, %s\n", $2);
						}						
					}

call_stmt		:	CALL var_ID
					{
						fprintf(user_code, "addi $sp, $sp, -4\n");
						fprintf(user_code, "sw $ra, 0($sp)\n");
						fprintf(user_code, "jal %s\n", $2);
						fprintf(user_code, "lw $ra, 0($sp)\n");
						fprintf(user_code, "addi $sp, $sp, 4\n");
					}

%%

int stringType(string x){
	for(int i=0; i<x.size();i++){
		if(x[i]=='(')
			return 3;	// Array Var
	}
	if(x[0]=='f'||x[0]=='i')
		return 0; 		// Variable 
	for(int i=0; i<x.size();i++){
		if(x[i]=='.')
			return 2;	// Float
	}
	return 1;			// Integer
}

char * getArrayName(char *a){
	string s(a);
	string s2 = s.substr(0, s.find("("));
	char *cstr = new char[s2.length() + 1];
	strcpy(cstr, s2.c_str());
	return cstr;
}

char * getArrayParam(char * a){
	string s(a);
	string s2 = s.substr(s.find("(")+1, s.find(")")-s.find("(")-1);
	char *cstr = new char[s2.length() + 1];
	strcpy(cstr, s2.c_str());
	return cstr;
}

void add_operation(char *r, char *a, char *b){
	string res(r);
	string op1(a);
	string op2(b);
	bool flo1=false;
	bool flo2=false;

	if(stringType(op1)==3){
		string xx(getArrayParam(a));
		char * zz = getArrayParam(a);
		char * yy = getArrayName(a);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "l.s $f1, 0($t4)\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "lw $t1, 0($t4)\n");
		}

	}
	else if(stringType(op1)==0){
		checkNewDeclare(a);
		if(op1[0]=='f'){
			flo1 = true;
			fprintf(user_code,"l.s $f1, %s\n",a);
		}
		else{
			fprintf(user_code,"lw $t1, %s\n",a);
		}
	}
	else{
		if(stringType(op1)==2){
			flo1 = true;
			fprintf(user_code,"li.s $f1, %s\n",a);
		}
		else{
			fprintf(user_code,"li $t1, %s\n",a);
		}
	}

	if(stringType(op2)==3){
		string xx(getArrayParam(b));
		char * zz = getArrayParam(b);
		char * yy = getArrayName(b);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "l.s $f2, 0($t4)\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "lw $t2, 0($t4)\n");
		}

	}
	else if(stringType(op2)==0){
		checkNewDeclare(b);
		if(op2[0]=='f'){
			flo2 = true;
			fprintf(user_code,"l.s $f2, %s\n",b);
		}
		else{
			fprintf(user_code,"lw $t2, %s\n",b);
		}
	}
	else{
		if(stringType(op2)==2){
			flo2 = true;
			fprintf(user_code,"li.s $f2, %s\n",b);
		}
		else{
			fprintf(user_code,"li $t2, %s\n",b);
		}
	}

	if(stringType(res)!=3)
		checkNewDeclare(r);
	
	bool resArr = false;
	if(stringType(res)==3){
		resArr = true;
		string xx(getArrayParam(r));
		char * zz = getArrayParam(r);
		char * yy = getArrayName(r);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
		}
	}
	if(flo1 || flo2){
		if(!flo1){
			fprintf(user_code,"mtc1 $t1, $f1\n");
			fprintf(user_code,"cvt.s.w $f1, $f1\n");
		}
		if(!flo2){
			fprintf(user_code,"mtc1 $t2, $f2\n");
			fprintf(user_code,"cvt.s.w $f2, $f2\n");
		}
		fprintf(user_code,"add.s $f0, $f1, $f2\n");
		if(!resArr)
			fprintf(user_code,"s.s $f0, %s\n", r);
		else
			fprintf(user_code,"s.s $f0, 0($t4)\n");
	}
	else{
		fprintf(user_code,"add $t0, $t1, $t2\n");
		if(!resArr)
			fprintf(user_code,"sw $t0, %s\n", r);
		else
			fprintf(user_code,"sw $t0, 0($t4)\n");
	}
}

void sub_operation(char *r, char *a, char *b){
	string res(r);
	string op1(a);
	string op2(b);
	bool flo1=false;
	bool flo2=false;

	if(stringType(op1)==3){
		string xx(getArrayParam(a));
		char * zz = getArrayParam(a);
		char * yy = getArrayName(a);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "l.s $f1, 0($t4)\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "lw $t1, 0($t4)\n");
		}

	}
	else if(stringType(op1)==0){
		checkNewDeclare(a);
		if(op1[0]=='f'){
			flo1 = true;
			fprintf(user_code,"l.s $f1, %s\n",a);
		}
		else{
			fprintf(user_code,"lw $t1, %s\n",a);
		}
	}
	else{
		if(stringType(op1)==2){
			flo1 = true;
			fprintf(user_code,"li.s $f1, %s\n",a);
		}
		else{
			fprintf(user_code,"li $t1, %s\n",a);
		}
	}

	if(stringType(op2)==3){
		string xx(getArrayParam(b));
		char * zz = getArrayParam(b);
		char * yy = getArrayName(b);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "l.s $f2, 0($t4)\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "lw $t2, 0($t4)\n");
		}

	}
	else if(stringType(op2)==0){
		checkNewDeclare(b);
		if(op2[0]=='f'){
			flo2 = true;
			fprintf(user_code,"l.s $f2, %s\n",b);
		}
		else{
			fprintf(user_code,"lw $t2, %s\n",b);
		}
	}
	else{
		if(stringType(op2)==2){
			flo2 = true;
			fprintf(user_code,"li.s $f2, %s\n",b);
		}
		else{
			fprintf(user_code,"li $t2, %s\n",b);
		}
	}

	if(stringType(res)!=3)
		checkNewDeclare(r);

	bool resArr = false;
	if(stringType(res)==3){
		resArr = true;
		string xx(getArrayParam(r));
		char * zz = getArrayParam(r);
		char * yy = getArrayName(r);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
		}
	}
	if(flo1 || flo2){
		if(!flo1){
			fprintf(user_code,"mtc1 $t1, $f1\n");
			fprintf(user_code,"cvt.s.w $f1, $f1\n");
		}
		if(!flo2){
			fprintf(user_code,"mtc1 $t2, $f2\n");
			fprintf(user_code,"cvt.s.w $f2, $f2\n");
		}
		fprintf(user_code,"sub.s $f0, $f1, $f2\n");
		if(!resArr)
			fprintf(user_code,"s.s $f0, %s\n", r);
		else
			fprintf(user_code,"s.s $f0, 0($t4)\n");
	}
	else{
		fprintf(user_code,"sub $t0, $t1, $t2\n");
		if(!resArr)
			fprintf(user_code,"sw $t0, %s\n", r);
		else
			fprintf(user_code,"sw $t0, 0($t4)\n");
	}
}

void mul_operation(char *r, char *a, char *b){
	string res(r);
	string op1(a);
	string op2(b);
	bool flo1=false;
	bool flo2=false;

	if(stringType(op1)==3){
		string xx(getArrayParam(a));
		char * zz = getArrayParam(a);
		char * yy = getArrayName(a);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "l.s $f1, 0($t4)\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "lw $t1, 0($t4)\n");
		}

	}
	else if(stringType(op1)==0){
		checkNewDeclare(a);
		if(op1[0]=='f'){
			flo1 = true;
			fprintf(user_code,"l.s $f1, %s\n",a);
		}
		else{
			fprintf(user_code,"lw $t1, %s\n",a);
		}
	}
	else{
		if(stringType(op1)==2){
			flo1 = true;
			fprintf(user_code,"li.s $f1, %s\n",a);
		}
		else{
			fprintf(user_code,"li $t1, %s\n",a);
		}
	}

	if(stringType(op2)==3){
		string xx(getArrayParam(b));
		char * zz = getArrayParam(b);
		char * yy = getArrayName(b);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "l.s $f2, 0($t4)\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "lw $t2, 0($t4)\n");
		}

	}
	else if(stringType(op2)==0){
		checkNewDeclare(b);
		if(op2[0]=='f'){
			flo2 = true;
			fprintf(user_code,"l.s $f2, %s\n",b);
		}
		else{
			fprintf(user_code,"lw $t2, %s\n",b);
		}
	}
	else{
		if(stringType(op2)==2){
			flo2 = true;
			fprintf(user_code,"li.s $f2, %s\n",b);
		}
		else{
			fprintf(user_code,"li $t2, %s\n",b);
		}
	}

	if(stringType(res)!=3)
		checkNewDeclare(r);
		
	bool resArr = false;
	if(stringType(res)==3){
		resArr = true;
		string xx(getArrayParam(r));
		char * zz = getArrayParam(r);
		char * yy = getArrayName(r);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
		}
	}
	if(flo1 || flo2){
		if(!flo1){
			fprintf(user_code,"mtc1 $t1, $f1\n");
			fprintf(user_code,"cvt.s.w $f1, $f1\n");
		}
		if(!flo2){
			fprintf(user_code,"mtc1 $t2, $f2\n");
			fprintf(user_code,"cvt.s.w $f2, $f2\n");
		}
		fprintf(user_code,"mul.s $f0, $f1, $f2\n");
		if(!resArr)
			fprintf(user_code,"s.s $f0, %s\n", r);
		else
			fprintf(user_code,"s.s $f0, 0($t4)\n");
	}
	else{
		fprintf(user_code,"mul $t0, $t1, $t2\n");
		if(!resArr)
			fprintf(user_code,"sw $t0, %s\n", r);
		else
			fprintf(user_code,"sw $t0, 0($t4)\n");
	}
}

void div_operation(char *r, char *a, char *b){
	string res(r);
	string op1(a);
	string op2(b);
	bool flo1=false;
	bool flo2=false;

	if(stringType(op1)==3){
		string xx(getArrayParam(a));
		char * zz = getArrayParam(a);
		char * yy = getArrayName(a);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "l.s $f1, 0($t4)\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "lw $t1, 0($t4)\n");
		}

	}
	else if(stringType(op1)==0){
		checkNewDeclare(a);
		if(op1[0]=='f'){
			flo1 = true;
			fprintf(user_code,"l.s $f1, %s\n",a);
		}
		else{
			fprintf(user_code,"lw $t1, %s\n",a);
		}
	}
	else{
		if(stringType(op1)==2){
			flo1 = true;
			fprintf(user_code,"li.s $f1, %s\n",a);
		}
		else{
			fprintf(user_code,"li $t1, %s\n",a);
		}
	}

	if(stringType(op2)==3){
		string xx(getArrayParam(b));
		char * zz = getArrayParam(b);
		char * yy = getArrayName(b);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "l.s $f2, 0($t4)\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
			fprintf(user_code, "lw $t2, 0($t4)\n");
		}

	}
	else if(stringType(op2)==0){
		checkNewDeclare(b);
		if(op2[0]=='f'){
			flo2 = true;
			fprintf(user_code,"l.s $f2, %s\n",b);
		}
		else{
			fprintf(user_code,"lw $t2, %s\n",b);
		}
	}
	else{
		if(stringType(op2)==2){
			flo2 = true;
			fprintf(user_code,"li.s $f2, %s\n",b);
		}
		else{
			fprintf(user_code,"li $t2, %s\n",b);
		}
	}

	if(stringType(res)!=3)
		checkNewDeclare(r);
		
	bool resArr = false;
	if(stringType(res)==3){
		resArr = true;
		string xx(getArrayParam(r));
		char * zz = getArrayParam(r);
		char * yy = getArrayName(r);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		if(yy[0]=='f'){
			fprintf(user_code, "li $t5, 8\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
		}
		else{
			fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
			fprintf(user_code, "add $t4, $t4, $t3\n");
		}
	}
	if(flo1 || flo2){
		if(!flo1){
			fprintf(user_code,"mtc1 $t1, $f1\n");
			fprintf(user_code,"cvt.s.w $f1, $f1\n");
		}
		if(!flo2){
			fprintf(user_code,"mtc1 $t2, $f2\n");
			fprintf(user_code,"cvt.s.w $f2, $f2\n");
		}
		fprintf(user_code,"div.s $f0, $f1, $f2\n");
		if(!resArr)
			fprintf(user_code,"s.s $f0, %s\n", r);
		else
			fprintf(user_code,"s.s $f0, 0($t4)\n");
	}
	else{
		fprintf(user_code,"div $t0, $t1, $t2\n");
		if(!resArr)
			fprintf(user_code,"sw $t0, %s\n", r);
		else
			fprintf(user_code,"sw $t0, 0($t4)\n");
	}
}

void less_than_op(char *r, char *a, char *b){
	string res(r);
	string op1(a);
	string op2(b);

	checkNewDeclare(a);
	checkNewDeclare(b);
	checkNewDeclare(r);
	
	if(stringType(op1)==3){
		string xx(getArrayParam(a));
		char * zz = getArrayParam(a);
		char * yy = getArrayName(a);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t1, 0($t4)\n");
	}
	else if(stringType(op1)==0)
		fprintf(user_code,"lw $t1, %s\n",a);
	else
		fprintf(user_code,"li $t1, %s\n",a);
	

	if(stringType(op2)==3){
		string xx(getArrayParam(b));
		char * zz = getArrayParam(b);
		char * yy = getArrayName(b);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t2, 0($t4)\n");
	}
	else if(stringType(op2)==0)
		fprintf(user_code,"lw $t2, %s\n",b);
	else
		fprintf(user_code,"li $t2, %s\n",b);
	
	fprintf(user_code,"li $t0, 0\n");
	fprintf(user_code,"slt $t0, $t1, $t2\n");
	fprintf(user_code,"sw $t0, %s\n", r);
}

void great_than_op(char *r, char *a, char *b){
	string res(r);
	string op1(a);
	string op2(b);

	checkNewDeclare(a);
	checkNewDeclare(b);
	checkNewDeclare(r);
	
	if(stringType(op1)==3){
		string xx(getArrayParam(a));
		char * zz = getArrayParam(a);
		char * yy = getArrayName(a);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t1, 0($t4)\n");
	}
	else if(stringType(op1)==0)
		fprintf(user_code,"lw $t1, %s\n",a);
	else
		fprintf(user_code,"li $t1, %s\n",a);
	

	if(stringType(op2)==3){
		string xx(getArrayParam(b));
		char * zz = getArrayParam(b);
		char * yy = getArrayName(b);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t2, 0($t4)\n");
	}
	else if(stringType(op2)==0)
		fprintf(user_code,"lw $t2, %s\n",b);
	else
		fprintf(user_code,"li $t2, %s\n",b);
	
	fprintf(user_code,"li $t0, 0\n");
	fprintf(user_code,"sgt $t0, $t1, $t2\n");
	fprintf(user_code,"sw $t0, %s\n", r);
}

void equal_op(char *r, char *a, char *b){
	string res(r);
	string op1(a);
	string op2(b);

	checkNewDeclare(a);
	checkNewDeclare(b);
	checkNewDeclare(r);
	
	if(stringType(op1)==3){
		string xx(getArrayParam(a));
		char * zz = getArrayParam(a);
		char * yy = getArrayName(a);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t1, 0($t4)\n");
	}
	else if(stringType(op1)==0)
		fprintf(user_code,"lw $t1, %s\n",a);
	else
		fprintf(user_code,"li $t1, %s\n",a);
	

	if(stringType(op2)==3){
		string xx(getArrayParam(b));
		char * zz = getArrayParam(b);
		char * yy = getArrayName(b);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t2, 0($t4)\n");
	}
	else if(stringType(op2)==0)
		fprintf(user_code,"lw $t2, %s\n",b);
	else
		fprintf(user_code,"li $t2, %s\n",b);
	
	fprintf(user_code,"li $t0, 0\n");
	fprintf(user_code,"seq $t0, $t1, $t2\n");
	fprintf(user_code,"sw $t0, %s\n", r);
}

void less_eq_op(char *r, char *a, char *b){
	string res(r);
	string op1(a);
	string op2(b);

	checkNewDeclare(a);
	checkNewDeclare(b);
	checkNewDeclare(r);
	
	if(stringType(op1)==3){
		string xx(getArrayParam(a));
		char * zz = getArrayParam(a);
		char * yy = getArrayName(a);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t1, 0($t4)\n");
	}
	else if(stringType(op1)==0)
		fprintf(user_code,"lw $t1, %s\n",a);
	else
		fprintf(user_code,"li $t1, %s\n",a);
	

	if(stringType(op2)==3){
		string xx(getArrayParam(b));
		char * zz = getArrayParam(b);
		char * yy = getArrayName(b);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t2, 0($t4)\n");
	}
	else if(stringType(op2)==0)
		fprintf(user_code,"lw $t2, %s\n",b);
	else
		fprintf(user_code,"li $t2, %s\n",b);
	
	fprintf(user_code,"li $t0, 0\n");
	fprintf(user_code,"sle $t0, $t1, $t2\n");
	fprintf(user_code,"sw $t0, %s\n", r);
}

void great_eq_op(char *r, char *a, char *b){
	string res(r);
	string op1(a);
	string op2(b);

	checkNewDeclare(a);
	checkNewDeclare(b);
	checkNewDeclare(r);
	
	if(stringType(op1)==3){
		string xx(getArrayParam(a));
		char * zz = getArrayParam(a);
		char * yy = getArrayName(a);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t1, 0($t4)\n");
	}
	else if(stringType(op1)==0)
		fprintf(user_code,"lw $t1, %s\n",a);
	else
		fprintf(user_code,"li $t1, %s\n",a);
	

	if(stringType(op2)==3){
		string xx(getArrayParam(b));
		char * zz = getArrayParam(b);
		char * yy = getArrayName(b);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t2, 0($t4)\n");
	}
	else if(stringType(op2)==0)
		fprintf(user_code,"lw $t2, %s\n",b);
	else
		fprintf(user_code,"li $t2, %s\n",b);
	
	fprintf(user_code,"li $t0, 0\n");
	fprintf(user_code,"sge $t0, $t1, $t2\n");
	fprintf(user_code,"sw $t0, %s\n", r);
}

void not_eq_op(char *r, char *a, char *b){
	string res(r);
	string op1(a);
	string op2(b);

	checkNewDeclare(a);
	checkNewDeclare(b);
	checkNewDeclare(r);
	
	if(stringType(op1)==3){
		string xx(getArrayParam(a));
		char * zz = getArrayParam(a);
		char * yy = getArrayName(a);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t1, 0($t4)\n");
	}
	else if(stringType(op1)==0)
		fprintf(user_code,"lw $t1, %s\n",a);
	else
		fprintf(user_code,"li $t1, %s\n",a);
	

	if(stringType(op2)==3){
		string xx(getArrayParam(b));
		char * zz = getArrayParam(b);
		char * yy = getArrayName(b);
		if(stringType(xx)==0)
			fprintf(user_code,"lw $t3, %s\n", zz);
		else
			fprintf(user_code,"li $t3, %s\n", zz);
		fprintf(user_code, "la $t4, %s\n", yy);

		fprintf(user_code, "li $t5, 4\n"); fprintf(user_code, "mul $t3, $t3, $t5\n");
		fprintf(user_code, "add $t4, $t4, $t3\n");
		fprintf(user_code, "lw $t2, 0($t4)\n");
	}
	else if(stringType(op2)==0)
		fprintf(user_code,"lw $t2, %s\n",b);
	else
		fprintf(user_code,"li $t2, %s\n",b);
	
	fprintf(user_code,"li $t0, 0\n");
	fprintf(user_code,"sne $t0, $t1, $t2\n");
	fprintf(user_code,"sw $t0, %s\n", r);
}

void checkNewDeclare(char * s){
	string ss(s);
	if(stringType(ss)!=0)
		return;
	
	if(find(allVar.begin(), allVar.end(), ss) == allVar.end()){
		allVar.push_back(ss);
		if(s[0]=='f')
			fprintf(final_code,"%s:\t\t .float 0.0\n", s);
		else
			fprintf(final_code,"%s:\t\t .word 0\n", s);
		
	}
}

int main (void) {
	char a[1000];
	
	user_code=fopen("temp_mips.s","w");
	final_code=fopen("mips.s","w");

	fprintf(final_code,".data\n");
	fprintf(final_code,"newLine:\t\t.asciiz \"\\n\"\n");

	yyparse ();

	fprintf(final_code,"\n.text\n" );
	
	fclose(user_code);
	fclose(final_code);

	std::ifstream in("temp_mips.s");
	std::ofstream out("mips.s", std::ios::app);
	out << in.rdbuf();
	
	return 0;
}

int yyerror (char *s){
	fprintf (stderr, "%s\n", s);
}
