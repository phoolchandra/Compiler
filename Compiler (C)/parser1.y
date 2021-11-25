%{
	#include <bits/stdc++.h>
	#include<string.h>
	#define pb push_back

	using namespace std;

	extern int yylex();
	extern int yyparse();
	extern int yylineno;
	void yyerror(string s);
 	extern char* yytext;
 	extern int yyleng;
	int syntaxERROR = 0;

	void yyerror(char *s){
		syntaxERROR = 1;
		printf ("Syntax Error in line no. %d\n",yylineno);
	}

	struct ptr{
		vector<ptr*> children;
		string dtype;
		float value;
		string svalue;
		string tag;
		int gScope = 0;
		vector<int> dimptr;
		vector<int> dimptrorg;
		vector<string> dimptrstr;
	};

	struct variable{
		vector<int> dim;
		string name;
		int array;
		int scope;
		string dtype;
	};

	struct func{
		int numparam;
		vector< variable * > params;
		string returntype;
		string name;
	};

	vector < map< string , variable* >> SymTable;
	map<string , func* > FuncTable;
	string activeFunc = "";
	string returnType = "";
	vector<vector<string>> para;
	string currFunc = "";
	vector<string> callFunc;
	int gScope = 0;
	int semanticERROR = 0;
	ptr * treeRoot;
	string gtype = "";
	string gid = "";
	vector<int> gdimv;
	vector<string> gfcallparam;
	vector<vector<string>> gfcallparam2d;
	vector< variable * > gparams;
	void SymTablePrint();
	string convert(string s);
	int checkOutofBound(vector<int> v);
	int findScope(string gid);
	string decideintfloat(string a, string b);
	variable * gvar;
	string chk;
	int printFlag = 0;
	vector<vector<int>> gdimv2d;
	vector<string> brk ,cont;
	FILE * f = fopen("intermediate.txt", "w");
	FILE * q = fopen("quadruple.txt", "w");
	vector<ptr*> funcList;

	vector<vector<string>> brlist;
%}

%union 
{
	struct ptr* Ptr;
	char * stringVal;
}

%token ADD SUB MUL DIV GT LT GE LBP RBP LE EQ NE MAIN INT FLOAT PRINT RETURN OR AND IF FOR READ WHILE ELSE BREAK CONTINUE INTEGERS FLOATING_POINTS ID SEMI LC RC LB RB COMMA EQUAL  LIBRARY VOID SWITCH CASE DEFAULT COLON STRING
%type<Ptr> grammar_start libraries decls decl break continue var_decl type var_list var id br_list br_list1 for_exp func_decl lbf lcf rcf func_end decl_plist decl_pl decl_param body stmts stmt exp case_exp default_exp return_exp exp_type_1 exp_type_2 exp_type_3 arith_exp_type_1 arith_exp_type_2 unary_exp term func_call args args_list args1 args_list1 consts intg floats plus_minus_op mul_div_op relation_op unary_operator string
%start	grammar_start

%%
grammar_start : 	libraries decls INT MAIN {returnType = "int";} LB RB lcf body rcf 
															{   
																treeRoot = new ptr; 
																treeRoot->children.pb($1);
																treeRoot->children.pb($2);
																treeRoot->children.pb($8);
																treeRoot->children.pb($9);
																treeRoot->children.pb($10);
																treeRoot->tag = "START";
															}
                    |   error RC						    { yyerrok; syntaxERROR = 1;treeRoot = new ptr;}

libraries : 		LIBRARY libraries 						
															{
																ptr *t = new ptr;
																t->tag = "LIBRARIES";
																t->gScope = gScope;
																(t->children).pb($2);
																$$ = t;
															}
					|  LIBRARY
															{
																ptr *t = new ptr;
																t->gScope = gScope;
																t->tag = "LIBRARIES";
																$$ = t;
															}

decls : 			decls decl  							
															{ 
																ptr *t = new ptr;
																t->tag = "GDECLS";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																$$ = t;
															}
					|  				
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "GDECLS";
																$$ = t;
															}	

decl :  			func_decl		
															{ 
																ptr * t = new ptr;
																t->tag = "GDECL";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}
					|	var_decl  	
															{ 
																ptr * t = new ptr;
																t->tag = "GDECL";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t; 
															}
					| exp SEMI 																						
															{
																ptr * t = new ptr;																
																t->tag = "STMTEXP";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}

					| error SEMI 							{yyerrok;syntaxERROR=1;}
					
var_decl : 			type var_list SEMI 	
															{ 
																ptr * t = new ptr;
																t->tag = "VARDECL";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																$$ = t;
															}
					| type var EQUAL exp_type_1 SEMI 
															{
																ptr * t = new ptr;
																t->tag = "VARDECL";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																(t->children).pb($4);
																$$ = t;
															}

type :				INT 
															{
																ptr * t = new ptr;
																t-> dtype = "int";
																t->gScope = gScope;
																gtype = "int";
																t-> tag = "TYPE";
																$$ = t;
															}
					| FLOAT 
															{
																ptr * t = new ptr;
																t-> dtype = "float";
																t->gScope = gScope;
																gtype = "float";
																t-> tag = "TYPE";
																$$ = t;
															}
														
void :				VOID 
															{
																gtype = "void";
															}

var_list :			var_list COMMA var 
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "VARLIST";
																t->dtype = gtype;
																(t->children).pb($1);
																(t->children).pb($3);
																$$ = t;
															}		
					| var 
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "VARLIST";
																t->dtype = gtype;
																(t->children).pb($1);
																$$ = t;
															}	

var : 				id
															{
																ptr * t = new ptr;
																t->tag = "VAR";
																t->dtype = gtype;
																t->gScope = gScope;
																t->svalue = gid;
																(t->children).pb($1);
																$$ = t;

																if( SymTable[gScope].find(gid)==SymTable[gScope].end() ){
																	if(gScope==2 && gparams.size()!=0 && SymTable[1].find(gid)!=SymTable[1].end() ){
																		cout << "Semantic Error : Redecleration of param as variable " << gid << " in line no. " << yylineno<< endl;
																		semanticERROR = 1;
																	}
																	else{
																		variable * v = new variable;
																		v->array = 0;
																		v->name = gid;
																		v->dtype = gtype;
																		v->scope = gScope;
																		SymTable[gScope][gid] = v;
																		gid = "";
																		gvar = v;
																	}
																}else{
																	cout <<  "Semantic Error : Multiple declarations of Variable : " << gid << " in line no. " << yylineno<< endl;
																	semanticERROR = 1;
																}
																// SymTablePrint();
															}	

					| id br_list	
															{
																ptr * t = new ptr;
																t->tag = "VARARRAY";
																t->dtype = gtype;
																t->gScope = gScope;
																t->svalue = gid;
																(t->children).pb($1);
																(t->children).pb($2);
																$$ = t;

																if(SymTable[gScope].find(gid)==SymTable[gScope].end()){
																	if(gScope==2 && gparams.size()!=0 && SymTable[1].find(gid)!=SymTable[1].end() ){
																		cout << "Semantic Error : Redecleration of param as var " << gid << " in line no. " << yylineno<< endl;
																		semanticERROR = 1;
																	}
																	else{
																		variable * v = new variable;
																		v->array = 1;
																		v->name = gid;
																		v->dtype = gtype;
																		v->dim = gdimv;
																		t->dimptr=gdimv;
																		gdimv = gdimv2d.back();
																		gdimv2d.pop_back();
																		v->scope = gScope;
																		SymTable[gScope][gid] = v;
																		gid = "";
																		gvar = v;
																	}
																}else{
																	cout <<  "Semantic Error : Multiple declarations of Variable : " << gid << " in line no. " << yylineno<< endl;
																	semanticERROR = 1;
																} 
																//SymTablePrint();
															}		
