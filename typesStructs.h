#include <stdbool.h>
#include <vector>
#include <map>


typedef enum { typeCon, typeId, typeOpr } nodeEnum;
typedef enum { typeLog,typeMath,typeOther } exprType;
typedef enum { typeInt,typeFloat,typeString,typeBool,VAR_AS_LVALUE,VAR_AS_EXPR} conType;
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
} idNodeType;

/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    conType operType;
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
  	char* varName;
	bool constant;
	bool used;
	bool initialized;
	bool null;
	int lineDeclared;
	 union {
        int valueInt;                  /* value of constant */
        char* valueString;
        float valueFloat;
        bool valueBool;
	 };
} varData;



extern std::vector<std::map<std::string,varData>> sym;
extern int yylineno;
extern varData v;
extern std::vector<std::pair<int,std::string>> errors;
