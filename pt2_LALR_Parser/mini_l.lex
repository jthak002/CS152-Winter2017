%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
%}

	int row = 1; 
	int column = 1;

%%

		/*Reserved Keywords*/
function	{yylval.keyw=new std::string("FUNCTION"); return FUNCTION;column=column+strlen(yytext);}
beginparams	{yylval.keyw=new std::string("BEGIN_PARAMS"); return BEGINPARAMS;column=column+strlen(yytext);}
endparams	{yylval.keyw=new std::string("END_PARAMS\n");return ENDPARAMS;column=column+strlen(yytext);}
beginlocals	{yylval.keyw=new std::string("BEGIN_LOCALS\n");return BEGINLOCALS;column=column+strlen(yytext);}
endlocals	{yylval.keyw=new std::string("END_LOCALS\n");return ENDLOCALS;column=column+strlen(yytext);}
beginbody	{yylval.keyw=new std::string("BEGIN_BODY\n");return BEGINBODY;column=column+strlen(yytext);}
endbody		{yylval.keyw=new std::string("END_BODY\n");return ENDBODY;column=column+strlen(yytext);}
integer		{yylval.keyw=new std::string("INTEGER\n");return INTEGER;column=column+strlen(yytext);}
array		{yylval.keyw=new std::string("ARRAY\n");return ARRAY;column=column+strlen(yytext);}
of		{yylval.keyw=new std::string("OF\n");return OF;column=column+strlen(yytext);}
if		{yylval.keyw=new std::string("IF\n");return IF;column=column+strlen(yytext);}
then		{yylval.keyw=new std::string("THEN\n");return THEN;column=column+strlen(yytext);}
endif		{yylval.keyw=new std::string("ENDIF\n")return ENDIF;column=column+strlen(yytext);}
else		{yylval.keyw=new std::string("ELSE\n");return ELSE;column=column+strlen(yytext);}
while		{yylval.keyw=new std::string("WHILE\n");return WHILE;column=column+strlen(yytext);}
do		{yylval.keyw=new std::string("DO\n");return DO;column=column+strlen(yytext);}
beginloop	{yylval.keyw=new std::string("BEGINLOOP\n");return BEGINLOOP;column=column+strlen(yytext);}
endloop		{yylval.keyw=new std::string("ENDLOOP\n");return ENDLOOP;column=column+strlen(yytext);}
continue	{yylval.keyw=new std::string("CONTINUE\n");return CONTINUE;column=column+strlen(yytext);}
read		{yylval.keyw=new std::string("READ\n");return READ;column=column+strlen(yytext);}
write		{yylval.keyw=new std::string("WRITE\n");return WRITE;column=column+strlen(yytext);}
and		{yylval.keyw=new std::string("AND\n");return AND;column=column+strlen(yytext);}
or		{yylval.keyw=new std::string("OR\n");return OR;column=column+strlen(yytext);}
not		{yylval.keyw=new std::string("NOT\n");return NOT;column=column+strlen(yytext);}
true		{yylval.keyw=new std::string("TRUE\n");return TRUE;column=column+strlen(yytext);}
false		{yylval.keyw=new std::string("FALSE\n");return FALSE;column=column+strlen(yytext);}
		/*END of Reserved keywords*/

		/*Operands*/
"-"		{yylval.op_val=new std::string(yytext);return SUB; column=column+strlen(yytext);}
"+"		{yylval.op_val=new std::string(yytext);return ADD;column=column+strlen(yytext);}
"*"		{yylval.op_val=new std::string(yytext);return MULT;column=column+strlen(yytext);}
"/"		{yylval.op_val=new std::string(yytext);return DIV;column=column+strlen(yytext);}
"%"		{yylval.op_val=new std::string(yytext);return MOD;column=column+strlen(yytext);}


"=="		{yylval.rel_op=new std::string(yytext); return EQ;column=column+strlen(yytext);}
"<>"		{yylval.rel_op=new std::string(yytext);return NEQ;column=column+strlen(yytext);}
"<"		{yylval.rel_op=new std::string(yytext);return LT;column=column+strlen(yytext);}
">"		{yylval.rel_op=new std::string(yyext);return GT;column=column+strlen(yytext);}
"<="		{yylval.rel_op=new std::string(yytext);return LTE;column=column+strlen(yytext);}
">="		{yylval.rel_op=new std::string(yytext);return GTE;column=column+strlen(yytext);}
		/*END of operands*/



		/*Comments*/
[##].*		row = row + 1; column=1;/*No need to count columns in comments, As Single line comments can not be followed by any code*/      
		

		
";"		{yylval.op_val=new std::string(yytext);return SEMICOLON;column=column+strlen(yytext);}
":"		{yylval.op_val=new std::string(yytext);return COLON;column=column+strlen(yytext);}
","		{yylval.op_val=new std::string(yytext);return COMMA;column=column+strlen(yytext);}
"("		{yylval.op_val=new std::string(yytext);return LPAREN;column=column+strlen(yytext);}
")"		{yylval.op_val=new std::string(yytext);return RPAREN;column=column+strlen(yytext);}
"["		{yylval.op_val=new std::string(yytext);return LSQUARE;column=column+strlen(yytext);}
"]"		{yylval.op_val=new std::string(yytext);return RSQUARE;column=column+strlen(yytext);}
":="		{yylval.op_val=new std::string(yytext);return ASSIGN;column=column+strlen(yytext);}


		/*Identifiers and Numbers*/
[0-9]+					{yylval.int_val=atoi(yytext);column=column+strlen(yytext);}

[0-9|_][a-zA-Z0-9|_]*[a-zA-Z0-9|_]      {printf("Error at line %d, column %d: Identifier \"%s\" must begin with a letter\n",row,column,yytext);column=column+strlen(yytext);exit(0);} 
[a-zA-Z][a-zA-Z0-9|_]*[_]               {printf("Error at line %d, column %d: Identifier \"%s\" cannot end with an underscore\n",row,column,yytext);column=column+strlen(yytext);exit(0);} 
[a-zA-Z][a-zA-Z0-9|_]*[a-zA-Z0-9]	{string s ="IDENT"+ yytext;yylval.indentifier_str=new std::string(s);column=column+strlen(yytext);/*Multi letter Identifier*/} 
[a-zA-Z][a-zA-Z0-9]*			{string s ="IDENT"+ yytext;yylval.indentifier_str=new std::string(s);column=column+strlen(yytext);/*Single Letter Identifier and Multi letter Identifier with underscores */}


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

