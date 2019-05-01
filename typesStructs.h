

#include <stdbool.h>

typedef enum { typeCon, typeId, typeOpr } nodeEnum;
typedef enum { typeLog,typeMath,typeOther } exprType;
typedef enum { typeInt,typeFloat,typeString,typeBool} conType;
/* constants */
typedef struct {
 conType conT;
 union {
    int valueInt;                  /* value of constant */
    char* valueString;
    float valueFloat;
    bool valueBool;
   };
} conNodeType;


/* identifiers */
typedef struct {
    int i;                      /* subscript to sym array */
} idNodeType;

/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[1];	/* operands, extended at runtime */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */
    exprType exType;
    union {
        conNodeType con;        /* constants */
        idNodeType id;          /* identifiers */
        oprNodeType opr;        /* operators */
    };
} nodeType;

extern int sym[26];
extern int yylineno;
