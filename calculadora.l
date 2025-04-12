%{
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"
    void yyerror(char *);
%}

%option noyywrap

DIGIT [0-9]
NUM {DIGIT}+

%%

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
":="                    {return (ASSGNOP);}
[ \t\n]+ /* blanck, tab, new line: eat up whitespace */     {return(yytext[0]);}

%%