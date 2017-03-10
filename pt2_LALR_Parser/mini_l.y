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

prog_start:	functions { cout<<"prog_start->functions"<<endl; }
		;	
	
functions:	/*empty*/{cout<<"function->epsilon"<<endl;}
		| function functions {cout<<"functions -> function functions"<<endl;}
		;

function:	FUNCTION IDENTIFIERS SEMICOLON BEGINPARAMS declarations ENDPARAMS BEGINLOCALS declarations ENDLOCALS BEGINBODY statements ENDBODY {cout<<"FUNCTION IDENT "<<*($2)<<" SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY"<<endl;}
		;


declarations:	/*empty*/ {cout<<"declarations->epsilon\n"}
		| declaration SEMICOLON declarations {cout<<"declarations -> declaration SEMICOLON declarations"<<endl;}
		;

declaration:	id COLON assign {cout<<"id COLON assign"<<endl;}
		;

id:		IDENTIFIERS {cout<<"id -> IDENT "<<*($1)<<endl;}
		| IDENTIFIERS COMMA id {cout<<"id -> IDENT "<<*($1)<<" COMMA id" << endl;}
		;

assign:		INTEGER {cout<<"assign -> INTEGER"<<endl;}
		| ARRAY LSQUARE NUMBERS RSQUARE OF INTEGER {cout<<"assign -> ARRAY LSQUARE NUMBER "<<$3<<" RSQUARE OF INTEGER"<<endl;}
		;

statements:	statement SEMICOLON statements {cout<<"statements -> statement SEMICOLON statements"<<endl;}
		| statement SEMICOLON {cout<<"statements -> statement SEMICOLON"<<endl;}
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

bb:		IF boolean_expr THEN statements ENDIF {cout<<"bb -> IF boolean_expr THEN statements ENDIF"<<endl;}
		| IF boolean_expr THEN statements ELSE statements ENDIF {cout<<"IF boolean_expr THEN statements ELSE statements ENDIF"<<endl;}
		;

cc:		WHILE boolean_expr BEGINLOOP statements ENDLOOP {cout<<"cc  -> WHILE boolean_expr BEGINLOOP statements ENDLOOP"<<endl;}
		;

dd:		DO BEGINLOOP statements ENDLOOP WHILE boolean_expr {cout<<"DO BEGINLOOP statements ENDLOOP WHILE boolean_expr"<<endl;}
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
		| LPAREN boolean_expr RPAREN {cout<< "rexpr -> LPAREN boolean_expr RPAREN" <<endl;}
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

expradd:	/*empty*/ {cout<< "expradd -> epsilon" <<endl;}
		| ADD mul_expr expradd {cout<< "expradd -> ADD mul_expr expradd" << endl;}
		| SUB mul_expr expradd {cout<< "expradd -> SUB mul_expr expradd" << endl;}
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
                | IDENTIFIERS term_iden {cout<< "term -> IDENT "<<*($1)<<" term_iden"<<endl;}
                ;

posterm:        var {cout<< "posterm -> var" <<endl;}
                | NUMBERS {cout<< "posterm -> NUMBER "<<$1 <<endl;}
                | LPAREN expression RPAREN {cout<< "posterm -> LPAREN expression RPAREN" <<endl;}
                ;

term_iden:      LPAREN term_ex RPAREN {cout<< "term_iden -> LPAREN term_ex RPAREN" <<endl;}
                | LPAREN RPAREN {cout<< "term_iden -> LPAREN RPAREN" <<endl;}
                ;

term_ex:        expression {cout<< "term_ex -> expression" <<endl;}
                | expression COMMA term_ex {cout<< "term_ex -> expression COMMA term_ex" <<endl;}
                ;

var:            IDENTIFIERS {cout<<"var -> IDENT "<<*($1)<<endl;}
                | IDENTIFIERS LSQUARE expression RSQUARE {cout<<"var -> IDENT "<<*($1)<<" LSQUARE expression RSQUARE"<<endl;} 
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

