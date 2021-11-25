#include<bits/stdc++.h>
using namespace std;
vector<string> getTokens(char line[]){
char * token;
token = strtok (line,",\n");
vector<string> col;
while (token != NULL)
{
col.push_back(token);
token = strtok (NULL, ",\n");
}
return col;
}
vector<string> getConditions(char line[]){
char * token;
token = strtok (line," ");
vector<string> col;
while (token != NULL)
{
col.push_back(token);
token = strtok (NULL, " ");
}
return col;
}
int sttoi(string s){
		  int flag = 0;
		  int t = 0;
		  for(int i=0;i<s.length();i++){
		    t += s[i];
		    if(!isdigit(s[i])){
		      flag = 1;
		    }
		  }
		  if(flag==0){
		    return stoi(s);
		  }else{
		    return t;
		  }
		}
int main(){
FILE * f1, *f2;
vector<string> row1, row2;
vector<int> indexs;
char * line1 = new char[1000];
char * line2 = new char[1000];
vector<string> col1, col2;
map<string, int> map1, map2;
map<string, string> mapt;
char * cond1;
char * cond2;
char * tp;
vector<string> con, type, type1, tp1;
int index1, index2;
cout<<"Query 1:"<<endl;f1 = fopen("Employee.csv", "r");
    f2 = fopen("Address.csv", "r");
    if(!f1 || !f2){
        cout<<"(Semantic Error-Table not found!)"<<endl;
        goto label0;
    }
    fgets(line1, 1000, f1);
    fgets(line2, 1000, f2);
    line1[strlen(line1)-1] = '\0';
    cout<<line1<<","<<line2;
    col1 = getTokens(line1);
    col2 = getTokens(line2);
        fgets(line1, 1000, f1);
    fgets(line2, 1000, f2);
    line1[strlen(line1)-1] = '\0';
    type = getTokens(line1);
    type1 = getTokens(line2);
for(int i=0;i<col1.size();i++){
        map1.insert({col1[i], i});
    }
    for(int i=0;i<col2.size();i++){
        map2.insert({col2[i], i});
    }
    cond1 = strdup("name");
    cond2 = strdup("name");
    if(map1.find(cond1)==map1.end() || map2.find(cond2)==map2.end()){
        cout<<"(Semantic Error-Column not found!)"<<endl;
    goto label0;
}
    index1 = map1.find(cond1)->second;
    index2 = map2.find(cond2)->second;
    if(type[index1]!=type1[index2]){
        cout<<"(Semantic Error-Type mismatch)"<<endl;
        goto label0;
}
while(fgets(line1, 1000, f1)){
        line1[strlen(line1)-1] = '\0';
        row1 = getTokens(line1);
        while(fgets(line2, 1000, f2)){
            row2 = getTokens(line2);
            if(row1[index1] == row2[index2]){
                for(int i=0;i<row1.size();i++){
                    cout<<row1[i]<<",";
                }
                for(int i=0;i<row2.size();i++){
                    cout<<row2[i];
                    if(i!=row2.size()-1)cout<<",";
                }
                cout<<endl;
            }
        }
        fseek(f2, 0, SEEK_SET);
        fgets(line2, 1000, f2);
        fgets(line2, 1000, f2);
    }
fclose(f1);
fclose(f2);
label0 :
cout<<endl;
}
