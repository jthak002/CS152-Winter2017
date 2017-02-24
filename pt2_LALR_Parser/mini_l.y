%{
#include <iostream>
#include <stdlib.h>
#include <string.h>
int yyerror (char* s);
int yylex (void)
%}

%union{
int 	int_val;
string*	op_val;
string*	keyw;
string* rel_op;
string* identifier_str;
}

%start	prog_start

%token	FUNCTION IDENTIFIERS BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE
%left MULT DIV MOD ADD SUB 
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND OR
%right ASSIGN
%type prog_start functions function declarations declaration statements 

%%

prog_start:	functions { cout<<"prog_start->functions"; }
		;	
	
functions:	/*empty*/{cout<<"function->epsilon"<<endl;}
		| function functions {cout<<"functions -> function functions"<<endl;}
		;

function:	FUNCTION IDENT identifier_str SEMICOLON BEGINPARAMS dec ENDPARAMS BEGINLOCALS dec ENDLOCALS BEGINBODY statements ENDBODY {cout<<"FUNCTION "<<identifier_str<<" SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY"<<endl;}
		;


declarations:	/*empty*/ {cout<<"declarations->epsilon\n"}
		| declaration SEMICOLON declarations {cout<<"declarations -> declaration SEMICOLON declarations"<<endl;}
		;

declaration:	id COLON assign {cout<<"id COLON assign"<<endl;}
		;

id:		IDENTIFIER {cout<<"id -> "<<identifier_str<<endl;}
		| IDENTIFIER COMMMA id {cout<<" id -> "<<identifier_str<<" COMMA id" << endl;}
		;

assign:		INTEGER {cout<<"assign -> INTEGER"<<endl;}
		| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {cout<<"assign -> ARRAY L_SQUARE_BRACKET "<<int_val<<" R_SQUARE_BRACKET OF INTEGER"<<endl;}
		;

statements:	statement SEMICOLON statements {cout<<"statements -> statement SEMICOLON statements"<<endl;}
		| statment SEMICOLON {cout<<"statements -> statement SEMICOLON"<<endl;}
		;

statement:	aa{cout<<"statement -> aa"<<endl;}
		| bb{cout<<"statement -> bb"<<endl;}
		| cc{cout<<"statement -> cc"<<endl;}
		| dd{cout<<"statement -> dd"<<endl;}
		| ee{cout<<"statement -> ee"<<endl;}
		| ff{cout<<"statement -> ff"<<endl;}
		| gg{cout<<"statement -> gg"<<endl;}
		| hh{cout<<"statement -> hh"<<endl;}
		;

aa:		var ASSIGN expression{cout<<"aa -> var ASSIGN expression"<<endl;}
		;

bb:		IF boolean-exp THEN statements ENDIF {cout<<"bb -> IF boolean-exp THEN statements ENDIF"<<endl;}
		| IF boolean-exp THEN statements ELSE statements ENDIF {cout<<"IF boolean-exp THEN statements ELSE statements ENDIF"<<endl;}
		;

cc:		WHILE boolean-exp BEGINLOOP statements ENDLOOP {cout<<"cc  -> WHILE boolean-exp BEGINLOOP statements ENDLOOP"<<endl;}
		;

dd:		DO BEGINLOOP statements ENDLOOP WHILE boolean-exp {cout<<"DO BEGINLOOP statements ENDLOOP WHILE boolean-exp"<<endl;}
		;

ee:		READ var ii {cout<<"ee- > READ var ii"<<endl;}
		;

ii:		/*empty*/ {cout<<"ii -> epsilon"<<endl;}
		| COMMA var ii {cout<<"ii -> COMMA var ii"<<endl;}
		;

ff:		WRITE var ii {cout<<"ff -> WRITE var ii"<<endl;}
		;

gg:		CONTINUE {cout<<"gg -> CONTINUE"<<endl;}
		;

hh:		RETURN expression {cout<<"hh -> RETURN expression"<<endl;}
		;

boolean_expr:	relation_exprr {cout<<"boolean_expr -> relation_exprr"<<endl;}
		| boolean_expr OR relation_exprr {cout<<"boolean_expr -> boolean_expr OR relation_exprr"<<endl;}
		;

relation_exprr:	relation_expr {cout<< "relation_exprr -> relation_expr"<<endl;} 
		| relation_exprr AND relation_expr {cout<<"relation_exprr -> relation_exprr AND relation_expr"<<endl;}
		;

relation_expr:	rexpr{ cout<< "relation_expr -> rexpr"<<endl;}
		| NOT rexpr { cout<<"relation_expr -> NOT rexpr"<<endl;}
		;

rexpr:		expression comp expression {cout<< "rexpr -> expression comp expression" <<endl;}
		| TRUE {cout<< "rexpr -> TRUE" <<endl;}
		| FALSE {cout<< "rexpr -> FALSE" <<endl;}
		| L_PAREN boolean_expr R_PAREN {cout<< "rexpr -> LPAREN boolean_expr R_PAREN" <<endl;}
		;

comp:		EQ {cout<< "comp -> EQ" <<endl;}
		| NEQ {cout<< "comp -> NEQ" <<endl;}
		| LT {cout<< "comp -> LT" <<endl;}
		| GT {cout<< "comp -> GT" <<endl;}
		| LTE {cout<< "comp -> LTE" <<endl;}
		| GTE {cout<< "comp -> GTE" <<endl;}
		;

expression:	mul_expr expradd {cout<< "expression -> mult-expr expradd" <<endl;}
		;

expradd:	/*empty*/ {cout<< "expradd -> episolon" <<endl;}
		| ADD mul_expr expradd {cout<< "expradd -> ADD mul_expr expradd" << endl;}
		| MULT mul_expr expradd {cout<< "expradd -> MULT mul_expr expradd" << endl;}
		;

mul_expr:	term multi_term {cout<< "mul_expr -> term multi_term" <<endl;}
		;

multi_term:	/*empty*/ {cout<< "multi_term -> epsilon"<<endl;}
		| MULT term multi_term {cout<< "multi_term -> MULT term multi_term" <<endl;} 
		| DIV term multi_term {cout<< "multi_term -> DIV term multi_term" <<endl;}
		| MOD term multi_term {cout<< "multi_term -> MOD term multi_term" <<endl;}
		;

term:           posterm {cout<< "term -> posterm" <<endl;}
                | SUB posterm {cout<< "term -> SUB posterm"  <<endl;}
                | IDENTIFIER term_iden {cout<< "term -> "<<identifier_str <<" term_iden"<<endl;}
                ;

posterm:        var {cout<< "posterm -> var" <<endl;}
                | NUMBER {cout<< "posterm -> "<<int_val <<endl;}
                | L_PAREN expression R_PAREN {cout<< "posterm -> L_PAREN expression R_PAREN" <<endl;}
                ;

term_iden:      L_PAREN term_ex R_PAREN {cout<< "term_iden -> L_PAREN term_ex R_PAREN" <<endl;}
                | L_PAREN R_PAREN {cout<< "term_iden -> L_PAREN R_PAREN" <<endl;}
                ;

term_ex:        expression {cout<< "term_ex -> expression" <<endl;}
                | expression COMMA term_ex {cout<< "term_ex -> expression COMMA term_ex" <<endl;}
                ;

var:            IDENTIFIER {cout<<"var -> "<<identifier_str<<endl;}
                | IDENTIFIER L_SQUARE_BRACKET expression R_SQUARE_BRACKET {cout<<"var -> "<<identifier_str<<" L_SQUARE_BRACKET expression R_SQUARE_BRACKET"<<endl;} 
                ;
%%


