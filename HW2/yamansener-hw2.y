%{
#include <stdio.h>
void yyerror (const char *s) /* Called by yyparse on error */
{
    //printf ("%s\n", s);
}
%}
%token tSTRING tGET tSET tFUNCTION tPRINT tIF tRETURN tINC tDEC tGT tEQUALITY tLT tLEQ tGEQ tIDENT tNUM

%% /* Grammar rules and actions follow */

prog:           '[' ']'
            |   '[' stmtlst ']'

stmtlst:        stmt           
            |   stmt stmtlst

stmt:           set
            |   if
            |   print
            |   incr
            |   decr
            |   return
            |   expr

set:            '[' tSET ',' tIDENT ',' expr ']'

if:             '[' tIF ',' cond ',' then ']'
            |   '[' tIF ',' cond ',' then else ']'

print:          '[' tPRINT ',' '[' expr ']'']'

incr:           '[' tINC ',' tIDENT ']'

decr:           '[' tDEC ',' tIDENT ']'

cond:           '[' cmp ',' expr ',' expr ']'

expr:           tNUM
            |   tSTRING
            |   get
            |   decl
            |   oper
            |   cond

get:            '[' tGET ',' tIDENT ']'
            |   '[' tGET ',' tIDENT ',' '[' ']' ']'
            |   '[' tGET ',' tIDENT ',' '[' exprlst ']' ']'

decl:           '[' tFUNCTION ',' '[' ']' ',' '[' ']' ']'
            |   '[' tFUNCTION ',' '[' params ']' ',' '[' ']' ']'
            |   '[' tFUNCTION ',' '[' ']' ',' '[' stmtlst ']' ']'
            |   '[' tFUNCTION ',' '[' params ']' ',' '[' stmtlst ']' ']'

params:         tIDENT
            |   tIDENT ',' params

exprlst:        expr
            |   expr ',' exprlst

oper:           '[' '"' operator '"' ',' expr ',' expr ']'

return:         '[' tRETURN ']'
            |   '[' tRETURN ',' expr ']'

operator:       '+' 
            |   '-'
            |   '*' 
            |   '/'

cmp:            tGT
            |   tGEQ
            |   tLT
            |   tLEQ
            |   tEQUALITY

then:           '[' ']'
            |   '[' stmtlst ']'

else:           '[' ']'
            |   '[' stmtlst ']'

%%
int main ()
{
    if (yyparse())
    {
    // parse error
        printf("ERROR\n");
        return 1;
    }
    else
    {
    // successful parsing
        printf("OK\n");
        return 0;
    }
}