id: 				ID 
															{
																ptr * t = new ptr;
																t->tag = "ID";
																t->dtype = gtype;
																t->svalue = yylval.stringVal;
																gid = yylval.stringVal;
																int scp = findScope(gid);

																if(scp==-1)
																{
																	t->gScope = gScope;
																}
																else
																{
																	t->dtype = SymTable[scp][t->svalue]->dtype;
																	t->gScope = scp;
																}
																$$ = t;
															}		

br_list : 			LBP intg RBP   		
															{
																ptr * t = new ptr;
																t->tag = "BRLIST";
																t->gScope = gScope;
																(t->children).pb($2);
																gdimv2d.pb(gdimv);
																gdimv.clear();
																gdimv.pb(($2)->value);
																$$ = t;
															}
					| br_list LBP intg RBP 
															{
																ptr * t = new ptr;
																t->tag = "BRLIST";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($3);
																gdimv.pb(($3)->value);
																$$ = t;
															}


br_list1 : 			LBP exp_type_1 RBP   		
															{
																ptr * t = new ptr;
																t->tag = "BRLIST1";
																t->gScope = gScope;
																(t->children).pb($2);
																t->value=1;
																gdimv2d.pb(gdimv);
																gdimv.clear();
																gdimv.pb(($2)->value);
																$$ = t;
															}
					| br_list1 LBP exp_type_1 RBP 
															{
																ptr * t = new ptr;
																t->tag = "BRLIST1";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($3);
																t->value=$1->value+1;
																gdimv.pb(($3)->value);
																$$ = t;
															}


func_decl : 		type id lbf decl_plist RB 
													{
														if(FuncTable.find($2->svalue)==FuncTable.end()  )
														{
															func * f  = new func;
															f->numparam = gparams.size();
															f->returntype = $1->dtype;
															f->params = gparams;
															f->name = $2->svalue;
															FuncTable[$2->svalue] = f;
														}
														else{
															cout << "Semantic Error : Multiple functions have the same name" << $2->svalue << "in lineno. "<< yylineno<< endl;
															semanticERROR = 1;
														}		
														gparams.clear();
													}
					lcf body rcf func_end
															{
																ptr * t = new ptr;
																t->tag = "FUNCDECL";
																(t->children).pb($1);
																(t->children).pb($2);
																(t->children).pb($3);
																(t->children).pb($4);
																(t->children).pb($7);
																(t->children).pb($8);
																(t->children).pb($9);
																(t->children).pb($10);
																t->gScope = gScope;
																t->svalue = $2->svalue;
																$$ = t;
																funcList.pb(t);
															}

					| void id lbf decl_plist RB
													{
														if(FuncTable.find($2->svalue)==FuncTable.end()  )
														{
															func * f  = new func;
															f->numparam = gparams.size();
															f->returntype = "void";
															f->params = gparams;
															f->name = $2->svalue;
															FuncTable[$2->svalue] = f;
														}
														else{
															cout << "Semantic Error : Multiple functions have the same name" << $2->svalue << "in lineno. "<< yylineno<< endl;
															semanticERROR = 1;
														}	
														gparams.clear();
													} 
						lcf body rcf func_end
															{ 
																ptr * t = new ptr;
																t->tag = "FUNCDECL";
																t->gScope = gScope;
																(t->children).pb($2);
																(t->children).pb($3);
																(t->children).pb($4);
																(t->children).pb($7);
																(t->children).pb($8);
																(t->children).pb($9);
																(t->children).pb($10);
																t->svalue = $2->svalue;
																$$ = t;
																funcList.pb(t);
															}

lbf : 				LB										{
																ptr * t = new ptr;
																t->tag = "LBF";
																t->gScope = gScope;
																$$ = t;
																gScope++;
																map< string , variable* > mp;
																SymTable.push_back(mp);
															}


lcf :				LC          
															{
																ptr * t = new ptr;
																t->tag = "LCF";
																t->gScope = gScope;
																$$ = t;
																gScope++;

																map< string , variable* > mp;
																SymTable.push_back(mp);
															}

rcf :				RC
															{
																ptr * t = new ptr;
																t->tag = "RCF";
																t->gScope = gScope;
																$$ = t;
																gScope--;
																SymTable.pop_back();
															}

														

func_end :													{
																ptr * t = new ptr;
																t->tag = "FUNCEND";
																t->gScope = gScope;
																$$ = t;
																gScope--;
																SymTable.pop_back();
															}

decl_plist :		{activeFunc = gid; returnType = gtype; } decl_pl 					
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "DECLPLIST";
																(t->children).pb($2);
																$$ = t;
															}
					| 	
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "DECLPLIST";
																$$ = t;
																activeFunc = gid;
																returnType = gtype;
															}

decl_pl :			decl_param COMMA decl_pl 				
															{
																ptr * t = new ptr;
																t->tag = "DECLPL";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($3);
																$$ = t;
															}
	
					| decl_param							
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "DECLPL";
																(t->children).pb($1);
																$$ = t;
															}

decl_param : 		type var 								{
																ptr * t = new ptr;
																t->tag = "DECLPARAM";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																gparams.push_back(gvar);
																$$ = t;
															}

body:				stmts									
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "BODY";
																(t->children).pb($1);
																$$ = t;
															}
					| 										
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "BODY";
																$$ = t;
															}

stmts :				stmt stmts								
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "STMTS";
																(t->children).pb($1);
																(t->children).pb($2);
																$$ = t;
															}
					| stmt 									
															{
																ptr * t = new ptr;
																t->tag = "STMTS";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}

stmt:				var_decl 								
															{
																ptr * t = new ptr;																
																t->tag = "STMTVARDECL";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}
					| exp semi 								
															{
																ptr * t = new ptr;																
																t->tag = "STMTEXP";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}
					| exp_type_1 semi 								
															{
																ptr * t = new ptr;																
																t->tag = "STMTEXP";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}		

					| FOR LB exp semi for_exp semi for_exp RB lcf body rcf 
															{
																ptr * t = new ptr;																
																t->tag = "FOREXP";
																t->gScope = gScope;
																(t->children).pb($3);
																(t->children).pb($5);
																(t->children).pb($7);
																(t->children).pb($9);
																(t->children).pb($10);
																(t->children).pb($11);
																$$ = t;
															}
					| WHILE LB exp_type_1 RB lcf body rcf 			
															{
																ptr * t = new ptr;
																t->tag = "WHILEEXP";
																t->gScope = gScope;
																(t->children).pb($3);
																(t->children).pb($5);
																(t->children).pb($6);
																(t->children).pb($7);
																$$ = t;
															}
					| IF LB exp_type_1 RB lcf body rcf ELSE lcf body rcf 
															{
																ptr * t = new ptr;
																t->tag = "IFELSEEXP";
																t->gScope = gScope;
																(t->children).pb($3);
																(t->children).pb($5);
																(t->children).pb($6);
																(t->children).pb($7);
																(t->children).pb($9);
																(t->children).pb($10);
																(t->children).pb($11);
																$$ = t;
															}
					| IF LB exp_type_1 RB lcf body rcf 				
															{
																ptr * t = new ptr;
																t->tag = "IFEXP";
																t->gScope = gScope;
																(t->children).pb($3);
																(t->children).pb($5);
																(t->children).pb($6);
																(t->children).pb($7);
																$$ = t;
															}
					| SWITCH LB exp_type_1 RB LC case_exp default_exp RC 
															{
																ptr * t = new ptr;
																t->tag = "SWITCHEXP";
																t->gScope = gScope;
																(t->children).pb($3);
																(t->children).pb($6);
																(t->children).pb($7);
																$$ = t;	
															}
					| continue semi					
															{
																ptr * t = new ptr;
																t->tag = "CONTINUEEXP";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
																
															}															
					| break semi 							
															{
																ptr * t = new ptr;
																t->tag = "STMTBREAK";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}
					| return_exp semi                       
															{
																ptr * t = new ptr;
																t->tag = "STMTRETURN";
																t->gScope = gScope;
																(t->children).pb($1);
																if(returnType!=($1->dtype)){
																	cout<<"Semantic Error : Return type does not match function return type in line no. "<<yylineno<<"\n";
																}
																$$ = t;	
															}
					| lcf body rcf 							
															{
																ptr * t = new ptr;
																t->tag = "STMTBODY";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																(t->children).pb($3);
																$$ = t;	
															}
					| PRINT LB args1 RB	semi     			{
																ptr * t = new ptr;
																t->tag = "PRINTEXP";
																t->gScope = gScope;
																(t->children).pb($3);
																$$ = t;	
															}
					| READ LB args RB semi	     			{
																ptr * t = new ptr;
																t->tag = "READEXP";
																t->gScope = gScope;
																(t->children).pb($3);
																$$ = t;	
															}
					| error	SEMI							{yyerrok; syntaxERROR = 1;}
					| error RC								{yyerrok; syntaxERROR = 1;}

