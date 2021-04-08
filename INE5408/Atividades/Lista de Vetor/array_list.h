// Copyright [2019] <SAMUEL CARDOSO>
#ifndef STRUCTURES_ARRAY_LIST_H
#define STRUCTURES_ARRAY_LIST_H

#include <cstdint>
#include <stdexcept>


namespace structures {

template<typename T>
//! Lista de vetores
class ArrayList {
 public:
    //! Construtor básico
    ArrayList();
    //! Construtor que recebe parâmetro
    explicit ArrayList(std::size_t max_size);
    //! Destrutor da Lista
    ~ArrayList();
    //! Resete de Lista
    void clear();
    //! Realiza a inserção de um elemento no final da lista
    void push_back(const T& data);
    //! Realiza a inserção de um elemento no início da lista
    void push_front(const T& data);
    //! Realiza a inserção em uma determinada posição
    void insert(const T& data, std::size_t index);
    //! Realiza a inserção de forma crescente
    void insert_sorted(const T& data);
    //! Realiza a retirada de um elemento em uma determinada posição
    T pop(std::size_t index);
    //! Realiza a retirada do elemento encontrado no final da lista
    T pop_back();
    //! Realiza a retirada do elemento encontrado no início da lista
    T pop_front();
    //! Retira um elemento com valor 'data'
    void remove(const T& data);
    //! Informa se a Lista está cheia
    bool full() const;
    //! Informa se a Lista está vazia
    bool empty() const;
    //! Verifica se um elemento 'data' está na lista
    bool contains(const T& data) const;
    //! Retorna em que posição está o elemento 'data'
    std::size_t find(const T& data) const;
    //! Retorna o tamanho de size_
    std::size_t size() const;
    //! Retorna o valor de max_size_
    std::size_t max_size() const;
    //! Retorna o valor encontrado em index
    T& at(std::size_t index);
    //! Define a operação []
    T& operator[](std::size_t index);
    //! Retorna o valor encontrado em index
    //! porém não permitindo alterações dado
    const T& at(std::size_t index) const;
    //! Define a operação []
    //! porém não permitindo alterações no dado
    const T& operator[](std::size_t index) const;

 private:
    T* contents;  // Dados da lista
    std::size_t size_;  // Tamanho atual da lista
    std::size_t max_size_;  // Tamanho máximo da lista
    int top_;
    static const auto DEFAULT_MAX = 10u;  // Tamanho padrão da lista
};

}  // namespace structures

#endif

template<typename T>
structures::ArrayList<T>::ArrayList() {
    contents = new T[DEFAULT_MAX];
    size_ = 0;
    max_size_ = DEFAULT_MAX;
}

template<typename T>
structures::ArrayList<T>::ArrayList(std::size_t max_size) {
    max_size_ = max_size;
    contents = new T[max_size_];
    size_ = 0;
}

template<typename T>
structures::ArrayList<T>::~ArrayList() {
    delete [] contents;
}

template<typename T>
void structures::ArrayList<T>::clear() {
    size_ = 0;
}

template<typename T>
void structures::ArrayList<T>::push_back(const T& data) {
    if (full()) {
        throw std::out_of_range("lista cheia");
    } else {
        contents[size_] = data;
        ++size_;
    }
}

template<typename T>
void structures::ArrayList<T>::push_front(const T& data) {
    if (full()) {
        throw std::out_of_range("lista cheia");
    } else {
        for (int i = size_; i >= 1; i--) {
            contents[i] = contents[i - 1];
        }
        ++size_;
        contents[0] = data;
    }
}

template<typename T>
void structures::ArrayList<T>::insert(const T& data, std::size_t index) {
    if (full()) {
        throw std::out_of_range("lista cheia");
    } else if ((index < 0) || index > size_) {
        throw std::out_of_range("index fora do escopo");
    } else {
        for (int i = size_; i > index; i--) {
            contents[i] = contents[i-1];
        }
        contents[index] = data;
        ++size_;
    }
}

template<typename T>
void structures::ArrayList<T>::insert_sorted(const T& data) {
    if (full()) {
        throw std::out_of_range("lista cheia");
    } else if ((contents[size_ - 1] < data) || empty()) {
        push_back(data);
    } else {
        for (int i = 0; i < size_; i++) {
            if (contents[i] > data) {
                insert(data, i);
                break;
            }
        }
    }
}

template<typename T>
T structures::ArrayList<T>::pop(std::size_t index) {
    if (empty()) {
        throw std::out_of_range("lista vazia");
    } else if (index < 0 || index + 1 > size_) {
        throw std::out_of_range("index fora do escopo");
    } else {
        size_--;
        T pop_item = contents[index];

        for (int i = index; i <size_; i++) {
            contents[i] = contents[i+1];
        }

        return pop_item;
    }
}

template<typename T>
T structures::ArrayList<T>::pop_back() {
    if (empty()) {
        throw std::out_of_range("lista vazia");
    } else {
        return contents[--size_];
    }
}

template<typename T>
T structures::ArrayList<T>::pop_front() {
    if (empty()) {
        throw std::out_of_range("lista vazia");
    } else {
        return pop(0);
    }
}

template<typename T>
void structures::ArrayList<T>::remove(const T& data) {
    pop(find(data));
}

template<typename T>
bool structures::ArrayList<T>::full() const {
    return size_ == max_size_;
}

template<typename T>
bool structures::ArrayList<T>::empty() const {
    return size_ == 0;
}

template<typename T>
bool structures::ArrayList<T>::contains(const T& data) const {
    for (int i = 0; i < size_; i++) {
        if (contents[i] == data) {
            return 1;
        }
    }
    return 0;
}

template<typename T>
std::size_t structures::ArrayList<T>::find(const T& data) const {
    std::size_t i;
    for (i = 0; i < size_; i++) {
        if (contents[i] == data) {
            break;
        }
    }
    return i;
}

template<typename T>
std::size_t structures::ArrayList<T>::size() const {
    return size_;
}

template<typename T>
std::size_t structures::ArrayList<T>::max_size() const {
    return max_size_;
}

template<typename T>
T& structures::ArrayList<T>::at(std::size_t index) {
    if (empty()) {
        throw std::out_of_range("lista vazia");
    } else if (index < 0 || index > size_) {
        throw std::out_of_range("index fora do escopo");
    } else {
        return contents[index];
    }
}

template<typename T>
T& structures::ArrayList<T>::operator[](std::size_t index) {
    if (empty()) {
        throw std::out_of_range("lista vazia");
    } else if (index < 0 || index > size_) {
        throw std::out_of_range("index fora do escopo");
    } else {
        return contents[index];
    }
}

template<typename T>
const T& structures::ArrayList<T>::at(std::size_t index) const {
    if (empty()) {
        throw std::out_of_range("lista vazia");
    } else if (index < 0 || index > size_) {
        throw std::out_of_range("index fora do escopo");
    } else {
        return contents[index];
    }
}

template<typename T>
const T& structures::ArrayList<T>::operator[](std::size_t index) const {
    if (empty()) {
        throw std::out_of_range("lista vazia");
    } else if (index < 0 || index > size_) {
        throw std::out_of_range("index fora do escopo");
    } else {
        return contents[index];
    }
}
