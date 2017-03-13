%{
#include "heading.h"
int yyerror (char* s);
int yylex (void);
vector <string> func_table; //Stores the names of functions for the function lookup table
vector <string> sym_table;  //Stores the name of the symbols for the symbol table
vector <string> sym_type;   //Stores the data type of the variables denoted by the symbols 
vector <string> op;
vector <string> stmnt_vctr;
string temp_string; 
int temp_var_count;
stringstream m;
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
					cout<<".[] "<<sym_table.at(j)<<","<<sym_type.at(j)<<endl;
			}
            //STATEMENT PRINT
            for(unsigned i=0;i<stmnt_vctr.size();i++)
                cout<<stmnt_vctr.at(i)<<endl;
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
            stmnt_vctr.push_back("= _" + *($1) + "," + op.back() );
            op.pop_back();
            cout<<op.size()<<endl;
            op.clear()  //REMOVE AFTER TESTING
        }
        | IDENTIFIERS LSQUARE expression RSQUARE ASSIGN expression
        {
            string array_result_expression = op.back();
            op.pop_back();
            string array_expression = op.back();
            op.pop_back();
            stmnt_vctr.push_back("[]= " + *($1)+"," + array_expression + "," + array_result_expression); 
        }
        ;

bb:		IF boolean_expr THEN statements ENDIF
        {op.clear();}
	
		| IF boolean_expr THEN statements ELSE statements ENDIF 
		{op.clear();}
        ;


cc:		WHILE boolean_expr BEGINLOOP statements ENDLOOP 
		{op.clear();}

        ;

dd:		DO BEGINLOOP statements ENDLOOP WHILE boolean_expr 
		{op.clear();}

        ;

ee:		READ var ii
        {
            while(!op.empty())
            {
          		string s= op.front();
                op.erase(op.begin());
                // insert symbol table checking here
                stmnt_vctr.push_back(".< "+ s);
                //read statements in machine language
            }
            op.clear();
        }
	    
 	
        ;

ii:		/*empty*/ 
		| COMMA var ii 
		
        ;

ff:		WRITE var ii
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
        {op.clear();}
		;

hh:		RETURN expression
        {
            op.clear();
        }
		;

boolean_expr:	relation_exprr
		| boolean_expr OR relation_exprr 
		;

relation_exprr:	relation_expr 
		| relation_exprr AND relation_expr 
		;

relation_expr:	rexpr
		| NOT rexpr 
		;

rexpr:		expression comp expression 
		| TRUE
		| FALSE 
		| LPAREN boolean_expr RPAREN 
		

comp:	EQ 
		| NEQ 
		| LT 
		| GT
		| LTE
		| GTE 
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
            stmnt_vctr.push_back("+ "+ new_temp_var + ","+op1+","+op2);    
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
            stmnt_vctr.push_back("- "+ new_temp_var + ","+op1+","+op2);    
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
            stmnt_vctr.push_back("* "+ new_temp_var + ","+op1+","+op2);    
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
            stmnt_vctr.push_back("/ "+ new_temp_var + ","+op1+","+op2);    
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
            stmnt_vctr.push_back("% "+ new_temp_var + ","+op1+","+op2);    
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
                    stmnt_vctr.push_back("- "+ new_temp_var + ",0," +op.back());    
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
                        stmnt_vctr.push_back("=[] "+new_temp_var+","+op1.substr(3,op1.length()-3));
                    else                                    //Copy statement for normal variables
                        stmnt_vctr.push_back("= "+ new_temp_var+","+op.back());    
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
                    stmnt_vctr.push_back("= "+ new_temp_var +","+ ss.str());
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
                    op.push_back("_"+*($1));
                }
                | IDENTIFIERS LSQUARE expression RSQUARE
                {
                    string op1 = op.back();
                    op.pop_back();
                    op.push_back("[] _" + *($1) + ", " + op1);
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