for_exp:			exp_type_1 								
															{
																ptr * t = new ptr;
																t->tag = "FOREXPERR";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;	
															}	
					|
															
															{
																ptr * t = new ptr;
																t->tag = "FOREXPERR";
																t->gScope = gScope;
																$$ = t;		
															}		

semi: 				SEMI										{}
					|	error SEMI									{yyerrok; syntaxERROR = 1;}


args1 	:  	args_list1 								
															{
																ptr * t = new ptr;
																t->tag = "ARGS1";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}
		| 													
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "ARGS1";
																$$ = t;
															}
		;

args_list1	:	args_list1 COMMA arith_exp_type_1 			
															{
																ptr * t = new ptr;
																t->tag = "ARGSLIST1";
																t->svalue = "1";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($3);
																$$ = t;
															}
			|	arith_exp_type_1 							
															{
																ptr * t = new ptr;
																t->tag = "ARGSLIST1";
																t->svalue = "2";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}
			| args_list1 COMMA string 			
															{
																ptr * t = new ptr;
																t->tag = "ARGSLIST1";
																t->svalue = "3";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($3);
																$$ = t;
															}
			|	string 							
															{
																ptr * t = new ptr;
																t->tag = "ARGSLIST1";
																t->svalue = "4";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}

string : 		STRING                              {
														ptr * t = new ptr;
														t->tag = "STRING";
														t->gScope = gScope;
														t->svalue = yylval.stringVal;
														$$ = t;
													}

break:				BREAK										
															{
																ptr * t = new ptr;
																t->tag = "BREAK";
																t->gScope = gScope;
																$$ = t;
															}

continue:		CONTINUE									
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "CONTINUE";
																$$ = t;
															}
case_exp :			CASE LB arith_exp_type_1 RB COLON lcf stmts rcf case_exp 
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "CASEEXP";
																(t->children).pb($3);
																(t->children).pb($6);
																(t->children).pb($7);
																(t->children).pb($8);
																(t->children).pb($9);
																$$ = t;
															}
					| 										
															{
																ptr * t = new ptr;

																t->gScope = gScope;
																t->tag = "CASEEXP";
																$$ = t;
															}

default_exp : 		DEFAULT COLON lcf stmts rcf 
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "DEFAULTEXP";
																(t->children).pb($3);
																(t->children).pb($4);
																(t->children).pb($5);
																$$ = t;
															} 
					|										
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "DEFAULTEXP";
																$$ = t;
															}

return_exp 	: 		RETURN 									
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "RETURN";
																t->dtype = "void";
																$$ = t;
															}
					| 	RETURN exp_type_1 							
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "RETURN";
																(t->children).pb($2);
																t->dtype = ($2->dtype);
																$$ = t;
															}
					;


exp :			id EQUAL exp_type_1							
															{ 
																int scp = findScope($1->svalue);
																
																if(scp==-1)
																{
																	cout << "Semantic Error : Variable "<< $1->svalue <<" is not declared in lineno. "<< yylineno << endl;
																	semanticERROR = 1;
																}									
																else{
																	if(SymTable[scp][$1->svalue]->dtype=="int" && $3->dtype=="float" )
																	{
																		cout << "Semantic Error : Invalid data type assignment in lineno. " << yylineno << endl;
																		semanticERROR = 1; 
																	}
																}						
																
																ptr * t = new ptr;
																t->tag = "EXP";
																t->gScope = scp;
																(t->children).pb($1);
																(t->children).pb($3);
																$$ = t;	
														    }

				| id br_list1 EQUAL exp_type_1 
							                                {
																ptr * t = new ptr;
																int scp = findScope($1->svalue);
																if(scp == -1){
																	cout<<"Semantic Error : Array not declared in lineno. "<< yylineno << endl;
																	semanticERROR = 1;					
																}
																else{
																	if(!SymTable[scp][$1->svalue]->array)
																	{
																		cout << "Semantic Error : Variable is not of array type in lineno. " << yylineno << endl;
																		semanticERROR = 1;
																	}
																	else if(SymTable[scp][$1->svalue]->dtype=="int" && $4->dtype=="float" ){
																		cout << "Semantic Error : Invalid data type assignment in lineno. " << yylineno << endl;
																		semanticERROR = 1;
																	}else if($2->value!=SymTable[scp][$1->svalue]->dim.size()){
																		cout<< "Semantic Error : Invalid dimensions of array " << $1->svalue << " in lineno " << yylineno <<  endl;
																		semanticERROR = 1;																		
																	}
																	else if(checkOutofBound(SymTable[scp][$1->svalue]->dim))
																	{
																		cout << "Semantic Error : Out Of Bound array " << $1->svalue << " in lineno. " << yylineno << endl;
																	}
																	else{
																		t->dimptrorg = SymTable[scp][$1->svalue]->dim;																		
																		t->dtype = SymTable[scp][$1->svalue]->dtype;
																	}
																}
																t->tag = "EXP";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																(t->children).pb($4);t->dimptr=gdimv;
																		gdimv = gdimv2d.back();
																		gdimv2d.pop_back();
																$$ = t;
															}

exp_type_1 	:		exp_type_1 OR exp_type_2 				
															{
																ptr * t = new ptr;
																t->tag = "EXPTYPE1";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($3);
																t->dtype = decideintfloat($1->dtype , $3->dtype);
																t->value = 0;
																$$ = t;
															}
					| 	exp_type_2 
															{
																ptr * t = new ptr;
																t->tag = "EXPTYPE1";
																t->gScope = gScope;
																(t->children).pb($1);
																t->dtype = $1->dtype;
																t->value = $1->value;
																$$ = t;
															}
								

exp_type_2 	:	exp_type_2 AND exp_type_3 					{
																ptr * t = new ptr;
																t->tag = "EXPTYPE2";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($3);
																t->dtype = decideintfloat($1->dtype , $3->dtype);
																t->value = 0;
																$$ = t;
															}
				|	exp_type_3 								
															{
																ptr * t = new ptr;
																t->tag = "EXPTYPE2";
																t->gScope = gScope;
																(t->children).pb($1);
																t->dtype = $1->dtype;
																t->value = $1->value;
																$$ = t;
															}
				;

exp_type_3 	:			exp_type_3 relation_op arith_exp_type_1 
															{

																ptr * t = new ptr;
																t->tag = "EXPTYPE3";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																(t->children).pb($3);
																t->dtype = decideintfloat($1->dtype , $3->dtype);
																if($1->dtype!="int" || $3->dtype!="int"){
																	cout<<"Semantic Error : Relation operator used with non-integer type in lineno. "<< yylineno <<endl;
																	semanticERROR=1;
																}
																t->value = 0;
																$$ = t;
																
															}
						|	arith_exp_type_1 				
															{
																ptr * t = new ptr;
																t->tag = "EXPTYPE3";
																t->gScope = gScope;
																(t->children).pb($1);
																t->dtype = $1->dtype;
																t->value = $1->value;
																$$ = t;
															}
						;

