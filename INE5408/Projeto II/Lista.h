// Copyright [2020] <Thiago Z L Chaves>
#ifndef STRUCTURES_ARRAY_LIST_H
#define STRUCTURES_ARRAY_LIST_H

#include <cstdint>
#include <stdexcept>  // C++ Exceptions
// é pra colocar isso?

namespace structures {

template<typename T>
//! classe ArrayList
class ArrayList {
 public:
    //! construtor padrao
    ArrayList();
    //! construtor com parametro
    explicit ArrayList(std::size_t max);
    //! destrutor padrao
    ~ArrayList();
    //! metodo limpa a lista
    void clear();
    //! metodo empurra pra tras
    void push_back(const T& data);
    //! metodo empurra pra frente
    void push_front(const T& data);
    //! insere objeto em determinada posicao
    void insert(const T& data, std::size_t index);
    //! insere ordenadamente
    void insert_sorted(const T& data);
    //! index
    T pop(std::size_t index);
    //! pop back
    T pop_back();
    //! pop front
    T pop_front();
    //! remove elemento
    void remove(const T& data);
    //! verifica se esta cheio
    bool full() const;
    //! verifica se esta vazio
    bool empty() const;
    //! contains
    bool contains(const T& data) const;
    //! find
    std::size_t find(const T& data) const;
    //! size
    std::size_t size() const;
    //! max size
    std::size_t max_size() const;
    //! index
    T& at(std::size_t index);
    //! index
    T& operator[](std::size_t index);
    //! index
    const T& at(std::size_t index) const;
    //! index
    const T& operator[](std::size_t index) const;

 private:
    T* contents;
    std::size_t size_;
    std::size_t max_size_;
    int end_;
    int begin_;
    static const auto DEFAULT_MAX = 10u;
};

}  // namespace structures

#endif

template<typename T>
structures::ArrayList<T>::ArrayList() {
    max_size_ = DEFAULT_MAX;
    contents = new T[max_size_];
    end_ = -1;
    size_ = 0;
    begin_ = 0;
    // size_ -1 ou size_
}

template<typename T>
structures::ArrayList<T>::ArrayList(std::size_t max) {
    max_size_ = max;
    contents = new T[max_size_];
    end_ = -1;
    size_ = 0;
    begin_ = 0;
}

template<typename T>
structures::ArrayList<T>::~ArrayList() {
    delete [] contents;
}

template<typename T>
void structures::ArrayList<T>::clear() {
    end_ = -1;
    size_ = 0;
    begin_ = 0;
}

template<typename T>
void structures::ArrayList<T>::push_back(const T& data) {
    if (full()) {
        throw std::out_of_range("Erro Lista Cheia");
}   else {
        size_ +=1;
        end_ += 1;
        contents[end_] = data;
}
}

template<typename T>
void structures::ArrayList<T>::push_front(const T& data) {
    insert(data , 0);
}

template<typename T>
void structures::ArrayList<T>::insert(const T& data, std::size_t index) {
    if (full()) {
        throw std::out_of_range("Erro Lista Cheia");
}   else {
        int atual;
        if (index > end_ + 1) {
            throw std::out_of_range("Erro Posicao");
      } else {
                size_ +=1;
                end_ +=1;
                atual = end_;
                while (atual > index) {
                    contents[atual] = contents[atual - 1];
                    atual = atual - 1;
                }
                contents[index] = data;
                }
        }
}

template<typename T>
void structures::ArrayList<T>::insert_sorted(const T& data) {
    int atual;
    if (full()) {
        throw std::out_of_range("Erro Lista Cheia");
  } else {
      atual = 0;
      while (atual < size() && contents[atual] < data) {
        atual +=1;
        }
    }
    insert(data, atual);
}

template<typename T>
T structures::ArrayList<T>::pop(std::size_t index) {
    int atual;
    T valor;
    if (index < 0 || index > end_) {
        throw std::out_of_range("Erro Posicao");
  } else {
        if (empty()) {
            throw std::out_of_range("Erro Lista Vazia");
      } else {
            size_ -=1;
            end_ -=1;
            valor = contents[index];
            atual = index;
            while (atual <= end_) {
                contents[atual] = contents[atual + 1];
                atual +=1;
                }
            return valor;
            }
        }
}

template<typename T>
T structures::ArrayList<T>::pop_back() {
    if (empty()) {
        throw std::out_of_range("Erro Lista Vazia");
  } else {
        return pop(size()-1);
        }
}

template<typename T>
T structures::ArrayList<T>::pop_front() {
    int posicao;
    T valor;
    if (empty()) {
        throw std::out_of_range("Erro Lista Vazia");
  } else {
        end_ -=1;
        valor = contents[0];
        posicao = 0;
        while (posicao <= end_) {
            contents[posicao] = contents[posicao + 1];
            posicao +=1;
            }
        return valor;
        }
}

template<typename T>
void structures::ArrayList<T>::remove(const T& data) {
    if (empty()) {
        throw std::out_of_range("Erro Lista Vazia");
  } else {
        pop(find(data));
         }
}

template<typename T>
bool structures::ArrayList<T>::full() const {
    return size_ == max_size_;
}

template<typename T>
bool structures::ArrayList<T>::empty() const {
    return (end_ == -1);
}

template<typename T>
bool structures::ArrayList<T>::contains(const T& data) const {
    std::size_t index = find(data);
    return index < size();
}

template<typename T>
std::size_t structures::ArrayList<T>::find(const T& data) const {
    for (int posicao = 0; posicao <= end_; posicao++) {
        if (contents[posicao] == data) {
            return posicao;
        }
    }
    return size_;
}

template<typename T>
std::size_t structures::ArrayList<T>::size() const {
    return end_+1;
}

template<typename T>
std::size_t structures::ArrayList<T>::max_size() const {
    return max_size_;
}

template<typename T>
T& structures::ArrayList<T>::at(std::size_t index) {
    if (index <= end_) {
        return contents[index];
    }
    throw std::out_of_range("Erro lista vazia");
}

template<typename T>
T& structures::ArrayList<T>::operator[](std::size_t index) {
    return contents[index];
}

template<typename T>
const T& structures::ArrayList<T>::at(std::size_t index) const {
    return contents[index];
}

template<typename T>
const T& structures::ArrayList<T>::operator[](std::size_t index) const {
    return contents[index];
}
