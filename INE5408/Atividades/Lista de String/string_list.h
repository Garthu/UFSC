//! Copyright [2020] <SAMUEL CARDOSO>


#ifndef STRUCTURES_STRING_LIST_H
#define STRUCTURES_STRING_LIST_H

#include <cstdint>
#include <stdexcept>  // C++ exceptions
#include <cstring>

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


//-------------------------------------

//! Lista de Strings
//! ArrayListString e' uma especializacao da classe ArrayList
class ArrayListString : public ArrayList<char *> {
 public:
    //! Construtor base da classe
    ArrayListString() : ArrayList() {}
    //! Construtor com parâmetro
    explicit ArrayListString(std::size_t max_size) : ArrayList(max_size) {}
    //! Destrutor da classe
    ~ArrayListString();

    //! Reseta a Lista
    void clear();
    //! Realiza a inserção no final
    void push_back(const char *data);
    //! Realiza a inserção de um elemento no início da lista
    void push_front(const char *data);
    //! Realiza a inserção de um elemento na posição 'index'
    void insert(const char *data, std::size_t index);
    //! Realiza a inserçãod o elemento ordenadamente
    void insert_sorted(const char *data);
    //! Retira um elemento de posição 'index'
    char *pop(std::size_t index);
    //! Retira um elemento encontrado no final da Lista
    char *pop_back();
    //! Retira um elemento encontrado no início da lista
    char *pop_front();
    //! Remove um elemento com valor 'data'
    void remove(const char *data);
    //! Verifica se existe um elemento de valor 'data' na lista
    bool contains(const char *data);
    //! Retorna em que posição o valor 'data' se encontra na lista
    std::size_t find(const char *data);
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

structures::ArrayListString::~ArrayListString() {
    clear();
}

void structures::ArrayListString::clear() {
    char *str_p;
    while (!empty()) {
        str_p = pop_front();
        delete str_p;
    }
}

void structures::ArrayListString::push_back(const char *data) {
    char *str_p = new char[strlen(data) + 1];
    snprintf(str_p, strlen(data) + 1, "%s", data);
    insert(str_p, size());
}

void structures::ArrayListString::push_front(const char *data) {
    char *str_p = new char[strlen(data) + 1];
    snprintf(str_p, strlen(data) + 1, "%s", data);
    insert(str_p, 0);
}

void structures::ArrayListString::insert(const char *data, std::size_t index) {
    char *str_p =new char[strlen(data) + 1];
    snprintf(str_p, strlen(data) + 1, "%s", data);
    ArrayList::insert(str_p, index);
}

void structures::ArrayListString::insert_sorted(const char *data) {
    char *str_p =new char[strlen(data) + 1];
    snprintf(str_p, strlen(data) + 1, "%s", data);
    std::size_t index = 0;

    while (index < size() && strcmp(str_p, ArrayList::at(index)) > 0) {
        ++index;
    }

    ArrayList::insert(str_p, index);
}

char *structures::ArrayListString::pop(std::size_t index) {
    if (empty()) {
        throw std::out_of_range("lista vazia");
    } else if (index >= ArrayList::size()) {
        throw std::out_of_range("indice fora do escopo");
    }

    char *str_p = new char[strlen(ArrayList::at(index) - 1)];
    snprintf(str_p, strlen(ArrayList::at(index))+1, "%s", ArrayList::at(index));
    delete ArrayList::at(index);
    ArrayList::pop(index);
    return str_p;
}

char *structures::ArrayListString::pop_back() {
    if (empty()) {
        throw std::out_of_range("lista vazia");
    }

    return pop(ArrayList::size()-1);
}

char *structures::ArrayListString::pop_front() {
    if (empty()) {
        throw std::out_of_range("lista vazia");
    }

    return pop(0);
}

void structures::ArrayListString::remove(const char *data) {
    std::size_t index = 0;

    while (index < size() && strcmp(data, at(index)) != 0) {
        ++index;
    }

    pop(index);
}

bool structures::ArrayListString::contains(const char *data) {
    std::size_t index = find(data);
    return index < size();
}

std::size_t structures::ArrayListString::find(const char *data) {
    std::size_t index = 0;

    while (index < size() && strcmp(data, ArrayList::at(index)) != 0) {
        ++index;
    }

    return index;
}
