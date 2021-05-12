#ifndef __HW3_H_ 
#define __HW3_H_ 
 
typedef enum { STRV, INTV, REALV } ExprType;
typedef enum { NONCONST, CONSTANT, TOP } ExprAttr;

typedef struct {
    char* str;
    int intVal;
    double realVal;
} ExprVal;

typedef struct Expr{
    int line;
    ExprAttr myAttr;
    ExprType myType;
    ExprVal myVal;
} Expr;

#endif