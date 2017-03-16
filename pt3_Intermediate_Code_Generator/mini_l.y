%{
#include "heading.h"
int yyerror (char* s);
int yylex (void);
bool in_sym_table(string);
bool in_arr_table(string);
vector <string> func_table; //Stores the names of functions for the function lookup table
vector <string> sym_table;  //Stores the name of the symbols for the symbol table
vector <string> sym_type;   //Stores the data type of the variables denoted by the symbols 
vector <string> op;         //Stores the operands for calculations within the stack. 
                            //Acts as both stack and queue [queue needed for read and write]
vector <string> stmnt_vctr; //Stores the statements in machine language
string temp_string;         //temporary variable
int temp_var_count;         //keeps a count on the number of temporary variables used
int label_count;            //keeps track of the next label number
vector <vector <string> > if_label; //storing 2 labels for if statement and 3 labels for else statement
vector <vector <string> > loop_label;
stringstream m;             //Used for conversion from int to string --> can be cleared by
                            //m.str("")[to clear the string buffer; m.clear()[to clear the parameters and errors
%}

%union{
int val;
string* op_val;
}
%start	prog_start

%token	FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE SEMICOLON COLON COMMA LPAREN RPAREN LSQUARE RSQUARE ASSIGN RETURN
%token <val> NUMBERS
%token <op_val> IDENTIFIERS
%left MULT DIV MOD ADD SUB 
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND OR
%right ASSIGN

%%

prog_start:	functions
		;	
	
functions:	/*empty*/
		| function functions
		
		;

function:	FUNCTION IDENTIFIERS SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY 
		{
			func_table.push_back(*($2));
            cout <<"func "<<*($2)<<endl;
            //VARIABLE AND PARAMETER DECLARATIONS
			for(unsigned int j=0;j<sym_table.size();j++)
			{
				if(sym_type.at(j)=="INTEGER")
					cout<<". "<<sym_table.at(j)<<endl;
				else
					cout<<".[] "<<sym_table.at(j)<<", "<<sym_type.at(j)<<endl;
			}
            //STATEMENT PRINT
            for(unsigned i=0;i<stmnt_vctr.size();i++)
                cout<<stmnt_vctr.at(i)<<endl;
            cout<<"endfunc"<<endl;
            stmnt_vctr.clear();
            sym_table.clear();
            sym_type.clear();

		}
		; 


declarations:	/*empty*/ 
		        | declaration SEMICOLON declarations 
		        ;

declaration:	id COLON assign 
		;

id:		IDENTIFIERS 
		{
			sym_table.push_back("_"+*($1));
		}
		| IDENTIFIERS COMMA id 
		{
			sym_table.push_back("_"+*($1));
			sym_type.push_back("INTEGER");
		}
		;

assign:		INTEGER 
		{ 
			sym_type.push_back("INTEGER");
		}
		| ARRAY LSQUARE NUMBERS RSQUARE OF INTEGER 
		{
			stringstream ss;
			ss << $3;
			string s = ss.str();
			sym_type.push_back(s);
		} 
		;

statements:	statement SEMICOLON statements
		    | statement SEMICOLON 
		    ;

statement:  aa
		    | bb
		    | cc
		    | dd
	       	| ee
            | ff
            | gg
        	| hh
            ;
aa:		IDENTIFIERS ASSIGN expression
        {
            string var = "_"+*($1);
            if (!in_sym_table(var))
                exit(0);
            stmnt_vctr.push_back("= " + var + ", " + op.back() );
            op.pop_back();
            //cout<<op.size()<<endl;    TEST
            //op.clear()  //REMOVE AFTER TESTING
        }
        | IDENTIFIERS LSQUARE expression RSQUARE ASSIGN expression
        {
            string var = "_"+*($1);
            if (!in_arr_table(var))
                exit(0);
            string array_result_expression = op.back();
            op.pop_back();
            string array_expression = op.back();
            op.pop_back();
            stmnt_vctr.push_back("[]= _" + *($1)+", " + array_expression + ", " + array_result_expression); 
        }
        ;


if_clause:		IF boolean_expr THEN
        {
            //MACHINE LANGUAGE CODE FOR IF STATEMENT
            /* ?= test_codition_temp_variable, goto first_label
                =:second_label
                :first_label
                ## Statements
                :second_label
            */
            label_count++;     //Generating two discrete labels for this if statement
            m.str("");
            m.clear();      //clearing the stringstream buffer
            m<<label_count;
            string label_1 = "if_condition_true_"+m.str();  //creating label1
            string label_2 = "if_condition_false_"+m.str(); //creating label2
            string label_3 = "end_if_"+m.str();   //creating label3
            vector<string> temp;        //temp label vector
            temp.push_back(label_1);    //pushing first label onto temp label vectr
            temp.push_back(label_2);    //pushing second label onto temp vector
            temp.push_back(label_3);
            if_label.push_back(temp);   //pushing temp vector onto if label
            stmnt_vctr.push_back("?:= "+if_label.back().at(0)+", "+op.back());
                                        //MC: evaluate if condition and goto first_label
            op.pop_back();
            stmnt_vctr.push_back(":= "+if_label.back().at(1));  //MC: goto second_label
            stmnt_vctr.push_back(": "+if_label.back().at(0));      //MC: declaration first_label

        }
        ;

