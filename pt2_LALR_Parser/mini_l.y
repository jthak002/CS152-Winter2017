%{
#include <stdio.h>
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

%start	prog-start

%token	FUNCTION IDENTIFIERS BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE
%left MULT DIV MOD ADD SUB 
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND OR
%right ASSIGN
%type prog-start functions function declarations declaration statements 

%%

prog-start:	functions { cout<<"prog-start->functions"; }
		;	
	
functions:	/*empty*/{cout<<"function->epsilon"<<endl;}
		| function functions {cout<<"functions -> function functions"<<endl;}
		;

function:	FUNCTION IDENT identifier_str SEMICOLON BEGINPARAMS dec ENDPARAMS BEGINLOCALS dec ENDLOCALS BEGINBODY statements ENDBODY {cout<<"FUNCTION "<<identifier_str<<" SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY"<<endl;}
		;


declarations:	/*empty*/ {cout<<"declarations->epsilon\n"}
		| declaration SEMICOLON declarations {cout<<"declarations -> declaration SEMICOLON declarations"<<endl;}
		;

declaration	id COLON assign {cout<<"id COLON assign"<<endl;}
		;

id		IDENTIFIER {cout<<"id -> "<<identifier_str<<endl;}
		| IDENTIFIER COMMMA id {cout<<" id -> "<<identifier_str<<" COMMA id" << endl;}
		;

assign		INTEGER {cout<<"assign -> INTEGER"<<endl;}
		| ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {cout<<"assign -> ARRAY L_SQUARE_BRACKET "<<int_val<<" R_SQUARE_BRACKET OF INTEGER"<<endl;}
		;

statements	aa
		| bb
		| cc
		| dd
		| ee
		| ff
		| gg
		| hh
		;

aa		var ASSIGN expression
		;

bb		IF bool-exp THEN statement ENDIF
		| IF bool-exp THEN statement ELSE statement ENDIF
		;

cc		WHILE bool-exp BEGINLOOP statement ENDLOOP
		;

dd		DO BEGINLOOP statement ENDLOOP WHILE bool-exp
		;

ee 		READ var ii
		;

ii		/*empty*/
		| COMMA var ii
		;

ff		WRITE var ii
		;

gg		CONTINUE
		;

hh 		RETURN expression
		;

bool-expr	relation-exprr
		| bool-expr OR relation-exprr
		;

relation-exprr	relation-expr
		| relation-exprr AND relation-expr
		;

relation-expr	rexpr 
		| NOT rexpr
		;

rexpr		expression comp expression
		| TRUE
		| FALSE
		| L_PAREN bool-expr R_PAREN  
		;

comp		EQ
		| NEQ
		| LT 
		| GT
		| LTE
		| GTE
		;

expression	mul-expr expradd
		;

expradd		/*empty*/
		| ADD mul-expr expradd
		| MULT mul-expr expr-add
		;

mul-expr	term multi-term
		;

multi-term	/*empty*/
		| MULT term multi-term
		| DIV term multi-term
		| MOD term multi-term
		;

	
%%


