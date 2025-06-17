# Compilador-y-lenguaje-propio
Taller de Fundamentos de la Ciencia de Computación (creación de lenguaje y compilador propio)
Integrantes: Eros cortés y Lucas Trujillo

Para el desarrollo de este proyecto se hace uso de flex (analizador léxico) y bison (analizador sintactico).

Para compilar este proyecto se debe ingresar en la terminal/cmd los siguientes comandos:
bison -dy jappscript.y
flex jappscript.l
gcc y.tab.c lex.yy.c -o jappscript.exe