arith_exp_type_1 	:	arith_exp_type_1 plus_minus_op arith_exp_type_2 
															{
																ptr * t = new ptr;
																t->tag = "ARITHEXPTYPE1";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																(t->children).pb($3);
																t->dtype = decideintfloat($1->dtype , $3->dtype);
																t->value = 0;
																$$ = t;
															}
					|	arith_exp_type_2 				
															{
																ptr * t = new ptr;
																t->tag = "ARITHEXPTYPE1";
																t->gScope = gScope;
																(t->children).pb($1);
																t->dtype = $1->dtype;
																t->value = $1->value;
																$$ = t;
															}
					;

arith_exp_type_2 	: 	arith_exp_type_2 mul_div_op unary_exp 
															{
																ptr * t = new ptr;
																t->tag = "ARITHEXPTYPE2";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																(t->children).pb($3);
																t->dtype = decideintfloat($1->dtype , $3->dtype) ;
																t->value = 0;
																$$ = t;	
															}
					| 	unary_exp 							
															{
																ptr * t = new ptr;
																t->tag = "ARITHEXPTYPE2";
																t->gScope = gScope;
																(t->children).pb($1);
																t->dtype = $1->dtype;
																t->value = $1->value;
																$$ = t;
															}
					;

unary_exp 	: 	unary_operator term 		
															{
																ptr * t = new ptr;
																t->tag = "UNARYEXP";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																t->dtype = $2->dtype;
																t->value = 0;
																$$ = t;
															}
					
					| 	term 
															{
																ptr * t = new ptr;
																t->tag = "UNARYEXP";
																t->gScope = gScope;
																(t->children).pb($1);
																t->dtype = $1->dtype;
																t->value = $1->value;
																$$ = t;
															}
					;

term 	:	LB exp_type_1 RB 										
															{
																ptr * t = new ptr;
																t->tag = "TERM";
																t->gScope = gScope;
																(t->children).pb($2);
																t->value = $2->value;
																t->dtype = $2->dtype;
																$$ = t;
															}
		| 	func_call 										
															{
																ptr * t = new ptr;
																t->tag = "TERM";
																t->gScope = gScope;
																(t->children).pb($1);
																t->dtype = $1->dtype;
																t->value = 0;
																$$ = t;
															}
		|	consts 											
															{
																ptr * t = new ptr;
																t->tag = "TERM";
																t->gScope = gScope;
																t->dtype = $1->dtype;
																t->value = $1->value;
																(t->children).pb($1);
																$$ = t;
															}
		|	id 									
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																int scp = findScope(gid);
																
																if(scp==-1)
																{
																	cout << "Semantic Error : Variable "<<$1->svalue<< " is not declared in lineno. " << yylineno << endl;
																	semanticERROR = 1;
																}									
																else{
																	t->dtype = SymTable[scp][gid]->dtype;
																}				

																t->tag = "TERM";
																(t->children).pb($1);
																t->value = 0;
																$$ = t;
															}
		|   id br_list1
															{
																ptr * t = new ptr;
																int scp = findScope($1->svalue);
																if(scp == -1){; 
																	cout<<"Semantic Error : Array "<<$1->svalue<< " not declared in line no." << yylineno <<endl;
																	semanticERROR = 1;					
																}
																else{
																	if(!SymTable[scp][$1->svalue]->array){
																		cout << "Semantic Error : Variable is not of array type in lineno. " << yylineno << endl;
																		semanticERROR = 1;
																	}else if($2->value!=SymTable[scp][$1->svalue]->dim.size()){
																		cout << "Semantic Error : Invalid dimension of array " << $1->svalue << " in lineno. " << yylineno << endl;
																		semanticERROR = 1;																		
																	}
																	else if(checkOutofBound(SymTable[scp][$1->svalue]->dim))
																	{
																		cout << "Semantic Error : Out Of Bound array " << $1->svalue << " in lineno. " << yylineno << endl;
																	}
																	else{
																		t->dimptrorg = SymTable[scp][$1->svalue]->dim;
																		t->dtype = SymTable[scp][$1->svalue]->dtype;
																	}
																}
																t->tag = "TERM";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($2);
																t->dimptr=gdimv;
																gdimv = gdimv2d.back();
																gdimv2d.pop_back();
																t->value = 0;
																$$ = t;												
															}

		
		;

func_call 	:	id LB args RB 		
															{
																ptr * t = new ptr;
																t->tag = "FUNCCALL";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($3);

																if(FuncTable.find($1->svalue)==FuncTable.end())
																{
																	cout << "Semantic Error : " << $1->svalue << " function is not declared in lineno. " << yylineno << endl;
																	semanticERROR =1;
																}
																else{
																	func * f = FuncTable[$1->svalue];
																	t->dtype = f->returntype;
																	if(f->numparam == gfcallparam2d.back().size() )
																	{
																		for(int j = 0 ; j< f->numparam ; j++ )
																		{
																			if(f->params[j]->dtype != gfcallparam2d.back()[j])
																			{
																				cout << "Semantic Error : Datatype mismatched in parameters in line no. " << yylineno << endl;
																				semanticERROR = 1;
																			}
																		}
																	}
																	else{
																		cout << "Semantic Error : No. of parameters not matched in line no. " << yylineno << endl;
																		semanticERROR = 1;
																	}
																}
																gfcallparam2d.pop_back();
																$$ = t;
															}
				;

args 	:  	args_list 								
															{
																ptr * t = new ptr;
																t->tag = "ARGS";
																t->gScope = gScope;
																(t->children).pb($1);
																$$ = t;
															}
		| 													
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "ARGS";
																gfcallparam.clear();
																gfcallparam2d.pb(gfcallparam);
																$$ = t;
															}
		;

args_list	:	args_list COMMA arith_exp_type_1 			
															{
																ptr * t = new ptr;
																t->tag = "ARGSLIST";
																t->gScope = gScope;
																(t->children).pb($1);
																(t->children).pb($3);
																gfcallparam2d.back().pb($3->dtype);
																$$ = t;
															}
			|	arith_exp_type_1 							
															{
																ptr * t = new ptr;
																t->tag = "ARGSLIST";
																t->gScope = gScope;
																(t->children).pb($1);
																gfcallparam.clear();
																gfcallparam2d.pb(gfcallparam);
																gfcallparam2d.back().pb($1->dtype);
																$$ = t;
															}

consts 	:	 intg 												
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "CONSTS";
																(t->children).pb($1);
																t->dtype = "int";
																t->value = $1->value;
																$$ = t;
															}
			| floats 						
															{
																ptr * t = new ptr;
																t->gScope = gScope;
																t->tag = "CONSTS";
																(t->children).pb($1);
																t->dtype = "float";
																t->value = $1->value;
																$$ = t;
															}
			
intg  :   INTEGERS		
												{    
													ptr * t = new ptr;
													t->gScope = gScope;
													t->tag = "INTG";
													t->value = stof( yylval.stringVal );
													t->dtype = "int";
													$$ = t;
												}

		 	| SUB INTEGERS		
												{    
													ptr * t = new ptr;
													t->gScope = gScope;
													t->tag = "INTG";
													t->value = -1*stof( yylval.stringVal );
													t->dtype = "int";
													$$ = t;
												}
				
floats  :  	FLOATING_POINTS 
												{
													ptr * t = new ptr;
													t->gScope = gScope;
													t->tag = "FLOATS";
													t->dtype ="float";
													t->value = stof( yylval.stringVal );
													$$ = t;    
												}
			| 	SUB FLOATING_POINTS 
												{
													ptr * t = new ptr;
													t->gScope = gScope;
													t->tag = "FLOATS";
													t->dtype ="float";
													t->value = -1*stof( yylval.stringVal );
													$$ = t;    
												}
										