else_if:    if_clause statements ELSE
            {
                /* Structure of IF-ELSE LOOP:
                    ?= if_condition_true_[NUM]
                    =: if_condition_false_[NUM]
                    //statements
                    =:end_if_[NUM]
                    :if_condition_false_[NUM]
                    //statements
                    :end_if_[NUM]
                */
                stmnt_vctr.push_back(":= "+if_label.back().at(2));
                stmnt_vctr.push_back(": "+if_label.back().at(1));
            }
            ;

bb:	    if_clause statements ENDIF
        {
            //declare second_label
            stmnt_vctr.push_back(": "+if_label.back().at(1));
            if_label.pop_back();
        }
        |else_if statements ENDIF 
		{
           stmnt_vctr.push_back(": "+if_label.back().at(2));
           if_label.pop_back();             //END_LOOP_HERE
        }
        ;

while_key:  WHILE
         {
            //MACHINE LANGUAGE CODE FOR WHILE STATEMENT
            /* :while_loop_[NUM]
                //conditional statements
                ?= test_codition_temp_variable, conditonal_true_[NUM]
                =:conditional_false_[NUM]
                :conditional_true_[NUM]
                ## Statements
                =: while_loop_[NUM]
                :conditional_false[NUM]
            */
            label_count++;     //Generating two discrete labels for this if statement
            m.str("");
            m.clear();      //clearing the stringstream buffer
            m<<label_count;
            string label_1 = "while_loop_"+m.str();  //creating loop label
            string label_2 = "conditional_true_"+m.str();  //creating entry label
            string label_3 = "conditional_false_"+m.str();  //creating exit label
            vector<string> temp;        //temp label vector
            temp.push_back(label_1);    //pushing first label onto temp label vectr
            temp.push_back(label_2);    //pushing second label onto temp vector
            temp.push_back(label_3);    //pushing third label onto temp vector
            loop_label.push_back(temp);   //pushing temp vector onto if label
            stmnt_vctr.push_back(": "+loop_label.back().at(0));      //MC: declaration loop_label
         }
         ;
while_clause: while_key boolean_expr BEGINLOOP
            {
                stmnt_vctr.push_back("?:= "+loop_label.back().at(1)+", "+op.back());
                op.pop_back();
                stmnt_vctr.push_back(":= "+loop_label.back().at(2));
                stmnt_vctr.push_back(": "+loop_label.back().at(1));
            }
            ;

cc:		 while_clause statements ENDLOOP 
		{
            stmnt_vctr.push_back(":= "+loop_label.back().at(0));
            stmnt_vctr.push_back(": "+loop_label.back().at(2));
            loop_label.pop_back();
        }
        ;

do_key: DO BEGINLOOP
        {                   //sounds like 'dookie'....geddit?
             //MACHINE LANGUAGE CODE FOR DO-WHILE STATEMENT
            /* :do_while_loop_[NUM]
                =:conditional_false_[NUM]
                :conditional_true_[NUM]
                ## Statements
                ?= test_codition_temp_variable, conditonal_true_[NUM]
            */
            label_count++;     //Generating two discrete labels for this if statement
            m.str("");
            m.clear();      //clearing the stringstream buffer
            m<<label_count;
            string label_1 = "do_while_loop_"+m.str();  //creating loop label
            vector <string> temp;
            temp.push_back(label_1);
            loop_label.push_back(temp);
            stmnt_vctr.push_back(": "+label_1);
        }
        ;
dd:	     do_key statements ENDLOOP WHILE boolean_expr 
		{
            stmnt_vctr.push_back("?:= "+ loop_label.back().at(0)+", "+op.back());
            //if condition is false just continue the program execution
            //the single execution before condition check satisfies do while 
            //statment's requirement
            op.pop_back();
            loop_label.pop_back();
        }
        ;

