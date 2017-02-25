%{
#include "heading.h"
#include "tok.h"
int yyerror(char *s);
int yylineno = 1;
%}

	int row = 1; 
	int column = 1;

%%

		/*Reserved Keywords*/
function	{return FUNCTION;column=column+strlen(yytext);}
beginparams	{return BEGINPARAMS;column=column+strlen(yytext);}
endparams	{return ENDPARAMS;column=column+strlen(yytext);}
beginlocals	{return BEGINLOCALS;column=column+strlen(yytext);}
endlocals	{return ENDLOCALS;column=column+strlen(yytext);}
beginbody	{return BEGINBODY;column=column+strlen(yytext);}
endbody		{return ENDBODY;column=column+strlen(yytext);}
integer		{return INTEGER;column=column+strlen(yytext);}
array		{return ARRAY;column=column+strlen(yytext);}
of		{return OF;column=column+strlen(yytext);}
if		{return IF;column=column+strlen(yytext);}
then		{return THEN;column=column+strlen(yytext);}
endif		{return ENDIF;column=column+strlen(yytext);}
else		{return ELSE;column=column+strlen(yytext);}
while		{return WHILE;column=column+strlen(yytext);}
do		{return DO;column=column+strlen(yytext);}
beginloop	{return BEGINLOOP;column=column+strlen(yytext);}
endloop		{return ENDLOOP;column=column+strlen(yytext);}
continue	{return CONTINUE;column=column+strlen(yytext);}
read		{return READ;column=column+strlen(yytext);}
write		{return WRITE;column=column+strlen(yytext);}
and		{return AND;column=column+strlen(yytext);}
or		{return OR;column=column+strlen(yytext);}
not		{return NOT;column=column+strlen(yytext);}
true		{return TRUE;column=column+strlen(yytext);}
false		{return FALSE;column=column+strlen(yytext);}
return		{return RETURN;column=column+strlen(yytext);}
		/*END of Reserved keywords*/

		/*Operands*/
"-"		{return SUB; column=column+strlen(yytext);}
"+"		{return ADD;column=column+strlen(yytext);}
"*"		{return MULT;column=column+strlen(yytext);}
"/"		{return DIV;column=column+strlen(yytext);}
"%"		{return MOD;column=column+strlen(yytext);}


"=="		{return EQ;column=column+strlen(yytext);}
"<>"		{return NEQ;column=column+strlen(yytext);}
"<"		{return LT;column=column+strlen(yytext);}
">"		{return GT;column=column+strlen(yytext);}
"<="		{return LTE;column=column+strlen(yytext);}
">="		{return GTE;column=column+strlen(yytext);}
		/*END of operands*/



		/*Comments*/
[##].*		row = row + 1; column=1;/*No need to count columns in comments, As Single line comments can not be followed by any code*/      
		

		
";"		{return SEMICOLON;column=column+strlen(yytext);}
":"		{return COLON;column=column+strlen(yytext);}
","		{return COMMA;column=column+strlen(yytext);}
"("		{return LPAREN;column=column+strlen(yytext);}
")"		{return RPAREN;column=column+strlen(yytext);}
"["		{return LSQUARE;column=column+strlen(yytext);}
"]"		{return RSQUARE;column=column+strlen(yytext);}
":="		{return ASSIGN;column=column+strlen(yytext);}


		/*Identifiers and Numbers*/
[0-9]+					{yylval.val=atoi(yytext);return NUMBERS;column=column+strlen(yytext);}

[0-9|_][a-zA-Z0-9|_]*[a-zA-Z0-9|_]      {printf("Error at line %d, column %d: Identifier \"%s\" must begin with a letter\n",row,column,yytext);column=column+strlen(yytext);exit(0);} 
[a-zA-Z][a-zA-Z0-9|_]*[_]               {printf("Error at line %d, column %d: Identifier \"%s\" cannot end with an underscore\n",row,column,yytext);column=column+strlen(yytext);exit(0);} 
[a-zA-Z][a-zA-Z0-9|_]*[a-zA-Z0-9]	{yylval.op_val=new std::string(yytext);return IDENTIFIERS;column=column+strlen(yytext);/*Multi letter Identifier*/} 
[a-zA-Z][a-zA-Z0-9]*			{yylval.op_val=new std::string(yytext);return IDENTIFIERS;column=column+strlen(yytext);/*Single Letter Identifier and Multi letter Identifier with underscores */}


		/*Spaces and Tabs*/
[ ]         	column=column+1; 
[\t]		column=column+1;
[\n]		{yylineno++;row=row+1;column=1;}

		/*Unidentified Characters*/
.		{printf("Error at line %d, column %d :unrecognized symbol \"%s\"\n",row,column,yytext);exit(0);}
%%