plus_minus_op 	: 	ADD 		
												{
														ptr * t = new ptr;
														t->gScope = gScope;
														t->tag = "PLUSMINUSOP";
														t->svalue = "+";
														$$ = t;	
												}
			| 	SUB 							
												{
													ptr * t = new ptr;
													t->gScope = gScope;
													t->tag = "PLUSMINUSOP";
													t->svalue = "-";
													$$ = t;
												}
			;

mul_div_op 	: 	MUL 				
												{
													ptr * t = new ptr;
													t->gScope = gScope;
													t->tag = "MULDIVOP";
													t->svalue = "*";
													$$ = t;
												}
			| 	DIV 
												{
													ptr * t = new ptr;
													t->gScope = gScope;
													t->tag = "MULDIVOP";
													t->svalue = "/";
													$$ = t;
												}
			;

relation_op 	: 	GT 	
												{
													ptr * t = new ptr;
													t->gScope = gScope;
													t->tag = "RELATIONOP";
													t->svalue =">";
													$$ = t;
												}
			| 	LT 
												{
													ptr * t = new ptr;
													t->svalue = "<";
													t->gScope = gScope;
													t->tag = "RELATIONOP";
													$$ = t;
												}
			| 	GE 
												{
													ptr * t = new ptr;
													t->svalue = ">=";
													t->gScope = gScope;
													t->tag = "RELATIONOP";
													$$ = t;
												}
			| 	LE 
												{
													ptr * t = new ptr;
													t->svalue = "<=";
													t->gScope = gScope;
													t->tag = "RELATIONOP";
													$$ = t;
												}
			| 	EQ 
												{
													ptr * t = new ptr;
													t->svalue = "==";
													t->gScope = gScope;
													t->tag = "RELATIONOP";
													$$ = t;
												}
			| 	NE 
												{
													ptr * t = new ptr;
													t->svalue = "!=";
													t->gScope = gScope;
													t->tag = "RELATIONOP";
													$$ = t;
												}
			;

unary_operator 	:	SUB SUB 
												{
													ptr * t = new ptr;
													t->gScope = gScope;
													t->tag = "UNARYOPERATOR";
													t->svalue = "--";
													$$ = t;
												}
				|	ADD ADD 
												{
													ptr * t = new ptr;
													t->gScope = gScope;
													t->tag = "UNARYOPERATOR";
													t->svalue = "++";
													$$ = t;
												}

%%

void printSpace(int cnt)
{
	for(int i=0;i<cnt;i++) cout<<"\t";
}

void PrintTree(ptr *n,int cnt)
{
	printSpace(cnt);
	if(n==NULL){
		return;
	}
	cout << n->tag << endl;
	for (int i = 0; i < (n->children).size(); ++i)
	{
		PrintTree((n->children)[i],cnt+1);
	}
}

string decideintfloat(string s1,string s2){
	if( s1 == "float" || s2 == "float"){
		return "float";
	}
	else{
		return "int";
	}
}

int checkOutofBound(vector<int> v){

	int n=gdimv.size();
	for(int i=0;i<n;i++){
		if(gdimv[i]>=v[i]){
			return i+1;
		}
	}
	return 0;
}

void SymTablePrint()
{
	cout << "Sym Table" << endl;
	for(int g = 0; g < SymTable.size(); g++ )
	{
		for(auto i : SymTable[g])
		{
			cout << g << "\t\t" << i.first << "\t\t" << i.second->dtype << "\t\t";

			if(i.second->array)
			{
				cout << "array\t\t" ;
				for(int i1 = 0; i1 < i.second->dim.size(); i1++ )
					cout << i.second->dim[i1] << " ";
				cout << endl;
			}
			else{
				cout << "single\t\t" << endl ;
			}
		}
	}
}

int findScope(string gid){
	for(int i=gScope;i>=0;i--){
		if(SymTable[i].find(gid)!=SymTable[i].end()){
			return i;
		}
	}
	return -1;
}

int temp = -1;

string getTemp(){
	temp++;
	string t = "temp_";
	t += to_string(temp);
	return t;
}

int label = -1;

string getLabel(){
	label++;
	string l = "label_";
	l += to_string(label);
	return l;
}

