//! Copyright [2020] <SAMUEL CARDOSO>
#include <cstdint>  // std::size_t
#include <stdexcept>  // C++ exceptions

namespace structures {

template<typename T>
//! Pilha encadeada
class LinkedStack {
 public:
    //! Construtor simples
    LinkedStack();
    //! Destrutor simples
    ~LinkedStack();
    //! Reseta a pilha
    void clear();
    //! Coloca um elemento no topo da pilha
    void push(const T& data);
    //! Retira o elemento no topo da pilha
    T pop();
    //! Retorna o valor armazenado no topo da pilha
    T& top() const;
    //! Retorna se a pilha está vazia
    bool empty() const;
    //! Retorna o tamanho atual da pilha
    std::size_t size() const;

 private:
    class Node {
     public:
        //! Construtor simples
        explicit Node(const T& data):
            data_{data}
        {}
        //! Construtor com adição de ponteiro
        Node(const T& data, Node* next):
            data_{data},
            next_{next}
        {}
        //! Retorna o dado armazenado no Node
        T& data() {
            return data_;
        }
        //! Retorna o dado armazenado no Node
        const T& data() const {
            return data_;
        }
        //! Retorna o ponteiro para o próximo Node
        Node* next() {
            return next_;
        }
        //! Retorna o ponteiro para o próximo Node
        const Node* next() const {
            return next_;
        }
        //! Seta o ponteiro do Node
        void next(Node* next) {
            next_ = next;
        }

     private:
        T data_;
        Node* next_;
    };

    Node* top_{nullptr};  // nodo-topo
    std::size_t size_{0u};  // tamanho
};

}  // namespace structures

template<typename T>
structures::LinkedStack<T>::LinkedStack() {}

template<typename T>
structures::LinkedStack<T>::~LinkedStack() {
    clear();
}

template<typename T>
void structures::LinkedStack<T>::clear() {
    while (!empty()) {
        pop();
    }
}

template<typename T>
void structures::LinkedStack<T>::push(const T& data) {
    Node *new_top = new Node(data);
    new_top->next(top_);
    top_ = new_top;
    ++size_;
}

template<typename T>
T structures::LinkedStack<T>::pop() {
    if (empty()) {
        throw std::out_of_range("Lista vazia");
    } else {
        T poped_data = top_->data();
        Node *current = top_;
        top_ = top_->next();
        delete current;
        --size_;

        return poped_data;
    }
}

template<typename T>
T& structures::LinkedStack<T>::top() const {
    if (empty()) {
        throw std::out_of_range("Lista vazia");
    }

    return top_->data();
}

template<typename T>
bool structures::LinkedStack<T>::empty() const {
    return (size() == 0);
}

template<typename T>
std::size_t structures::LinkedStack<T>::size() const {
    return size_;
}