ee:		READ IDENTIFIERS                //!!---IMPORTANT----!!
        {                               //READ cannnot process multiple variables. only one variable at a time
            string var = "_"+*($2);
            if (!in_sym_table(var))
                exit(0);
            stmnt_vctr.push_back(".< _"+*($2));
        }
        |READ IDENTIFIERS LSQUARE expression RSQUARE
        {
            //First equating the input to a temporary variable
            //then assigning the input to the element in the array
            string var = "_"+*($2);
            if (!in_arr_table(var))
                exit(0);
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;                       
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            stmnt_vctr.push_back(".< "+new_temp_var);
            stmnt_vctr.push_back("[]= _"+*($2)+", "+op.back()+", "+new_temp_var);
            op.pop_back();
        }
	    ;

ii:		/*empty*/ 
		| COMMA posterm ii 
		
        ;

ff:		WRITE posterm ii
        {
            while(!op.empty())
            {
            	string s= op.front();
                op.erase(op.begin());
                // insert symbol table checking here
                stmnt_vctr.push_back(".> "+ s);
                //write statements in machine language
            }
            op.clear();
        }
		;

gg:		CONTINUE 
        {
            //Just transfer control back to the head of the most recent while loop
            //:= while_loop_[NUM]
            if (!loop_label.empty())
                stmnt_vctr.push_back(":= "+ loop_label.back().at(0));
        }
		;

hh:		RETURN expression
        {
            op.clear();
        }
		;

