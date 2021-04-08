#include <iostream>

using namespace std; 

struct Branch { 
    struct Branch *lista_de_letras[26]; 
    int forks{0};
    bool isOneWord{0};
    int count_char;
    int count_line;
};

struct Branch* getNode(void) { 
    struct Branch *novo =  new Branch;
  
    for (int i = 0; i < 26; i++) 
        novo->lista_de_letras[i] = NULL; 
  
    return novo; 
}

void insert(struct Branch *root, string data, int count_char, int count_line) {
    struct Branch *ptr = root; 
  
    for (int i = 0; i < data.length(); i++) { 
        int index = data[i] % 'a'; 
        if (!ptr->lista_de_letras[index]) 
            ptr->lista_de_letras[index] = getNode(); 
  
        ptr = ptr->lista_de_letras[index];
    } 

    ptr->isOneWord = true;
    ptr->count_char = count_char;
    ptr->count_line = count_line;
}

int order(struct Branch *current) {
    struct Branch *ptr = current;
    int branch_order = 0;

    if (ptr->isOneWord == true) {
        ++branch_order;
    }
    
    for (int i = 0; i < 26; i++) {
        if (ptr->lista_de_letras[i] != NULL) {
            branch_order += order(ptr->lista_de_letras[i]);
        }
    }

    return branch_order;
}

int search(struct Branch *root, string data) {
    struct Branch *ptr = root; 
  
    for (int i = 0; i < data.length(); i++) { 
        int index = data[i] % 'a'; 
        if (!ptr->lista_de_letras[index]) 
            return 0; 
  
        ptr = ptr->lista_de_letras[index];
    } 
  
    return order(ptr); 
}

struct Branch *isOneWord(struct Branch *root, string data) {
    struct Branch *ptr = root;

    for (int i = 0; i < data.length(); i++) {
        int index = data[i] % 'a';
        if (!ptr->lista_de_letras[index]) {
            return NULL;
        }

        ptr = ptr->lista_de_letras[index];
    }

    return ptr;
}

