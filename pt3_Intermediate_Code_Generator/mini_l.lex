%{
#include "heading.h"
#include "tok.h"
int yyerror(char *s);
int yylineno = 1;
%}

	int row = 1;
	int column = 1;
	string ops ="";
%%

		/*Reserved Keywords*/
function	{ops=ops+"func ";column=column+strlen(yytext);return FUNCTION;}
beginparams	{column=column+strlen(yytext);return BEGINPARAMS;}
endparams	{column=column+strlen(yytext);return ENDPARAMS;}
beginlocals	{column=column+strlen(yytext);return BEGINLOCALS;}
endlocals	{column=column+strlen(yytext);return ENDLOCALS;}
beginbody	{column=column+strlen(yytext);return BEGINBODY;}
endbody		{column=column+strlen(yytext);return ENDBODY;}
integer		{ops.insert(0,".");column=column+strlen(yytext);return INTEGER;}
array		{ops.insert(0,".[] ");column=column+strlen(yytext);return ARRAY;}
of		{column=column+strlen(yytext);return OF;}
if		{column=column+strlen(yytext);return IF;}
then		{column=column+strlen(yytext);return THEN;}
endif		{column=column+strlen(yytext);return ENDIF;}
else		{column=column+strlen(yytext);return ELSE;}
while		{column=column+strlen(yytext);return WHILE;}
do		{column=column+strlen(yytext);return DO;}
beginloop	{column=column+strlen(yytext);return BEGINLOOP;}
endloop		{column=column+strlen(yytext);return ENDLOOP;}
continue	{column=column+strlen(yytext);return CONTINUE;}
read		{column=column+strlen(yytext);return READ;}
write		{column=column+strlen(yytext);return WRITE;}
and		{column=column+strlen(yytext);return AND;}
or		{column=column+strlen(yytext);return OR;}
not		{column=column+strlen(yytext);return NOT;}
true		{column=column+strlen(yytext);return TRUE;}
false		{column=column+strlen(yytext);return FALSE;}
return		{column=column+strlen(yytext);return RETURN;}
		/*END of Reserved keywords*/

		/*Operands*/
"-"		{column=column+strlen(yytext);return SUB; }
"+"		{column=column+strlen(yytext);return ADD;}
"*"		{column=column+strlen(yytext);return MULT;}
"/"		{column=column+strlen(yytext);return DIV;}
"%"		{column=column+strlen(yytext);return MOD;}


"=="		{column=column+strlen(yytext);return EQ;}
"<>"		{column=column+strlen(yytext);return NEQ;}
"<"		{column=column+strlen(yytext);return LT;}
">"		{column=column+strlen(yytext);return GT;}
"<="		{column=column+strlen(yytext);return LTE;}
">="		{column=column+strlen(yytext);return GTE;}
		/*END of operands*/



		/*Comments*/
[##].*		row = row + 1; column=1;/*No need to count columns in comments, As Single line comments can not be followed by any code*/



";"		{column=column+strlen(yytext);return SEMICOLON;}
":"		{column=column+strlen(yytext);return COLON;}
","		{column=column+strlen(yytext);return COMMA;}
"("		{column=column+strlen(yytext);return LPAREN;}
")"		{column=column+strlen(yytext);return RPAREN;}
"["		{column=column+strlen(yytext);return LSQUARE;}
"]"		{column=column+strlen(yytext);return RSQUARE;}
":="		{column=column+strlen(yytext);return ASSIGN;}


		/*Identifiers and Numbers*/
[0-9]+					{column=column+strlen(yytext);yylval.val=atoi(yytext);return NUMBERS;}

[0-9|_][a-zA-Z0-9|_]*[a-zA-Z0-9|_]      {printf("LEXER Error at line %d, column %d: Identifier \"%s\" must begin with a letter\n",row,column,yytext);column=column+strlen(yytext); exit(1);}
[a-zA-Z][a-zA-Z0-9|_]*[_]               {printf("LEXER Error at line %d, column %d: Identifier \"%s\" cannot end with an underscore\n",row,column,yytext);column=column+strlen(yytext);exit(1);}
[a-zA-Z][a-zA-Z0-9|_]*[a-zA-Z0-9]	{ops=ops+yytext; column=column+strlen(yytext);yylval.op_val=new std::string(yytext);return IDENTIFIERS;/*Multi letter Identifier*/}
[a-zA-Z][a-zA-Z0-9]*			{ops=ops+yytext; column=column+strlen(yytext);yylval.op_val=new std::string(yytext);return IDENTIFIERS;/*Single Letter Identifier and Multi letter Identifier with underscores */}


		/*Spaces and Tabs*/
[ ]         	column=column+1;
[\t]		column=column+1;
[\n]		{cout<<ops<<endl;ops.clear(); yylineno++;row=row+1;column=1;}

		/*Unidentified Characters*/
.		{printf("LEXER Error at line %d, column %d :unrecognized symbol \"%s\"\n",row,column,yytext);exit(1);}
%%
