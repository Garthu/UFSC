// Copyright [2019] <SAMUEL CARDOSO>
#ifndef STRUCTURES_ARRAY_STACK_H
#define STRUCTURES_ARRAY_STACK_H

#include <cstdint>  // std::size_t
#include <stdexcept>  // C++ exceptions

namespace structures {

template<typename T>
//! CLASSE PILHA
class ArrayStack {
 public:
    //! construtor simples
    ArrayStack();
    //! construtor com parametro tamanho
    explicit ArrayStack(std::size_t max);
    //! destrutor
    ~ArrayStack();
    //! metodo empilha
    void push(const T& data);
    //! metodo desempilha
    T pop();
    //! metodo retorna o topo
    T& top();
    //! metodo limpa pilha
    void clear();
    //! metodo retorna tamanho
    std::size_t size();
    //! metodo retorna capacidade maxima
    std::size_t max_size();
    //! verifica se esta vazia
    bool empty();
    //! verifica se esta cheia
    bool full();

 private:
    T* contents;
    int top_;
    std::size_t max_size_;

    static const auto DEFAULT_SIZE = 10u;
};

}  // namespace structures

#endif


template<typename T>
structures::ArrayStack<T>::ArrayStack() {
    max_size_ = DEFAULT_SIZE;
    contents = new T[max_size_];
    top_ = -1;
}

template<typename T>
structures::ArrayStack<T>::ArrayStack(std::size_t max) {
    // Contrutor explícito com parâmetro max
    max_size_ = max;
    contents = new T[max];
    top_ = -1;
}

template<typename T>
structures::ArrayStack<T>::~ArrayStack() {
    delete [] contents;
}

template<typename T>
void structures::ArrayStack<T>::push(const T& data) {
    if (full()) {
        throw std::out_of_range("pilha cheia");
    } else {
        // Coloca um item na pilha caso haja espaço
        top_++;
        contents[top_] = data;
    }
}

template<typename T>
T structures::ArrayStack<T>::pop() {
    // Caso a pilha não esteja vazia, retira e retorna o topo
    if (empty()) {
        throw std::out_of_range("pilha vazia");
    } else {
        top_--;
        return contents[top_+1];
    }
}

template<typename T>
T& structures::ArrayStack<T>::top() {
    // Caso a lista não esteja vazia, retorna o topo
    if (empty()) {
        throw std::out_of_range("pilha vazia");
    } else{
        return contents[top_];
    }
}

template<typename T>
void structures::ArrayStack<T>::clear() {
    // Reseta a pilha
    delete [] contents;
    contents = new T[max_size_];
    top_ = -1;
}

template<typename T>
std::size_t structures::ArrayStack<T>::size() {
    // Retorna o tamanho atual da pilha
    return (top_+1);
}

template<typename T>
std::size_t structures::ArrayStack<T>::max_size() {
    // Retorna o máximo valor da pilha
    return max_size_;
}

template<typename T>
bool structures::ArrayStack<T>::empty() {
    // Verifica se a pilha está vazia
    if (top_ == -1) {
        return 1;
    } else {
        return 0;
    }
}

template<typename T>
bool structures::ArrayStack<T>::full() {
    // Retorna se a pilha já está cheia
    if (top_ == max_size_ - 1) {
        return 1;
    } else {
        return 0;
    }
}