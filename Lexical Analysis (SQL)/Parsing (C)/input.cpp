

#include <bits/stdc++.h> 
using namespace std; 




class Geeks 
{ 
	public: 
	int id; 
	
	//Default Constructor 
	Geeks() 
	{ 
		cout << "Default Constructor called" << endl; 
		id=-1; 
	} 

class gfg1
{
	public:
		gfg1();
		~gfg1();
	};
	
	void operator ++() 
       { 
          count = count+1; 
       }	
	
	
	//Parametrized Constructor 
	Geeks(int x) 
	{ 
		cout << "Parametrized Constructor called" << endl; 
		id=x; 
	} 
	~Geeks() 
    { 
        cout << "Destructor called for id: " << id <<endl;  
    } 
}; 

// MathsTeacher class is derived from base class Person.
class MathsTeacher : public Geeks
{
    public:
       void teachMaths() { cout << "I can teach Maths." << endl; }
};

class Bat: public Mammal, public WingedAnimal {

};

int main() { 
	
	// obj1 will call Default Constructor 
	Geeks obj1; 
	cout << "Geek id is: " <<obj1.id << endl; 
		Geeks obj1; 
		MathsTeacher teacher;
	// obj1 will call Parametrized Constructor 
	Geeks obj2(21); 
	cout << "Geek id is: " <<obj2.id << endl; 
	return 0; 
} 
