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
    printf("- Error: Variable '%s' no declarada. Se usa 0\n", nombre);
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
            printf("- Error: Límite de variables alcanzado\n");
        }
    }
}

typedef struct ASTNode {
    struct ASTNode* cond; //condicional
    struct ASTNode* body; //cuerpo del while
    int (*eval)(struct ASTNode*);
    void (*exec)(struct ASTNode*);
} ASTNode;

ASTNode* new_while(ASTNode* cond; ASTNode* body);
void ejecutar(ASTNode* node);

%}

%union {
    int num;
    char* id;
    struct ASTNode* node;
}

%token <num> NUMBER
%token <id> ID

%token IF ELSE
%token WHILE FOR
%token INTEGER STRING VOID
%token AND OR
%token EQ NOEQ MEEQ MAEQ ME MA
%token PRINT
%token LPAREN RPAREN
%token LLLAVE RLLAVE
%token ASSIGN
%token FUNCTION
%token RETURN
%token INPUT
%token ';'


%left '+' '-'
%left '*' '/'
%left EQ NOEQ MEEQ MAEQ ME MA

%type <num> expr
%type <node> block

%%

program:
    statements
    ;

statements:
      /* vacío */
    | statements statement
    ;

statement:
    
      IF LPAREN expr RPAREN block                        {if($3) ejecutar($5);}
    | IF LPAREN expr RPAREN block ELSE block             {if($3) ejecutar($5); else ejecutar($7);}
    | INTEGER ID ASSIGN expr ';'                         {asignar_variable($2, $4);}
    | ID ASSIGN expr ';'                                 {asignar_variable($1, $3);}
    | STRING ID ASSIGN expr ';'                          {printf("Asignacion de string\n");}
    | VOID ID ';'                                        {printf("Declaracion de void '%s'\n", $2); free($2);}
    | WHILE LPAREN expr RPAREN block {
        ASTNode* cond_node = malloc(sizeof(ASTNode));
        cond_node -> eval = [](ASTNode* n) {return $3;};
        ASTNode* w = new_while(cond_node, $5);
        ejecutar(w);
    }
    | FOR LPAREN statement expr ';' expr ';' expr statement RPAREN block
    | PRINT LPAREN expr RPAREN ';'                       {printf("Imprimir: %d\n", $3);}
    | INPUT LPAREN ID RPAREN ';' {
        int val;
        printf("Ingrese valor para %s: ", $3);
        scanf("%d", &val);
        asignar_variable($3, val);
        free($3);
      }
    | RETURN expr ';'
    | function_dec
    ;

function_dec:
    FUNCTION return_tipo ID LPAREN RPAREN block;

return_tipo:
    VOID        { $$ = "void";}
    | INTEGER   { $$ = "integer";}
    | STRING    { $$ = "string";}
    ;

block:
      LLLAVE statements RLLAVE
    ;

expr:
      expr '+' expr      { $$ = $1 + $3;}
    | expr '-' expr      { $$ = $1 - $3;}
    | expr '*' expr      { $$ = $1 * $3;}
    | expr '/' expr      { 
        if ($3 == 0){
            yyerror("Invalido, division por cero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }}
    | expr EQ expr       { $$ = ($1 == $3);}
    | expr NOEQ expr     { $$ = ($1 != $3);}
    | expr MEEQ expr     { $$ = ($1 <= $3);}
    | expr MAEQ expr     { $$ = ($1 >= $3);}
    | expr ME expr       { $$ = ($1 < $3);}
    | expr MA expr       { $$ = ($1 > $3);}
    | expr AND expr      { $$ = ($1 && $3);}
    | expr OR expr       { $$ = ($1 || $3);}
    | '(' expr ')'       { $$ = $2;}
    | NUMBER             { $$ = $1;}

    | ID { $$ = obtener_valor($1); free($1);}
    ;

%%

ASTNode* new_while (ASTNode* cond, ASTNode* body){
    ASTNode* w = malloc(sizeof(ASTNode));
    w -> cond = cond;
    w -> body = body;
    return w;
}

void ejecutar(ASTNode* node){
    if(!node) return;
    while(node -> cond -> eval(node -> cond)){
        if(node -> body && node -> body -> exec)
            ndoe -> body -> exec(ndoe -> body);
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Error de sintaxis: %s\n", s);
}

int main() {
    printf("Bienvenido a jappcript!\n");
    return yyparse();
}
