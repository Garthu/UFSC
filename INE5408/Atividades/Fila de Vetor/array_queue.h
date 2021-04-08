// Copyright [2018] <SAMUEL CARDOSO>
#ifndef STRUCTURES_ARRAY_QUEUE_H
#define STRUCTURES_ARRAY_QUEUE_H

#include <cstdint>  // std::size_t
#include <stdexcept>  // C++ Exceptions

namespace structures {

template<typename T>
//! classe ArrayQueue
class ArrayQueue {
 public:
    //! construtor padrao
    ArrayQueue();
    //! construtor com parametro
    explicit ArrayQueue(std::size_t max);
    //! destrutor padrao
    ~ArrayQueue();
    //! metodo enfileirar
    void enqueue(const T& data);
    //! metodo desenfileirar
    T dequeue();
    //! metodo retorna o ultimo
    T& back();
    //! metodo limpa a fila
    void clear();
    //! metodo retorna tamanho atual
    std::size_t size();
    //! metodo retorna tamanho maximo
    std::size_t max_size();
    //! metodo verifica se vazio
    bool empty();
    //! metodo verifica se esta cheio
    bool full();

 private:
    T* contents;
    std::size_t size_;
    std::size_t max_size_;
    int begin_;  // indice do inicio (para fila circular)
    int end_;  // indice do fim (para fila circular)
    static const auto DEFAULT_SIZE = 10u;
};

}  // namespace structures

#endif

template<typename T>
structures::ArrayQueue<T>::ArrayQueue() {
    // Realiza a criação da lista com tamanho DEFAULT_SIZE
    contents = new T[DEFAULT_SIZE];
    max_size_ = DEFAULT_SIZE;
    size_ = 0;
    begin_ = 0;
    end_ = -1;
}

template<typename T>
structures::ArrayQueue<T>::ArrayQueue(std::size_t max) {
    // Realiza a criação da lista com tamanho max
    contents = new T[max];
    max_size_ = max;
    size_ = 0;
    begin_ = 0;
    end_ = -1;
}

template<typename T>
structures::ArrayQueue<T>::~ArrayQueue() {
    // Destroi a lista
    delete[] contents;
}

template<typename T>
void structures::ArrayQueue<T>::enqueue(const T& data) {
    // Caso a lista não esteja cheia, adiciona o elemento na lista
    if (full()) {
        throw std::out_of_range("fila cheia");
    } else {
        end_ = (end_ + 1) % max_size_;
        contents[end_] = data;
        ++size_;
    }
}

template<typename T>
T structures::ArrayQueue<T>::dequeue() {
    // Caso a lista não esteja vazia, retorna o valor pedido
    if (empty()) {
        throw std::out_of_range("fila vazia");
    } else {
        int queueNumber = contents[begin_];
        begin_ = (begin_ + 1) % max_size_;
        --size_;

        return queueNumber;
    }
}

template<typename T>
T& structures::ArrayQueue<T>::back() {
    // Caso a lista não esteja vazia, retorna o último valor da lista
    if (empty()) {
        throw std::out_of_range("fila vazia");
    } else {
        return contents[end_];
    }
}

template<typename T>
void structures::ArrayQueue<T>::clear() {
    delete[] contents;
    contents = new T[max_size_];
    size_ = 0;
    begin_ = 0;
    end_ = -1;
}

template<typename T>
std::size_t structures::ArrayQueue<T>::size() {
    // Retorna o valor de size_
    return size_;
}

template<typename T>
std::size_t structures::ArrayQueue<T>::max_size() {
    // Retorna o valor de max_size_
    return max_size_;
}

template<typename T>
bool structures::ArrayQueue<T>::empty() {
    // Retorna se a lista está vazia ou não
    return (size_ == false);
}

template<typename T>
bool structures::ArrayQueue<T>::full() {
    // Retorna se a lista está cheia ou não
    return (size_ == max_size_);
}
