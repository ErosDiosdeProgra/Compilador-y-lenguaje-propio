%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_VARS 100

void yyerror(const char *s);
int yylex(void);

typedef struct ASTNodeList {
    struct ASTNode* stmt;
    struct ASTNodeList* next;
} ASTNodeList;

typedef struct ASTNode {
    struct ASTNode* cond;
    struct ASTNode* body;
    ASTNodeList* stmts; 
    int valor_constante;
    char* nombre_variable; 
    int (*eval)(struct ASTNode*);
    void (*exec)(struct ASTNode*);
} ASTNode;

void exec_block(ASTNode* block) {
    ASTNodeList* curr = block->stmts;
    while (curr) {
        if (curr->stmt && curr->stmt->exec)
            curr->stmt->exec(curr->stmt);
        curr = curr->next;
    }
}

ASTNode* new_block_node(ASTNodeList* stmts) {
    ASTNode* node = malloc(sizeof(ASTNode));
    node->stmts = stmts;
    node->exec = exec_block;
    return node;
}

ASTNodeList* append_statement(ASTNodeList* list, ASTNode* stmt) {
    ASTNodeList* new_node = malloc(sizeof(ASTNodeList));
    new_node->stmt = stmt;
    new_node->next = NULL;

    if (!list) return new_node;

    ASTNodeList* curr = list;
    while (curr->next) curr = curr->next;
    curr->next = new_node;
    return list;
}


int eval_constante(ASTNode* node) {
    return node->valor_constante;
}

ASTNode* new_while(ASTNode* cond, ASTNode* body);
void ejecutar(ASTNode* node);

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

void exec_print(ASTNode* node) {
    printf("%d\n", node->valor_constante);
}

void exec_input(ASTNode* node) {
    int val;
    printf("Ingrese valor para %s: ", node->nombre_variable);
    scanf("%d", &val);
    asignar_variable(node->nombre_variable, val);
    free(node->nombre_variable);
    node->nombre_variable = NULL;
}


%}

%union {
    int num;
    char* id;
    struct ASTNode* node;
    struct ASTNodeList* list;
}


%token <num> NUMBER
%token <id> ID

%token IF ELSE
%token WHILE 
%token INTEGER STRING VOID
%token AND OR
%token EQ NOEQ MEEQ MAEQ ME MA
%token PRINT
%token LPAREN RPAREN
%token LLLAVE RLLAVE
%token ASSIGN
%token INPUT
%token ';'


%left '+' '-'
%left '*' '/'
%left EQ NOEQ MEEQ MAEQ ME MA

%type <num> expr
%type <node> block
%type <node> statement_node
%type <list> statements_ast

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
                                    cond_node->valor_constante = $3;
                                    cond_node->eval = eval_constante;

                                    ASTNode* w = new_while(cond_node, $5);
                                    ejecutar(w);
                                }

    | PRINT LPAREN expr RPAREN ';'                       {printf("Imprimir: %d\n", $3);}
    | INPUT LPAREN ID RPAREN ';' {
        int val;
        printf("Ingrese valor para %s: ", $3);
        scanf("%d", &val);
        asignar_variable($3, val);
        free($3);
      }
    

block:
      LLLAVE statements_ast RLLAVE      { $$ = new_block_node($2); }
    ;

statements_ast:
      /* vacío */                       { $$ = NULL; }
    | statements_ast statement_node     { $$ = append_statement($1, $2); }
    ;

statement_node:
      INTEGER ID ASSIGN expr ';' {
          asignar_variable($2, $4);
          $$ = NULL;
      }
    | ID ASSIGN expr ';' {
          asignar_variable($1, $3);
          $$ = NULL;
      }
    | PRINT LPAREN expr RPAREN ';' {
          ASTNode* n = malloc(sizeof(ASTNode));
          n->valor_constante = $3;
          n->exec = exec_print;
          $$ = n;
      }
    | INPUT LPAREN ID RPAREN ';' {
          ASTNode* n = malloc(sizeof(ASTNode));
          n->nombre_variable = $3;
          n->exec = exec_input;
          $$ = n;
      }
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
            node -> body -> exec(node -> body);
    }
}

void yyerror(const char *s) {
    fprintf(stderr, "Error de sintaxis: %s\n", s);
}

int main() {
    printf("Bienvenido a jappcript!\n");
    return yyparse();
}