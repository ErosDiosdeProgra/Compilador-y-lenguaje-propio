%{
    #include <stdio.h>
    #include <string.h>
    #include "jappscript.tab.h"
    void yyerror(char *);
%}

%option noyywrap

DIGIT [0-9]
NUM {DIGIT}+

%%

[a-zA-Z_][a-zA-Z0-9]*   {yylval.str = strdup(yytext); return(ID);}
{NUM}                   {yylval = atoi(yytext); return NUMBER;}
[-()+*/;]               {return *yytext;}
"evaluar"               {return EVALUAR;}
[[:blanck:]];
.                       yyerror("Caracter invalido");
do                      {return(DO);}
else                    {return(ELSE);}
if                      {return(IF);}
while                   {return(WHILE);}
integer                 {return(INTEGER);}
string                  {return(STRING);}
void                    {return(VOID);}
and                     {return(AND);}
or                      {return(OR);}

==                      {return(EQ);}
!=                      {return(NOEQ);}
<=                      {return(MEEQ);}
>=                      {RETURN(MAEQ);}
<                       {return(ME);}
>                       {return(MA);}

+                       {return(SUM);}
-                       {return(RES);}
*                       {return(MULT);}
/                       {return(DIV);}

{                       {return(LLLAVE);}
}                       {return(RLLAVE);}
(                       {return(LPARENT);}
)                       {return(RPARENT);}
;                       {return(PCOMA);}
=                       {return(ASIGNAR);}
":="                    {return (ASSGNOP);}

[ \t\n]+ /* blanck, tab, new line: eat up whitespace */     {return(yytext[0]);}



%%