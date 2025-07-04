%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
%}

DIGIT       [0-9]
FLOAT       {DIGIT}+"."{DIGIT}+

%%

"print"     {return PRINT;}
"else"      {return ELSE;}
"if"        {return IF;}
"while"     {return WHILE;}
"float"     {return FLOAT;}
"integer"   {return INTEGER;}
"string"    {return STRING;}
"void"      {return VOID;}
"and"       {return AND;}
"or"        {return OR;}
"input"     {return INPUT;}


"=="        {return EQ;}
"!="        {return NOEQ;}
"<="        {return MEEQ;}
">="        {return MAEQ;}
"<"         {return ME;}
">"         {return MA;}

"{"         {return LLLAVE;}
"}"         {return RLLAVE;}

"("         {return LPAREN;}
")"         {return RPAREN;}
";"         {return ';';}
"+"         {return '+';}
"-"         {return '-';}
"*"         {return '*';}
"/"         {return '/';}
"="         {return ASSIGN;}

[ \t\n]+    ; // Ignorar espacios

[0-9]+      { yylval.num = atoi(yytext); return NUMBER;}
FLOAT       { yylval.fval = atof(yytex); return FLOAT_NUM;}
[a-zA-Z_][a-zA-Z0-9_]* { yylval.id = strdup(yytext); return ID;}

.           { printf("Caracter no válido: %s\n", yytext);}

%%

int yywrap() { return 1;}