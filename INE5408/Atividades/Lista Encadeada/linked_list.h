//! Copyright [2020] <SAMUEL CARDOSO>
#include <cstdint>  // std::size_t
#include <stdexcept>  // C++ exceptions

namespace structures {

template<typename T>
//! Fila encadeada
class LinkedQueue {
 public:
    //! Construtor simples
    LinkedQueue();
    //! Destrutor simples
    ~LinkedQueue();
    //! Reseta a fila
    void clear();
    //! Adiciona um elemento como o novo final da fila
    void enqueue(const T& data);
    //! Retira o elemento mais antigo
    T dequeue();
    //! Retorna o elemento encontrado no início da fila
    T& front() const;
    //! Retorna o elemento no final da fila
    T& back() const;
    //! Retorna se a fila está vazia
    bool empty() const;
    //! Retorna o tamanho atual da fila
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

    //! Node responsável pelo início da fila
    Node* head{nullptr};
    //! Node responsável pelo final da fila
    Node* tail{nullptr};
    //! Elemento que marca o tamanho da fila
    std::size_t size_{0u};
};

}  // namespace structures

template<typename T>
structures::LinkedQueue<T>::LinkedQueue() {}

template<typename T>
structures::LinkedQueue<T>::~LinkedQueue() {
    clear();
}

template<typename T>
void structures::LinkedQueue<T>::clear() {
    while (!empty()) {
        dequeue();
    }
}

template<typename T>
void structures::LinkedQueue<T>::enqueue(const T& data) {
    Node *new_data = new Node(data);
    if (empty()) {
        head = new_data;
    } else {
        tail->next(new_data);
    }

    new_data->next(nullptr);
    tail = new_data;
    ++size_;
}

template<typename T>
T structures::LinkedQueue<T>::dequeue() {
    if (empty()) {
        throw std::out_of_range("Lista cheia");
    }

    Node *should_be_deleted = head;
    T dequeue_data = head->data();
    head = head->next();

    if (size() == 1) {
        tail = nullptr;
    }

    --size_;
    delete should_be_deleted;

    return dequeue_data;
}

template<typename T>
T& structures::LinkedQueue<T>::front() const {
    if (empty()) {
        throw std::out_of_range("Lista vazia");
    }

    return head->data();
}

template<typename T>
T& structures::LinkedQueue<T>::back() const {
    if (empty()) {
       throw std::out_of_range("Lista vazia");
    }

    return tail->data();
}

template<typename T>
bool structures::LinkedQueue<T>::empty() const {
    return (size() == 0);
}

template<typename T>
std::size_t structures::LinkedQueue<T>::size() const {
    return size_;
}
