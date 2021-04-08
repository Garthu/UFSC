#ifndef RECURSIVE_H
#define RECURSIVE_H

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>

using namespace std;
//! recursive
/*!
* Metodo usa recursao para percorrer a matriz, estamos percorrendo a matriz como uma column-major.
* Os parametros são: o ponteiro que aponta para a matriz e as dimensoes da matriz.
* Algoritmo que percorre os elementos da "Matriz" em busca de 1's;
* Quando encontra um, vai para ele e procura por mais elementos adjacentes.
*/
int recursive(string *content, int *height, int *width, int j, int k) {

    //! Seta o valor atual para 2 para que não seja repetido seu valor
    if ((*content)[j*(*width)+k] == '1') {
        (*content)[j*(*width)+k] = '2';
    }

    //! Bloquei a linha de cima
    if ((j*(*width)+k) > ((*width)-1)) {
        //! Percorre para cima
        if ((*content)[(j-1)*(*width)+k] == '1') {
            recursive(content, height, width, j-1, k);
        }
    }

    //! Bloqueia a linha de baixo
    if ((j*(*width)+k) < ((*height)*(*width)-((*width)-1))) {
        //! Percorre para baixo
        if ((*content)[(j+1)*(*width)+k] == '1') {
            recursive(content, height, width, j+1, k);
        }
    }

    //! Bloqueia a linha da direita
    if ((j*(*width)+k+1) % (*width) != 0) {
        //! Percorre em direção à direita
        if ((*content)[j*(*width)+k+1] == '1') {
            recursive(content, height, width, j, k+1);
        }
    }

    //! Bloquei a linha da esquerda
    if ((j*(*width)+k) % (*width) != 0 && j*(*width)+k != 0) {
        //! Percorre em direção à esquerda
        if ((*content)[j*(*width)+k-1] == '1') {
            recursive(content, height, width, j, k-1);
        }
    }

    return 0;
}

int recursiveXML(string *content, int *height, int *width) {

    int total = 0;

    //! Aqui é simulado uma Matriz, usando um vetor
    for (int j = 0; j < *height; j++) {
        for (int k = 0; k < *width; k++) {
            
            if ((*content)[j*(*width)+k] == '1') {

                //! Caso um elemento novo seja encontrado, total recebe um
                //! acréscimo de 1
                total += 1;

                //! Inicia a recursão a partir do elemento X
                recursive(content, height, width, j, k);
            }
        }
    }

    //! Retorna quantos elementos foram contados
    return total;
}


#endif