#include <iostream>
using namespace std;

class Person
{
     public:
        string profession;
        int age;

        Person(): profession("unemployed"), age(16) { }

                Person(int a): profession("unemployed"), age(16) { }

        void display()
        {
             cout << "My profession is: " << profession << endl;
             cout << "My age is: " << age << endl;
             walk();
             talk();
        }        void walk() { cout << "I can walk." << endl; }

        class Test        {            private:
              int count;

           public:
               Test(): count(5){}

               void operator ++() 
               { 
                  count = count+1; 
               }
               void operator +() 
               { 
                  count = count+1; 
               }
               void Display() { cout<<"Count: "<<count; }
        };

        /*
        void talk() { cout << "I can talk." << endl; }
        */
};

// MathsTeacher class is derived from base class Person.
class MathsTeacher : public Person
{
    public:
       void teachMaths() { cout << "I can teach Maths." << endl; }
};

// Footballer class is derived from base class Person.
class Footballer : public Person
{
    public:
       void playFootball() { cout << "I can play Football." << endl; }
};




int main()
{
     MathsTeacher teacher;
     teacher.profession = "Teacher";
     teacher.age = 23;
     teacher.display();
     teacher.teachMaths();

     Footballer footballer;      Person p(0);

     footballer.profession = "Footballer";
     footballer.age = 19;
     footballer.display();
     footballer.playFootball();


     return 0;
}