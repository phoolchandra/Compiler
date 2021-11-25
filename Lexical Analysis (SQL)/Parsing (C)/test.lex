%{ 
#include<bits/stdc++.h>
using namespace std;
set<string> className;
string SPACE = " \n\r\t\f\v";
set<int> obj;
set<int> classDec;
set<int> constDec;
set<int> inherClass;
set<int> opOverload;
string removespace(string s)
{
    int start = s.find_first_not_of(SPACE);
    if (start==-1)
        return s.substr(0 , 0);

    s = s.substr(start);
    int end = s.find_last_not_of(SPACE);
    s = s.substr(0 , end + 1);
    return s;
}
void addClassName(string s){
	s = s.substr(5, s.length());
	s = removespace(s);
	string ans;
	int i = 0;
	while(isalnum(s[i]) || s[i]=='_'){
		ans+=s[i];
		i++;
	}
	className.insert(ans);

	return;
}
int identifyConstObj(string s){
	string ans;
	int i = 0;
	while(isalnum(s[i]) || s[i]=='_'){
		ans+=s[i];
		i++;
	}
	if(className.find(ans)!=className.end()){
		return 1;
	}
	return 0;
}
%} 
%option yylineno
%x CLASS
%x NAMECLASS
%% 
"//".*                                    { }
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]       { }
["][^"]*["]       { }
"class"[ \n]+[a-zA-Z0-9_]+[ \n]+"{" {addClassName(yytext);classDec.insert(yylineno);}
"class"[ \n]+[a-zA-Z0-9_]+[ \n]*":"[ \n]*[a-zA-Z0-9_ \n,]+"{" {addClassName(yytext);classDec.insert(yylineno);inherClass.insert(yylineno);}
operator {opOverload.insert(yylineno);}
[~][a-zA-Z0-9_]+[ \n]*"(" { }
[a-zA-Z0-9_]+[ \n]*"(" { if(identifyConstObj(yytext))constDec.insert(yylineno);}
[a-zA-Z0-9_]+[ \n*]+[a-zA-Z0-9_]+[ \n]*[,;=(]+ { if(identifyConstObj(yytext))obj.insert(yylineno);}
. {}
\n { }
%% 

int yywrap(){} 
int main(){ 
yylex(); 

cout<<"Object Declaration - "<<obj.size()<<endl;
cout<<"Class Definition - "<<classDec.size()<<endl;
cout<<"Constructor Definition - "<<constDec.size()<<endl;
cout<<"Inherited Class Definition - "<<inherClass.size()<<endl;
cout<<"Operator Overloaded function Definition - "<<opOverload.size()<<endl;
return 0; 
} 