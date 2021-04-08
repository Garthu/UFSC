#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "types.h"


typedef struct node{
	order_t *data;
	struct node* next;
}*Node;


Node Head;
Node Tail;

void enqueue(order_t* valor) {
    Node obj = (Node)malloc(sizeof(struct node));
    obj->data = valor;
    obj->next = NULL;
    if (Head == NULL) {
        Head = obj;
        // Head->ant = Tail;
        Tail = obj;
    } else {
        Tail->next = obj;
        Tail = obj;
    }
}

order_t* dequeue() {
   if (Head == NULL) {
        return NULL;
   } else {
      order_t *poped_data = Head->data;
      Node tmp = Head;
      Head = Head->next;
      free(tmp);
      return poped_data;
   } 
}