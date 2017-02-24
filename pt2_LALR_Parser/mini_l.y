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

%start	functions

%token	FUNCTION BEGINPARAMS ENDPARAMS BEGINLOCALS ENDLOCALS BEGINBODY ENDBODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE TRUE FALSE
%left MULT DIV MOD ADD SUB 
%left LT LTE GT GTE EQ NEQ
%right NOT
%left AND OR
%right ASSIGN

%%
prog		/*empty*/
		| function prog
		;

function	FUNCTION IDENTIFIER SEMICOLON BEGINPARAMS dec ENDPARAMS BEGINLOCALS dec ENDLOCALS BEGINBODY statements ENDBODY
		;

dec		/*empty*/
		| declaration SEMICOLON dec
		;

declaration	id COLON assign
		;

id		IDENTIFIER
		| IDENTIFIER COMMMA id
		;

assign		INTEGER
		| ARRAY L_SQUARE_BRACKER NUMBER R_SQUARE_BRACKET OF INTEGER
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


