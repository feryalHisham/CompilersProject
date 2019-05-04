#pragma once
#include <stdio.h>
#include "typesStructs.h"
#include "y.tab.h"

static int lbl;
static int caselbl;
static int switchlbl;
static int deflbl;

int ex(nodeType *p) {
    int lbl1, lbl2;
    int caselbl1,caselbl2;


    if (!p) { return 0;}

    /*printf("p type %d",p->exType);
    printf("compiler\n");
    printf("p type %d",p->type);*/
    switch(p->type) {
    case typeCon: 
		switch(p->con.conT){
		case typeInt:
			printf("\tpush\t%d\n", p->con.valueInt);
		break;
		case typeFloat:
			printf("\tpush\t%f\n", p->con.valueFloat); 
		break;
		case typeString:
			printf("\tpush\t%s\n", p->con.valueString); 
		break;
		default:
			printf("\tpush\t%d\n", p->con.valueBool); 
        }      
        break;
    case typeId: 
	//fprintf(stdout, "line %s\n", p->id.keyName);       
        printf("\tpush\t%s\n", p->id.keyName); 
        break;
    case typeOpr:
    	 //fprintf(stdout, "type %d %c \n", p->exType,p->opr.oper);
        switch(p->opr.oper) {
        case WHILE:
            printf("L%03d:\n", lbl1 = lbl++);
            ex(p->opr.op[0]);
            printf("\tjz\tL%03d\n", lbl2 = lbl++);
            ex(p->opr.op[1]);
            printf("\tjmp\tL%03d\n", lbl1);
            printf("L%03d:\n", lbl2);
            break;
        case IF:
            ex(p->opr.op[0]);
            if (p->opr.nops > 2) {
                /* if else */
                printf("\tjz\tL%03d\n", lbl1 = lbl++);
                ex(p->opr.op[1]);
                printf("\tjmp\tL%03d\n", lbl2 = lbl++);
                printf("L%03d:\n", lbl1);
                ex(p->opr.op[2]);
                printf("L%03d:\n", lbl2);
            } else {
                /* if */
                printf("\tjz\tL%03d\n", lbl1 = lbl++);
                ex(p->opr.op[1]);
                printf("L%03d:\n", lbl1);
            }
            break;
        case PRINT:     
            ex(p->opr.op[0]);
            printf("\tprint\n");
            break;
        case '=':       
            ex(p->opr.op[1]);
            printf("\tpop\t%s\n", p->opr.op[0]->id.keyName );
            break;
        case UMINUS:    
            ex(p->opr.op[0]);
            printf("\tneg\n");
            break;
        case SWITCH:
            ex(p->opr.op[0]); /*expression of switch*/
            ex(p->opr.op[1]); /*first case*/
            printf("defaultL%03d\n",deflbl++);
            ex(p->opr.op[2]); /*default block code*/
            printf("switchL%03d\n",switchlbl++);
            break;
        case CASE:
            ex(p->opr.op[0]); /*expression of case*/
            printf("\tcompEQ\n");
            printf("\tjnz\tcaseL%03d\n",caselbl1 = caselbl++);
            if(p->opr.nops == 3){
                ex(p->opr.op[2]);
            }
            else{
                printf("\tjmp\tdefaultL%03d\n",deflbl);
            }
            printf("caseL%03d:\n",caselbl1);
            ex(p->opr.op[1]); /*case block code*/
            printf("\tjmp\tswitchL%03d\n",switchlbl);
            break;

        default:
            ex(p->opr.op[0]);
            ex(p->opr.op[1]);
            switch(p->opr.oper) {
            case '+':   printf("\tadd\n"); break;
            case '-':   printf("\tsub\n"); break; 
            case '*':   printf("\tmul\n"); break;
            case '/':   printf("\tdiv\n"); break;
            case '<':   printf("\tcompLT\n"); break;
            case '>':   printf("\tcompGT\n"); break;
            case GE:    printf("\tcompGE\n"); break;
            case LE:    printf("\tcompLE\n"); break;
            case NE:    printf("\tcompNE\n"); break;
            case EQ:    printf("\tcompEQ\n"); break;
            }
        }
    }
    return 0;
}