boolean_expr:	relation_exprr
		| boolean_expr OR relation_exprr 
		{
            //|| t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("|| "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }
        ;

relation_exprr:	relation_expr 
		| relation_exprr AND relation_expr 
		{
            //&& t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("&& "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }

        ;

relation_expr:	rexpr
		| NOT rexpr
        {
            //! t[temp_var_num], first_unused_variable_from_stack
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op1 = op.back();
            op.pop_back();                          //removing last variable as it has already been used
            stmnt_vctr.push_back("! "+new_temp_var+", "+op1);   //equating the the logical NOT of the last variable on the stack
                                                                //to the new temporary variable that will be added to the stack
            op.push_back(new_temp_var);

        }
		;

rexpr:	expression EQ expression
        {
            //== t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("== "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }
		| expression NEQ expression
        {
            //!= t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("!= "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }

        | expression LT expression 
        {
            //< t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("< "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }
        | expression GT expression 
        {
            //> t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("> "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }
        | expression LTE expression 
        {
            //<= t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("<= "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }
        | expression GTE expression 
        {
            //>= t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back(">= "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }
        |TRUE
        {
            //= t[temp_var_num], 1 [TRUE]
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            stmnt_vctr.push_back("= "+new_temp_var+", 1"); //adding constant value TRUE via temporary variables on operand stack
            op.push_back(new_temp_var);
        }
		| FALSE
        {
            //= t[temp_var_num], 0 [FALSE]
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            stmnt_vctr.push_back("= "+new_temp_var+", 0"); //adding constant value FALSE via temporary variables on operand stack
            op.push_back(new_temp_var);
        }
		| LPAREN boolean_expr RPAREN 
        ;		


expression:	mul_expr expradd
		;

expradd:	/*empty*/ 
		| ADD mul_expr expradd
        {
            //+ t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("+ "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable

        }
		| SUB mul_expr expradd
        {
            //- t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("- "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }
		;

mul_expr:	term multi_term 
		;

multi_term:	/*empty*/ 
		| MULT term multi_term 
        {
            //* t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("* "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }
		| DIV term multi_term
        {
            // / t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("/ "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }

		| MOD term multi_term
        {
            //% t[temp_var_num],second_to_last_operand,last_operand_from_vector
            m.str("");
            m.clear();                              //clearing string stream for conversion from int to str
            m<<temp_var_count;                      //feeding int to stringstream
            temp_var_count++;
            string new_temp_var='t'+ m.str();       //creating temp variable name
            sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
            sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
            string op2 = op.back();
            op.pop_back();
            string op1 =op.back();
            op.pop_back();
            stmnt_vctr.push_back("% "+ new_temp_var + ", "+op1+", "+op2);    
            op.push_back(new_temp_var); //pushing new temp variable
        }

		;

term:           posterm 
                {
                    //empty transition. Last operand on stack si still a valid part
                }
                | SUB posterm
                {
                    //UNARY MINUS: -value = 0 - value
                    //- t[temp_var_num],0,[last_var in operand list]
                    m.str("");
                    m.clear();                              //clearing string stream for conversion from int to str
                    m<<temp_var_count;                      //feeding int to stringstream
                    temp_var_count++;
                    string new_temp_var='t'+ m.str();       //creating temp variable name
                    sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
                    sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table 
                    stmnt_vctr.push_back("- "+ new_temp_var + ", 0, " +op.back());    
                    op.pop_back();  //removing the old variable and replacing with new temp variable 
                    op.push_back(new_temp_var); //pushing new temp variable

                }
                | IDENTIFIERS term_iden 
                ;

posterm:        var                 //THIS ENTIRE STEP  IS NOT REDUNDANT__IT IS ABSOLUTELY NECESSARY TO MAINTAIN THE 3 ADDRESS MODE
                                    //This has been used to remove the identifiers from the symbol table, and replace them with 
                                    // temporary variables. This reduces teh number of places where identifier checks have been 
                                    //performed to just one.
                {
                    //= t[temp_var_num], [var in operand list]
                    m.str("");
                    m.clear();                       //clearing string stream for conversion from int to str
                    m<<temp_var_count;                  //feeding int to stringstream
                    temp_var_count++;
                    string new_temp_var='t'+ m.str();       //creating temp variable name
                    sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
                    sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table 
                    string op1=op.back();       
                    if(op1.at(0)=='[')                  //Copy Statement for array elements
                        stmnt_vctr.push_back("=[] "+new_temp_var+", "+op1.substr(3,op1.length()-3));
                    else                                    //Copy statement for normal variables
                        stmnt_vctr.push_back("= "+ new_temp_var+", "+op.back());    
                    op.pop_back();  //removing the old variable and replacing with new temp variable 
                    op.push_back(new_temp_var); //pushing new temp variable
                }
                | NUMBERS
                {
                    // t[temp_var_num] =39
                    //.= t[temp_var_num],39 
                    m.str("");
                    m.clear();                          //clearing string stream for conversion from int to str
                    m<<temp_var_count;                  //feeding int to stringstream
                    temp_var_count++;                   //incrementing count of temp vars
                    string new_temp_var='t'+ m.str();       //creating temp variable name
                    sym_table.push_back(new_temp_var);      //adding temporary variable to symbol table
                    sym_type.push_back("INTEGER");          //adding datatype for the temp var to symbol table
                    stringstream ss;
                    ss << $1;
                    stmnt_vctr.push_back("= "+ new_temp_var +", "+ ss.str());
                    op.push_back(new_temp_var);
                }
                | LPAREN expression RPAREN
                ;

term_iden:      LPAREN term_ex RPAREN 
                | LPAREN RPAREN 
                ;

term_ex:        expression 
                | expression COMMA term_ex 
                ;

var:            IDENTIFIERS
                {
                    string var = "_"+*($1);
                    if (!in_sym_table(var))
                        exit(0);
                    op.push_back(var);
                }
                | IDENTIFIERS LSQUARE expression RSQUARE
                {
                    string op1 = op.back();
                    op.pop_back();
                    string var = "_"+*($1);
                    if (!in_arr_table(var))
                        exit(0);
                    op.push_back("[] " + var + ", " + op1);
                }
                ;
%%

int yyerror(string s)
{
  extern int row, column;	// defined and maintained in lex.c
				//to maintain the row and column
				//of characters
  extern char *yytext;		// defined and maintained in lex.c
  
  cerr << "SYNTAX(PARSER) Error at line "<<row<<", column "<<column<<" : Unexpected Symbol \""<<yytext<<"\" Encountered."<<endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}

//FUNCTION CHECKS IF THE INTEGER VARIABLE USED HAS BEEN DECLARED FIRST
bool in_sym_table(string var)
{
    extern int row, column;
    for(unsigned int i=0;i<sym_table.size();i++)
    {
        if(sym_table.at(i)==var)
        {
            if(sym_type.at(i)=="INTEGER")
            {
                return true;
            }
            else
            {
                cout << "SEMANTIC Error at line "<<row<<", column "<<column<<" : Incompatible Datatype - \""<<var.substr(1,var.length()-1)<<"\" is an ARRAY."<<endl; 
                return false;
            }
        }
    }
    cerr << "SEMANTIC Error at line "<<row<<", column "<<column<<" : Undeclared \""<<var.substr(1,var.length()-1)<<"\" Used."<<endl; 
    return false;
}
//FUNCTION CHECKS IF THE ARRAY VARIABLE USED HAS BEEN DECLARED FIRST AND IS IN FACT AN ARRAY
bool in_arr_table(string var)
{
    extern int row, column;
    for(unsigned int i=0;i<sym_table.size();i++)
    {
        if(sym_table.at(i)==var)
        {
            if(sym_type.at(i)=="INTEGER")
            {
                cout << "SEMANTIC Error at line "<<row<<", column "<<column<<" : Incompatible Datatype - \""<<var.substr(1,var.length()-1)<<"\" is an INTEGER."<<endl; 
                return false;
            }
            else
            {
                return true;
            }
        }
    }
    cerr << "SEMANTIC Error at line "<<row<<", column "<<column<<" : Undeclared \""<<var.substr(1,var.length()-1)<<"\" Used."<<endl; 
    return false;
}