string generateCode(ptr * root){
	vector<ptr*> v = root->children;
	if(root->tag=="VARDECL"){
		if(root->children.size()==3){
			string val1 = generateCode(v[2]);
			fprintf(f, "%s.%s.%d%s = %s.%s\n", v[0]->dtype.c_str(), v[1]->svalue.c_str(), v[1]->gScope, currFunc.c_str(),  v[2]->dtype.c_str(), val1.c_str());
			fprintf(q, " , %s.%s , , %s.%s.%d%s\n", v[2]->dtype.c_str(), val1.c_str(), v[0]->dtype.c_str(), v[1]->svalue.c_str(), v[1]->gScope, currFunc.c_str());

		}
		else{
			string val1 = generateCode(v[1]);
		}
	}else if(root->tag=="VARLIST"){
		if(root->children.size()==2){
			string val1 = generateCode(v[1]);
		}
		else{
			string val1 = generateCode(v[0]);
		}
	}else if(root->tag=="EXP"){
		if(v.size()==2)
		{
			string val1 = generateCode(v[1]);
			if(v[0]->gScope>=1){
				fprintf(f, "%s.%s.%d%s = %s.%s\n", v[0]->dtype.c_str(), v[0]->svalue.c_str(), v[0]->gScope, currFunc.c_str(), v[1]->dtype.c_str(), val1.c_str());
				fprintf(q, " , %s.%s , , %s.%s.%d%s\n", v[1]->dtype.c_str(), val1.c_str(), v[0]->dtype.c_str(), v[0]->svalue.c_str(), v[0]->gScope, currFunc.c_str());
			}
			else{
				fprintf(f, "%s.%s.%d = %s.%s\n", v[0]->dtype.c_str(), v[0]->svalue.c_str(), v[0]->gScope, v[1]->dtype.c_str(), val1.c_str());
				fprintf(q, " , %s.%s , , %s.%s.%d\n", v[1]->dtype.c_str(), val1.c_str(), v[0]->dtype.c_str(), v[0]->svalue.c_str(), v[0]->gScope);
			}
		}
		else{
			string t = v[0]->svalue;
			vector<int> dimptrorg = root->dimptrorg;
			string val1 = generateCode(v[2]);
			vector<string> str;
			brlist.pb(str);
			generateCode(v[1]);
			vector<string> list = brlist.back(); 
			brlist.pop_back();
			string var1 = getTemp();
			fprintf(f, "int.%s = int.%s\n", var1.c_str(), list[0].c_str());
			fprintf(q, " , int.%s , , int.%s\n", list[0].c_str(), var1.c_str());
			for(int i=0;i<list.size()-1;i++){
				fprintf(f, "int.%s = int.%s * %d\n", var1.c_str(), var1.c_str(), dimptrorg[i+1]);
				fprintf(q, " * , int.%s , %d , int.%s\n", var1.c_str(), dimptrorg[i+1], var1.c_str());

				fprintf(f, "int.%s = int.%s + int.%s\n", var1.c_str(), var1.c_str(), list[i+1].c_str());
				fprintf(q, " + , int.%s , int.%s , int.%s\n", var1.c_str(), list[i+1].c_str(), var1.c_str());

			}
			if(v[0]->gScope>=1)	{
				fprintf(f, "%s.%s.%d%s(int.%s) = %s.%s\n", root->dtype.c_str(), t.c_str(), v[0]->gScope, currFunc.c_str(), var1.c_str(), v[2]->dtype.c_str(), val1.c_str());
				fprintf(q, " , %s.%s , , %s.%s.%d%s(int.%s)\n", v[2]->dtype.c_str(), val1.c_str(), root->dtype.c_str(), t.c_str(), v[0]->gScope, currFunc.c_str(), var1.c_str());
			}else{
				fprintf(f, "%s.%s.%d(int.%s) = %s.%s\n", root->dtype.c_str(), t.c_str(), v[0]->gScope, var1.c_str(), v[2]->dtype.c_str(), val1.c_str());
				fprintf(q, " , %s.%s , , %s.%s.%d(int.%s)\n", v[2]->dtype.c_str(), val1.c_str(), root->dtype.c_str(), t.c_str(), v[0]->gScope, var1.c_str());
			}
		}
	}else if(root->tag=="BRLIST1"){
		if(v.size()==1){
			string t = generateCode(v[0]);
			brlist.back().pb(t);
		}else{
			generateCode(v[0]);
			string t = generateCode(v[1]);
			brlist.back().pb(t);
		}
	}else if(root->tag=="EXPTYPE1"){
		if(v.size()==1)
			return generateCode(v[0]);	
		else{
			string var1 = generateCode(v[0]);
			string l1 = getLabel();
			string l2 = getLabel();
			string l3 = getLabel();
			string l4 = getLabel();
			string t = getTemp();
			fprintf(f, "int.%s = %s.%s <= 0\n", t.c_str(), v[0]->dtype.c_str(), var1.c_str());
			fprintf(q, " <= , %s.%s , 0 , int.%s\n", v[0]->dtype.c_str(), var1.c_str(), t.c_str());

			fprintf(f, "if int.%s goto %s\n", t.c_str(), l1.c_str());
			fprintf(q, " if , int.%s , %s , goto\n", t.c_str(), l1.c_str());

			fprintf(f, "goto %s\n", l2.c_str());
			fprintf(q, " , %s , , goto\n", l2.c_str());

			fprintf(f, "%s:\n", l1.c_str());
			fprintf(q, "%s:\n", l1.c_str());

			string var2 = generateCode(v[1]);
			string t1 = getTemp();
			fprintf(f, "int.%s = %s.%s <= 0\n", t1.c_str(), v[1]->dtype.c_str(), var2.c_str());
			fprintf(q, " <= , %s.%s , 0 , int.%s\n", v[1]->dtype.c_str(), var2.c_str(), t1.c_str());

			fprintf(f, "if int.%s goto %s\n", t1.c_str(), l3.c_str());
			fprintf(q, "if , int.%s , %s , goto\n", t1.c_str(), l3.c_str());

			fprintf(f, "goto %s\n", l2.c_str());
			fprintf(q, " , %s , , goto\n", l2.c_str());

			fprintf(f, "%s:\n", l3.c_str());
			fprintf(q, "%s:\n", l3.c_str());

			fprintf(f, "int.%s = 0\n", t.c_str());
			fprintf(q, " , 0 , , int.%s\n", t.c_str());

			fprintf(f, "goto %s\n", l4.c_str());
			fprintf(q, " , %s , , goto\n", l4.c_str());

			fprintf(f, "%s:\n", l2.c_str());
			fprintf(q, "%s:\n", l2.c_str());

			fprintf(f, "int.%s = 1\n", t.c_str());
			fprintf(q, " , 1 , , int.%s\n", t.c_str());

			fprintf(f, "%s:\n", l4.c_str());
			fprintf(q, "%s:\n", l4.c_str());

			return t;
		}

	}else if(root->tag=="EXPTYPE2"){
		if(v.size()==1)
			return generateCode(v[0]);	
		else{
			string var1 = generateCode(v[0]);
			string l1 = getLabel();
			string l2 = getLabel();
			string l3 = getLabel();
			string l4 = getLabel();
			string t = getTemp();
			fprintf(f, "int.%s = %s.%s > 0\n", t.c_str(), v[0]->dtype.c_str(), var1.c_str());
			fprintf(q, " > , %s.%s , 0 , int.%s\n", v[0]->dtype.c_str(), var1.c_str(), t.c_str());

			fprintf(f, "if int.%s goto %s\n", t.c_str(), l1.c_str());
			fprintf(q, " if , int.%s , %s , goto\n", t.c_str(), l1.c_str());

			fprintf(f, "goto %s\n", l2.c_str());
			fprintf(q, " , %s , , goto\n", l2.c_str());

			fprintf(f, "%s:\n", l1.c_str());
			fprintf(q, "%s:\n", l1.c_str());

			string var2 = generateCode(v[1]);
			string t1 = getTemp();
			fprintf(f, "int.%s = %s.%s > 0\n", t1.c_str(), v[1]->dtype.c_str(), var2.c_str());
			fprintf(q, " > , %s.%s , 0 , int.%s\n", v[1]->dtype.c_str(), var2.c_str(), t1.c_str());

			fprintf(f, "if int.%s goto %s\n", t1.c_str(), l3.c_str());
			fprintf(q, " if , int.%s , %s , goto\n", t1.c_str(), l3.c_str());

			fprintf(f, "goto %s\n", l2.c_str());
			fprintf(q, " , %s , , goto\n", l2.c_str());

			fprintf(f, "%s:\n", l3.c_str());
			fprintf(q, "%s:\n", l3.c_str());

			fprintf(f, "int.%s = 1\n", t.c_str());
			fprintf(q, " , 1 , , int.%s\n", t.c_str());

			fprintf(f, "goto %s\n", l4.c_str());
			fprintf(q, " , %s , , goto\n", l4.c_str());

			fprintf(f, "%s:\n", l2.c_str());
			fprintf(q, "%s:\n", l2.c_str());

			fprintf(f, "int.%s = 0\n", t.c_str());
			fprintf(q, " , 0 , , int.%s\n", t.c_str());

			fprintf(f, "%s:\n", l4.c_str());
			fprintf(q, "%s:\n", l4.c_str());

			return t;
		}									
	}else if(root->tag=="EXPTYPE3" || root->tag=="ARITHEXPTYPE1" || root->tag=="ARITHEXPTYPE2"){
		if(v.size()==1){
			return generateCode(v[0]);
		}
		string var1 = getTemp();
		string val1 = generateCode(v[0]);
		string val2 = generateCode(v[2]);
		fprintf(f, "%s.%s = %s.%s %s %s.%s\n", root->dtype.c_str(), var1.c_str(), v[0]->dtype.c_str(), val1.c_str(), v[1]->svalue.c_str(), v[2]->dtype.c_str(), val2.c_str());
		fprintf(q, " %s , %s.%s , %s.%s , %s.%s\n", v[1]->svalue.c_str(), v[0]->dtype.c_str(), val1.c_str(), v[2]->dtype.c_str(), val2.c_str(), root->dtype.c_str(), var1.c_str());
		
		return var1;																	
	}else if(root->tag=="UNARYEXP"){
		if(v.size()==1){
			return generateCode(v[0]);			
		}
		string var1 = generateCode(v[1]);				
		if(v[0]->svalue=="++"){
			fprintf(f, "%s.%s = %s.%s + 1\n", v[1]->dtype.c_str(), var1.c_str(), v[1]->dtype.c_str(), var1.c_str() );															
			fprintf(q, " + , %s.%s , 1 , %s.%s\n", v[1]->dtype.c_str(), var1.c_str(), v[1]->dtype.c_str(), var1.c_str());															

		}
		if(v[0]->svalue=="--"){
			fprintf(f, "%s.%s = %s.%s - 1\n", v[1]->dtype.c_str(), var1.c_str(), v[1]->dtype.c_str(), var1.c_str() );
			fprintf(q, " - , %s.%s , 1 , %s.%s\n", v[1]->dtype.c_str(), var1.c_str(),  v[1]->dtype.c_str(), var1.c_str() );

		}
		return var1;		
		
	}else if(root->tag=="TERM" || root->tag=="CONSTS"){
		if(v.size()==1){
			return generateCode(v[0]);
		}		
		else{
			string t = v[0]->svalue;
			vector<int> dimptrorg = root->dimptrorg;
			vector<string> str;
			brlist.pb(str);
			generateCode(v[1]);
			vector<string> list = brlist.back(); 
			brlist.pop_back();
			string var1 = getTemp();
			fprintf(f, "int.%s = int.%s\n", var1.c_str(), list[0].c_str());
			fprintf(q, " , int.%s , , int.%s\n", list[0].c_str(),  var1.c_str());

			for(int i=0;i<list.size()-1;i++){
				fprintf(f, "int.%s = int.%s * %d\n", var1.c_str(), var1.c_str(), dimptrorg[i+1]);
				fprintf(q, " * , int.%s , %d , int.%s\n", var1.c_str(), dimptrorg[i+1], var1.c_str());

				fprintf(f, "int.%s = int.%s + int.%s\n", var1.c_str(), var1.c_str(), list[i+1].c_str());
				fprintf(q, " + , int.%s , int.%s , int.%s\n", var1.c_str(), list[i+1].c_str(), var1.c_str());

			}
			string temp;
			if(v[0]->gScope>=1){
				temp = t + "." + to_string(v[0]->gScope) + currFunc + "(int." + var1 + ")";
			}else{
				temp = t + "." + to_string(v[0]->gScope) + "(int." + var1 + ")";
			}
			//	fprintf(f, "%s.%s = %s.%s.%d%s(int.%s)\n", root->dtype.c_str(), temp.c_str(), root->dtype.c_str(), t.c_str(), v[0]->gScope, currFunc.c_str(), var1.c_str());
			//else{
			//	fprintf(f, "%s.%s = %s.%s.%d(int.%s)\n", root->dtype.c_str(), temp.c_str(),  root->dtype.c_str(), t.c_str(), v[0]->gScope, var1.c_str());
			//}
			return temp;
		}
	}else if(root->tag=="INTG" || root->tag=="FLOATS"){
		string var1 = getTemp();
		if(root->dtype=="int"){
			int a = root->value;
			fprintf(f, "int.%s = %d\n", var1.c_str(), a);
			fprintf(q, " , %d , , int.%s\n", a, var1.c_str());

		}else{
			fprintf(f, "float.%s = %f\n", var1.c_str(), root->value);
			fprintf(q, " , %f , , float.%s\n", root->value, var1.c_str());

		}
		return var1;
	}else if(root->tag=="STMTBREAK" || root->tag=="STMTRETURN" || root->tag=="CONTINUEEXP" || root->tag=="STMTVARDECL" || root->tag=="STMTEXP"){
		return generateCode(v[0]);
	}else if(root->tag=="STMTBODY"){
		return generateCode(v[1]);
	}else if(root->tag=="FOREXP"){
		string init = generateCode(v[0]);
		string l1 = getLabel();
		string l2 = getLabel();
		string l3 = getLabel();
		string l4 = getLabel();
		fprintf(f, "%s:\n", l1.c_str());
		fprintf(q, "%s:\n", l1.c_str());

		string cond = generateCode(v[1]);
		fprintf(f, "if int.%s goto %s\n", cond.c_str(), l2.c_str());
		fprintf(q, "if , int.%s , %s , goto\n", cond.c_str(), l2.c_str());

		fprintf(f, "goto %s\n", l3.c_str());
		fprintf(q, " , %s , , goto\n", l3.c_str());

		fprintf(f, "%s:\n", l2.c_str());
		fprintf(q, "%s:\n", l2.c_str());

		brk.pb(l3);
		cont.pb(l4);
		string body = generateCode(v[4]);
		brk.pop_back();
		cont.pop_back();
		fprintf(f, "%s:\n", l4.c_str());
		fprintf(q, "%s:\n", l4.c_str());

		string itr = generateCode(v[2]);
		fprintf(f, "goto %s\n", l1.c_str());
		fprintf(q, " , %s , , goto\n", l1.c_str());

		fprintf(f, "%s:\n", l3.c_str());
		fprintf(q, "%s:\n", l3.c_str());

		return "";
	}else if(root->tag=="BREAK"){
		fprintf(f, "goto %s\n", brk[brk.size()-1].c_str());
		fprintf(q, " , %s , , goto\n", brk[brk.size()-1].c_str());

	}else if(root->tag=="CONTINUE"){
		fprintf(f, "goto %s\n", cont[cont.size()-1].c_str());
		fprintf(q, " , %s , , goto\n", cont[cont.size()-1].c_str());

	}else if(root->tag=="WHILEEXP"){
		string l1 = getLabel();		
		string l2 = getLabel();
		string l3 = getLabel();
		fprintf(f, "%s:\n", l1.c_str());
		fprintf(q, "%s:\n", l1.c_str());

		string cond = generateCode(v[0]);
		fprintf(f, "if int.%s goto %s\n", cond.c_str(), l2.c_str());
		fprintf(q, " if , int.%s , %s , goto\n", cond.c_str(), l2.c_str());

		fprintf(f, "goto %s\n", l3.c_str());
		fprintf(q, " , %s , , goto\n", l3.c_str());

		fprintf(f, "%s:\n", l2.c_str());
		fprintf(q, "%s:\n", l2.c_str());		

		brk.pb(l3);
		cont.pb(l1);
		string body = generateCode(v[2]);
		brk.pop_back();
		cont.pop_back();
		fprintf(f, "goto %s\n", l1.c_str());
		fprintf(q, " , %s , , goto\n", l1.c_str());

		fprintf(f, "%s:\n", l3.c_str());
		fprintf(q, "%s:\n", l3.c_str());

		return "";															
	}else if(root->tag=="ID"){
		string var1 = "";
		var1 += root->svalue;
		if(root->dimptr.size()){
			vector<int> temp = root->dimptr;
			for(int i=0;i<temp.size();i++){
				var1 += ".";
				var1 += to_string(temp[i]);
			}
		}
		var1 += ".";
		var1 += to_string(root->gScope);
		if(root->gScope>=1){
			var1 += currFunc;
		}
		return var1;
	}else if(root->tag=="IFEXP"){
		string l1 = getLabel();
		string l2 = getLabel();
		string cond = generateCode(v[0]);
		fprintf(f, "if int.%s goto %s\n", cond.c_str(), l1.c_str());
		fprintf(q, " if , int.%s , %s , goto\n", cond.c_str(), l1.c_str());

		fprintf(f, "goto %s\n", l2.c_str());
		fprintf(q, " , %s , , goto\n", l2.c_str());

		fprintf(f, "%s:\n", l1.c_str());
		fprintf(q, "%s:\n", l1.c_str());

		string body = generateCode(v[2]);
		fprintf(f, "%s:\n", l2.c_str());
		fprintf(q, "%s:\n", l2.c_str());

	}else if(root->tag=="IFELSEEXP"){
		string l1 = getLabel();
		string l2 = getLabel();
		string l3 = getLabel();
		string cond = generateCode(v[0]);
		fprintf(f, "if int.%s goto %s\n", cond.c_str(), l1.c_str());
		fprintf(q, " if , int.%s , %s , goto\n", cond.c_str(), l1.c_str());

		fprintf(f, "goto %s\n", l2.c_str());
		fprintf(q, " , %s , , goto\n", l2.c_str());

		fprintf(f, "%s:\n", l1.c_str());
		fprintf(q, "%s:\n", l1.c_str());

		string body = generateCode(v[2]);
		fprintf(f, "goto %s\n", l3.c_str());
		fprintf(q, " , %s , , goto\n", l3.c_str());

		fprintf(f, "%s:\n", l2.c_str());
		fprintf(q, "%s:\n", l2.c_str());

		string el = generateCode(v[5]);
		fprintf(f, "%s:\n", l3.c_str());
		fprintf(q, "%s:\n", l3.c_str());

	}else if(root->tag=="SWITCHEXP"){
		chk = generateCode(v[0]);
		brk.pb(getLabel());
		generateCode(v[1]);
		generateCode(v[2]);
		fprintf(f, "%s:", brk[brk.size()-1].c_str());
		fprintf(q, "%s:", brk[brk.size()-1].c_str());

		brk.pop_back();				
	}else if(root->tag=="CASEEXP"){
		if(v.size()==0){
			return "";
		}
		string var1 = generateCode(v[0]);
		string t1 = getTemp();
		string l1 = getLabel();
		string l2 = getLabel();
		fprintf(f, "int.%s = int.%s == int.%s\n", t1.c_str(), chk.c_str(), var1.c_str());
		fprintf(q, " == , int.%s , int.%s , int.%s\n", chk.c_str(), var1.c_str(), t1.c_str());

		fprintf(f, "if int.%s goto %s\n", t1.c_str(), l1.c_str());
		fprintf(q, " if , int.%s , %s , goto\n", t1.c_str(), l1.c_str());

		fprintf(f, "goto %s\n", l2.c_str());
		fprintf(q, " , %s , , goto\n", l2.c_str());

		fprintf(f, "%s:\n", l1.c_str());
		fprintf(q, "%s:\n", l1.c_str());

		string body = generateCode(v[2]);
		fprintf(f, "%s:\n", l2.c_str());
		fprintf(q, "%s:\n", l2.c_str());

		generateCode(v[4]);
		return "";
	}else if(root->tag=="DEFAULTEXP"){
		if(v.size()==0){
			return "";
		}
		string body = generateCode(v[1]);
		return "";
	}else if(root->tag=="FUNCDECL"){
		return "";
	}else if(root->tag=="RETURN"){
		if(v.size()==0){
			fprintf(f, "return NULL\n");
			fprintf(q, " , NULL , , return\n");

		}else{
			string var1 = generateCode(v[0]);
			fprintf(f, "return %s.%s\n", v[0]->dtype.c_str() ,var1.c_str());
			fprintf(q, " , %s.%s , , return\n", v[0]->dtype.c_str() ,var1.c_str());

		}
	}else if(root->tag=="FUNCCALL"){
		int temp = printFlag;
		printFlag = 0;
		string fName = v[0]->svalue;
		callFunc.pb(fName);
		generateCode(v[1]);
		callFunc.pop_back();
		fprintf(f, "call %s\n", fName.c_str());
		fprintf(q, " , %s , , call\n", fName.c_str());

		string var1 = "";
		if(FuncTable[fName]->returntype!="void"){
			var1 = getTemp();
			fprintf(f, "refparam %s.%s\n", FuncTable[fName]->returntype.c_str(), var1.c_str());
			fprintf(q, " , %s.%s , , refparam\n", FuncTable[fName]->returntype.c_str(), var1.c_str());

		}
		printFlag = temp;
		return var1;
	}else if(root->tag=="PRINTEXP"){
		generateCode(v[0]);
		fprintf(f, "print \"\\n\" \n");
		fprintf(q, " , \"\\n\" , , print\n");

	}else if(root->tag=="ARGS1"){
		if(v.size()!=0){
			vector<string> param;
			para.pb(param);
			generateCode(v[0]);
			for(string s : para[para.size()-1]){
				fprintf(f, "print %s\n", s.c_str());
				fprintf(q, " , %s , , print\n", s.c_str());

			}
			para.pop_back();
			return "";
		}
	}else if(root->tag=="ARGSLIST1"){
		if(root->svalue=="1"){
			generateCode(v[0]);
			string t = "";
			t += v[1]->dtype;
			t += ".";
			t += generateCode(v[1]);
			para[para.size()-1].pb(t);
		}else if(root->svalue=="2"){
			string t = "";
			t += v[0]->dtype;
			t += ".";
			t += generateCode(v[0]);
			para[para.size()-1].pb(t);
		}else if(root->svalue=="3"){
			generateCode(v[0]);
			string str = v[1]->svalue;
			string t = "";
			t += str;
			para[para.size()-1].pb(t);
		}else{
			string str = v[0]->svalue;
			string t = "";
			t += str;
			para[para.size()-1].pb(t);
		}
	}else if(root->tag=="READEXP"){
		printFlag = 1;
		generateCode(v[0]);
		printFlag = 0;
	}else if(root->tag=="ARGS"){
		if(v.size()!=0){
			vector<string> param;
			para.pb(param);
			generateCode(v[0]);
			for(string s : para[para.size()-1]){
				if(!printFlag){
					fprintf(f, "param %s\n", s.c_str());
					fprintf(q, " , %s , , param\n", s.c_str());
				}
				else{
					fprintf(f, "read %s\n", s.c_str());
					fprintf(q, " , %s , , read\n", s.c_str());
				}

			}
			para.pop_back();
			return "";
		}
	}else if(root->tag=="ARGSLIST"){
		if(v.size()==1){
			string t = "";
			t += v[0]->dtype;
			t += ".";
			t += generateCode(v[0]);
			para[para.size()-1].pb(t);
		}else{
			generateCode(v[0]);
			string t = "";
			t += v[1]->dtype;
			t += ".";
			t += generateCode(v[1]);
			para[para.size()-1].pb(t);
		}
	}else if(root->tag=="VARARRAY"){
		string t = v[0]->svalue;
		int a = 1;
		vector<int> temp = root->dimptr;
		for(int i=0;i<temp.size();i++)
		{
			a = a*temp[i];
		}
		if(v[0]->gScope>=1)	{
			fprintf(f, "decl %s.%s.%d%s(%d)\n", v[0]->dtype.c_str(), t.c_str(), v[0]->gScope, currFunc.c_str(),a );
			fprintf(q, " , %s.%s.%d%s(%d) , , decl\n", v[0]->dtype.c_str(), t.c_str(), v[0]->gScope, currFunc.c_str(),a );

		}else{
			fprintf(f, "decl %s.%s.%d(%d)\n", v[0]->dtype.c_str(), t.c_str(), v[0]->gScope,a );
			fprintf(q, " , %s.%s.%d(%d) , , decl\n", v[0]->dtype.c_str(), t.c_str(), v[0]->gScope,a );

		}
	}else if(root->tag=="FOREXPERR"){
		if(v.size()!=0){
			return generateCode(v[0]);
		}
	}
	else{
		for(int i=0;i<root->children.size();i++){
			generateCode(root->children[i]);
		}
	}
	return "";
}

