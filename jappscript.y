%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_VARS 100

void yyerror(const char *s);
int yylex(void);

typedef struct {
    char nombre[64];
    int valor;
} Variable;

Variable tabla_vars[MAX_VARS];
int num_vars = 0;

int buscar_variable(const char* nombre) {
    for (int i = 0; i < num_vars; i++) {
        if (strcmp(tabla_vars[i].nombre, nombre) == 0) return i;
    }
    return -1;
}

int obtener_valor(const char* nombre) {
    int idx = buscar_variable(nombre);
    if (idx >= 0) return tabla_vars[idx].valor;
    printf("→ Error: Variable '%s' no declarada. Se usa 0\n", nombre);
    return 0;
}

void asignar_variable(const char* nombre, int valor) {
    int idx = buscar_variable(nombre);
    if (idx >= 0) {
        tabla_vars[idx].valor = valor;
    } else {
        if (num_vars < MAX_VARS) {
            strcpy(tabla_vars[num_vars].nombre, nombre);
            tabla_vars[num_vars].valor = valor;
            num_vars++;
        } else {
            printf("→ Error: Límite de variables alcanzado\n");
        }
    }
}
%}

%union {
    int num;
    char* id;
}

%token <num> NUMBER
%token <id> ID

%token IF ELSE
%token DO WHILE
%token INTEGER STRING VOID
%token AND OR
%token EQ NOEQ MEEQ MAEQ ME MA
%token PRINT
%token LPAREN RPAREN
%token LLLAVE RLLAVE
%token ASSIGN
%token EVALUAR
%token FUNCTION
%token INPUT


%left '+' '-'
%left '*' '/'
%left EQ NOEQ MEEQ MAEQ ME MA

%type <num> expr

%%

program:
    statements
    ;

statements:
      /* vacío */
    | statements statement
    ;

statement:
    
      IF LPAREN expr RPAREN block                        { printf("→ IF sin else (cond: %d)\n", $3); }
    | IF LPAREN expr RPAREN block ELSE block             { printf("→ IF con else (cond: %d)\n", $3); }
    | INTEGER ID ASSIGN expr ';'                         { asignar_variable($2, $4); }
    | ID ASSIGN expr ';'                                 { asignar_variable($1, $3);}
    | PRINT LPAREN expr RPAREN ';'                       { printf("→ Imprimir: %d\n", $3); }
    | INPUT LPAREN ID RPAREN ';' {
        int val;
        printf("Ingrese valor para %s: ", $3);
        scanf("%d", &val);
        asignar_variable($3, val);
      }
    ;

block:
      LLLAVE statements RLLAVE
    ;

expr:
      expr '+' expr      { $$ = $1 + $3; }
    | expr '-' expr      { $$ = $1 - $3; }
    | expr '*' expr      { $$ = $1 * $3; }
    | expr '/' expr      { $$ = $1 / $3; }
    | expr EQ expr       { $$ = ($1 == $3); }
    | expr NOEQ expr     { $$ = ($1 != $3); }
    | expr MEEQ expr     { $$ = ($1 <= $3); }
    | expr MAEQ expr     { $$ = ($1 >= $3); }
    | expr ME expr       { $$ = ($1 < $3); }
    | expr MA expr       { $$ = ($1 > $3); }
    | '(' expr ')'       { $$ = $2; }
    | NUMBER             { $$ = $1; }

    | ID { $$ = obtener_valor($1); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error de sintaxis: %s\n", s);
}

int main() {
    printf("Bienvenido a jappcript!\n");
    return yyparse();
}
