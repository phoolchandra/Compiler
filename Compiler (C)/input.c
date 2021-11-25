#include <stdio.h>
#include <stdlib.h>


int a;

int b;
void print_global(){
    printf("a: ",a);
    printf("b: ",b);
}
void set_global_variable(int a1,int b1){
    a=a1;
    b=b1;
}
void scope_check(){
    int a;
    int b;
    {
        a=3;
        b=4;
        printf(a,b);   
    }
}
int array_check(){
    int arr[2][2];
    int i,j;
    int k=0;
    for(i=0;i<2;++i){
        for(j=0;j<2;++j){
            arr[i][j]=i+j;
            k=k+arr[i][j];
        }
    }
    return k;
}
// void switch_case(){

// }

void global_variable(int k){
    a=k*a;
    b=k*b;
}

int for_loop(int k){
    int x=1;
    while(k){
        x=x*2;
        --k;
    }
    return x;
}

void while_loop(){
    while(a!=0){
        while(b!=0){
            --b;
        }
        --a;
    }
    print_global();
}

void if_else(int c){
    if(a==b){
        if(c!=1){
            a=c;
            b=c;
        }
        else{
            a=a/2;
        }
    }
}

void relational_operator(){
    while(a-b!=5){
        if(a-b<5){
            ++a;
        }
        if(a-b>5){
            --a;
        }
    }
}


int arithmetic_operation(){
   int op;
   float c=8.3;
    printf("1: a=a+b 2: a=a*b 3: a=a/b 4: a=a-b : 5: c =a + c;");
    scanf(op);
    
    if(op==1){
        a=a+b ;
    }
    if(op == 2){
        a=a*b;
    }
    if(op==3){
        a=a/b;
    }if(op==4){
        a=a-b;
    }
    if(op==5){
        c=a+c;
        printf("c",c);
    }
}
int function_call(){
    printf("short circuit failed");
    return 0;
}
void short_circuit(){
    if(a==b || function_call()){
        printf("short circuit passed");    
    }
}

// recursion
int precedence(int a,int b,int c){
    int k=a+c*b;
    return k;
}

int main(){

    a=1;
    b=1;
    
    int s;

    while(1){
        

        printf("0: scope_check\n1: array_check \n2 : arithmetic_operation\n3: global_variable\n4: for_loop\n5: while_loop");
        printf("6: if_else\n7: precedence \n8 : relational_operator\n9: short_circuit\n10: set_global_variable\n");
        scanf(s);

        switch (s)
        {
            case (0):{
                printf("before scope_check ");
                print_global();
                scope_check();
                printf("after scope check ");
                print_global();   
                break;
            }
            case (1):{
                int c;
                printf("array check");
                c=array_check();
                printf("sum of elements in array ",c);
                break;
            }
            case (2):{
                // switch_case();
                arithmetic_operation();
                // printf("switch_case is in main");
                break;
                }
            case (3):{
                    int l,k;
                    printf("enter k to multiply global variable with k");
                    scanf(k);
                    global_variable(k);
                    printf("global variable after multiplying with ",k);
                    print_global();
                    break;
            }
            case (4):{
                int p;
                printf("this will return power of 2");
                scanf(p);
                p=for_loop(p);
                printf(p);
                break;
            }
            case (5):{
                print_global();
                printf("this will set global variable to 0 ");
                while_loop();
                print_global();
                break;
            }
            case (6):{
                int k;
                printf("set global variable to value k and enter 1 to half the value of a");
                scanf(k);
                if_else(k);
                print_global();
                    break;
            }
            case (7):{
                int e,f,g;
                printf("enter value of e f g");
                scanf(e,f,g);
                
                g=precedence(e,f,g);
                printf("value of g after",g);
                break;
            }

            case (8):{
                printf("change a and b such that a - b =5");
                relational_operator();
                print_global();
                break;
            }
            case (9):{
                printf("check short circuit");
                short_circuit();
                break;
            }
            case (10):{
                // printf("check st circuit");
                int a1,b1;
                scanf(a1,b1);
                set_global_variable(a1,b1);
                print_global();
                break;
            }
            default:{
                printf("wrong input");
                break;
            }
        }
    } 
}