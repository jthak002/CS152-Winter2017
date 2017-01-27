%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
%}

	int row = 1; 
	int column = 1;

%%

		/*Reserved Keywords*/
function	{printf("FUNCTION\n");column=column+strlen(yytext);}
beginparams	{printf("BEGIN_PARAMS\n");column=column+strlen(yytext);}
endparams	{printf("END_PARAMS\n");column=column+strlen(yytext);}
beginlocals	{printf("BEGIN_LOCALS\n");column=column+strlen(yytext);}
endlocals	{printf("END_LOCALS\n");column=column+strlen(yytext);}
beginbody	{printf("BEGIN_BODY\n");column=column+strlen(yytext);}
endbody		{printf("END_BODY\n");column=column+strlen(yytext);}
integer		{printf("INTEGER\n");column=column+strlen(yytext);}
array		{printf("ARRAY\n");column=column+strlen(yytext);}
of		{printf("OF\n");column=column+strlen(yytext);}
if		{printf("IF\n");column=column+strlen(yytext);}
then		{printf("THEN\n");column=column+strlen(yytext);}
endif		{printf("ENDIF\n");column=column+strlen(yytext);}
else		{printf("ELSE\n");column=column+strlen(yytext);}
while		{printf("WHILE\n");column=column+strlen(yytext);}
do		{printf("DO\n");column=column+strlen(yytext);}
beginloop	{printf("BEGINLOOP\n");column=column+strlen(yytext);}
endloop		{printf("ENDLOOP\n");column=column+strlen(yytext);}
continue	{printf("CONTINUE\n");column=column+strlen(yytext);}
read		{printf("READ\n");column=column+strlen(yytext);}
write		{printf("WRITE\n");column=column+strlen(yytext);}
and		{printf("AND\n");column=column+strlen(yytext);}
or		{printf("OR\n");column=column+strlen(yytext);}
not		{printf("NOT\n");column=column+strlen(yytext);}
true		{printf("TRUE\n");column=column+strlen(yytext);}
false		{printf("FALSE\n");column=column+strlen(yytext);}
		/*END of Reserved keywords*/

		/*Operands*/
"-"		{printf("SUB\n");column=column+strlen(yytext);}
"+"		{printf("ADD\n");column=column+strlen(yytext);}
"*"		{printf("MULT\n");column=column+strlen(yytext);}
"/"		{printf("DIV\n");column=column+strlen(yytext);}
"%"		{printf("MOD\n");column=column+strlen(yytext);}


"=="		{printf("EQ\n");column=column+strlen(yytext);}
"<>"		{printf("NEQ\n");column=column+strlen(yytext);}
"<"		{printf("LT\n");column=column+strlen(yytext);}
">"		{printf("GT\n");column=column+strlen(yytext);}
"<="		{printf("LTE\n");column=column+strlen(yytext);}
">="		{printf("GTE\n");column=column+strlen(yytext);}
		/*END of operands*/



		/*Comments*/
[##].*		row = row + 1; column=1;/*No need to count columns in comments, As Single line comments can not be followed by any code*/      
		

		
";"		{printf("SEMICOLON\n");column=column+strlen(yytext);}
":"		{printf("COLON\n");column=column+strlen(yytext);}
","		{printf("COMMA\n");column=column+strlen(yytext);}
"("		{printf("L_PAREN\n");column=column+strlen(yytext);}
")"		{printf("R_PAREN\n");column=column+strlen(yytext);}
"["		{printf("L_SQUARE_BRACKET\n");column=column+strlen(yytext);}
"]"		{printf("R_SQUARE_BRACKET\n");column=column+strlen(yytext);}
":="		{printf("ASSIGN\n");column=column+strlen(yytext);}


		/*Identifiers and Numbers*/
[0-9]+					{printf("NUMBER %s\n",yytext);column=column+strlen(yytext);}

[0-9|_][a-zA-Z0-9|_]*[a-zA-Z0-9|_]      {printf("Error at line %d, column %d: Identifier \"%s\" must begin with a letter\n",row,column,yytext);column=column+strlen(yytext);exit(0);} 
[a-zA-Z][a-zA-Z0-9|_]*[_]               {printf("Error at line %d, column %d: Identifier \"%s\" cannot end with an underscore\n",row,column,yytext);column=column+strlen(yytext);exit(0);} 
[a-zA-Z][a-zA-Z0-9|_]*[a-zA-Z0-9]	{printf("IDENT %s\n", yytext);column=column+strlen(yytext);/*Multi letter Identifier*/} 
[a-zA-Z][a-zA-Z0-9]*			{printf("IDENT %s\n", yytext);column=column+strlen(yytext);/*Single Letter Identifier and Multi letter Identifier with underscores */}


		/*Spaces and Tabs*/
[ ]         	column=column+1; 
[\t]		column=column+1;
[\n]		{row=row+1;column=1;}

		/*Unidentified Characters*/
.		{printf("Error at line %d, column %d :unrecognized symbol \"%s\"\n",row,column,yytext);exit(0);}
%%


int main(int argc, char* argv[])
{
    if(argc == 2)
    {
	yyin = fopen(argv[1],"r");
	yylex();
	fclose(yyin);
    }
    else
        yylex();
}

