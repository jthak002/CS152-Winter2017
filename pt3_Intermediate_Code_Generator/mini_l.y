%{
#include "heading.h"
int yyerror (char* s);
int yylex (void);
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
		;


declarations:	/*empty*/ 
		| declaration SEMICOLON declarations 
		;

declaration:	id COLON assign
		;

id:		IDENTIFIERS 
		| IDENTIFIERS COMMA id 
		;

assign:		INTEGER
		| ARRAY LSQUARE NUMBERS RSQUARE OF INTEGER
		;

statements:	statement SEMICOLON statements
		| statement SEMICOLON 
		;

statement:	aa
		| bb
		| cc
		| dd
		| ee
		| ff
		| gg
		| hh
		;

aa:		var ASSIGN expression
		;

bb:		IF boolean_expr THEN statements ENDIF 
		| IF boolean_expr THEN statements ELSE statements ENDIF
		;

cc:		WHILE boolean_expr BEGINLOOP statements ENDLOOP 
		;

dd:		DO BEGINLOOP statements ENDLOOP WHILE boolean_expr 
		;

ee:		READ var ii 
		;

ii:		/*empty*/ 
		| COMMA var ii 
		;

ff:		WRITE var ii 
		;

gg:		CONTINUE 
		;

hh:		RETURN expression 
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
		;

comp:		EQ 
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
		| SUB mul_expr expradd 
		;

mul_expr:	term multi_term 
		;

multi_term:	/*empty*/ 
		| MULT term multi_term 
		| DIV term multi_term 
		| MOD term multi_term 
		;

term:           posterm 
                | SUB posterm 
                | IDENTIFIERS term_iden 
                ;

posterm:        var 
                | NUMBERS
                | LPAREN expression RPAREN
                ;

term_iden:      LPAREN term_ex RPAREN
                | LPAREN RPAREN
                ;

term_ex:        expression 
                | expression COMMA term_ex 
                ;

var:            IDENTIFIERS 
                | IDENTIFIERS LSQUARE expression RSQUARE 
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

