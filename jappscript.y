%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

// Tabla dinámica para variables
typedef struct Variable {
    char* nombre;
    int valor;
    struct Variable* siguiente;
} Variable;

Variable* tabla_variables = NULL;

Variable* buscar_variable(const char* nombre) {
    Variable* actual = tabla_variables;
    while (actual != NULL) {
        if (strcmp(actual->nombre, nombre) == 0) return actual;
        actual = actual->siguiente;
    }
    return NULL;
}

void asignar_variable(const char* nombre, int valor) {
    Variable* var = buscar_variable(nombre);
    if (var != NULL) {
        var->valor = valor;
    } else {
        var = malloc(sizeof(Variable));
        var->nombre = strdup(nombre);
        var->valor = valor;
        var->siguiente = tabla_variables;
        tabla_variables = var;
    }
}

int obtener_valor_variable(const char* nombre, int* existe) {
    Variable* var = buscar_variable(nombre);
    if (var != NULL) {
        *existe = 1;
        return var->valor;
    } else {
        *existe = 0;
        return 0;
    }
}

void liberar_variables() {
    Variable* actual = tabla_variables;
    while (actual != NULL) {
        Variable* siguiente = actual->siguiente;
        free(actual->nombre);
        free(actual);
        actual = siguiente;
    }
}
%}

%union {
    int num;
    char* id;
}

%token <num> NUMBER
%token <id> ID
%token EVALUAR ASSIGN
%left '+' '-'
%left '*' '/'

%type <num> expr stmt programa

%%

programa:
    programa stmt
  | /* vacío */
  ;

stmt:
    EVALUAR '(' expr ')' ';' {
        printf("Resultado: %d\n", $3);
    }
  | ID ASSIGN expr ';' {
        asignar_variable($1, $3);
        free($1);
    }
  | expr ';' {
        printf("Evaluar expr: %d\n", $1);
    }
  ;

expr:
    expr '+' expr { $$ = $1 + $3; }
  | expr '-' expr { $$ = $1 - $3; }
  | expr '*' expr { $$ = $1 * $3; }
  | expr '/' expr {
        if ($3 == 0) {
            fprintf(stderr, "Error: división por cero\n");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
  | NUMBER        { $$ = $1; }
  | ID            {
        int existe;
        int val = obtener_valor_variable($1, &existe);
        if (!existe) {
            fprintf(stderr, "Error: variable '%s' no inicializada\n", $1);
            val = 0;
        }
        $$ = val;
        free($1);
    }
  | '(' expr ')'  { $$ = $2; }
  ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error de sintaxis: %s\n", s);
}

int main() {
    int res = yyparse();
    liberar_variables();
    return res;
}
