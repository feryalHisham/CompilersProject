#include <stdbool.h>
#define MAX_SCOPES 100
#define MAX_VARS 50
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
    char* keyName;                      /* subscript to sym array */
    int scopeIndex;
    int varIndex;
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

typedef struct {
	conType varType;
    int scopeIndex;
  	char* varName;
	bool constant;
	 union {
    int valueInt;                  /* value of constant */
    char* valueString;
    float valueFloat;
    bool valueBool;
   };	
} varData;

extern int scopeLevel;
extern int scopesParent[MAX_SCOPES];	/* start from index 1*/
extern varData sym[MAX_SCOPES][MAX_VARS]; /* first index contains the number of variables in this scope*/
extern int yylineno;