void generateFunc(ptr * root){
	fprintf(f, "func begin %s\n", root->svalue.c_str());
	fprintf(q, " begin , func , %s , \n", root->svalue.c_str());

	vector< variable * > v = FuncTable[root->svalue]->params;
	for(variable * var : v){
		fprintf(f, "args %s.%s.%d.%s\n", var->dtype.c_str(), var->name.c_str(), var->scope, root->svalue.c_str());	
		fprintf(q, " , %s.%s.%d.%s , , args\n", var->dtype.c_str(), var->name.c_str(), var->scope, root->svalue.c_str());		

	}
	currFunc = "." + root->svalue;
	if(root->children.size()==7){
		generateCode(root->children[4]);
	}else{
		generateCode(root->children[5]);
	}
	currFunc = "";
	
	fprintf(f, "func end\n");
	fprintf(q, " end , func , , \n");

}

int main(){
		
		map< string , variable* > mp;

		func * main  = new func;
		main->numparam = 0;
		main->returntype = "int";
		
		main->name = "main";
		FuncTable["main"] = main;

		SymTable.pb(mp);

		yyparse();
		// PrintTree(treeRoot,0);
		//SymTablePrint();

		if(semanticERROR || syntaxERROR)
		{
			cout << "" << endl;
		}
		else
		{
			fprintf(q, " operator , arg1 , arg2 , result\n");
			//SymTablePrint();
			for( ptr * p : funcList)
				generateFunc(p);
			fprintf(f, "func begin main\n");
			fprintf(q, " begin , func , main , \n");

			generateCode(treeRoot);
			fprintf(f, "func end\n");
			fprintf(q, " end , func , , \n");

		}
}