//! Copyright [2020] <SAMUEL CARDOSO>
#include <cstdint>  // std::size_t
#include <stdexcept>  // C++ exceptions

namespace structures {

template<typename T>
//! Lista duplamente encadeada
class DoublyCircularList {
 public:
    //! Construtor simples
    DoublyCircularList();
    //! Destrutor simples
    ~DoublyCircularList();
    //! Reseta a lista duplamente encadeada
    void clear();
    //! Insere um elemento no final da lista
    void push_back(const T& data);
    //! Insere um elemento no inicio da lista
    void push_front(const T& data);
    //! Insere um elemento num indice 'index'
    void insert(const T& data, std::size_t index);
    //! Insere um elemento na lista de forma ordenada
    void insert_sorted(const T& data);
    //! Retira um elemento da posição 'index'
    T pop(std::size_t index);
    //! Retira um elemento encontrado no final da lista
    T pop_back();
    //! Retira um elemento encontrado no inicio da lista
    T pop_front();
    //! Retira um elemento x dado por 'data'
    void remove(const T& data);
    //! Verifica se a lista se encontra vazia
    bool empty() const;
    //! Verifica se a lista contém um elemento x dado por 'data'
    bool contains(const T& data) const;
    //! Retorna o elemento encontrado no índice 'index'
    T& at(std::size_t index);
    //! Retorna o elemento constante no índice 'index'
    const T& at(std::size_t index) const;
    //! Retorna o índice de um dado dado por 'data'
    std::size_t find(const T& data) const;
    //! Retorna o tamanho atual da lista
    std::size_t size() const;

 private:
    class Node {
     public:
        //! Construtor simples
        explicit Node(const T& data):
            data_{data}
        {}
        //! Construtor com adição de um ponteiro
        Node(const T& data, Node* next):
            data_{data},
            next_{next}
        {}
        //! Construtor com adição de ambos os ponteiros
        Node(const T& data, Node* prev, Node* next):
            data_{data},
            prev_{prev},
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
        //! Retorna o ponteiro de Node anterior
        Node* prev() {
            return prev_;
        }
        //! Retorna o ponteiro do Node anterior constante
        const Node* prev() const {
            return prev_;
        }
        //! Seta o ponteiro prev_ como o Node 'node'
        void prev(Node* node) {
            prev_ = node;
        }
        //! Retorna o ponteiro para o próximo Node
        Node* next() {
            return next_;
        }
        //! Retorna o ponteiro para o próximo Node
        const Node* next() const {
            return next_;
        }
        //! Seta o ponteiro next_ como o Node 'node'
        void next(Node* node) {
            next_ = node;
        }

     private:
        T data_;  // Dado encontrado no Node
        Node* prev_;  // Node anterior ao atual
        Node* next_;  // Node sucessor ao atual
    };

    Node* head{nullptr};  // Elemento do início da lista
    Node* tail{nullptr};  // Elemento do final da lista
    std::size_t size_{0};  // Tamanho atual da lista
};

}  // namespace structures

template<typename T>
structures::DoublyCircularList<T>::DoublyCircularList() {}

template<typename T>
structures::DoublyCircularList<T>::~DoublyCircularList() {
    clear();
}

template<typename T>
void structures::DoublyCircularList<T>::clear() {
    while (!empty()) {
        pop_front();
    }
}

template<typename T>
void structures::DoublyCircularList<T>::push_back(const T& data) {
    insert(data, size());
}

template<typename T>
void structures::DoublyCircularList<T>::push_front(const T& data) {
    Node *new_node = new Node(data, nullptr, head);
    if (new_node == nullptr) {
        throw std::out_of_range("Lista cheia");
    } else {
        Node *current_front = head;
        head = new_node;
        if (current_front != nullptr) {
            current_front->prev(new_node);
        } else {
            tail = head;
        }
    }
    ++size_;
}

template<typename T>
void structures::DoublyCircularList<T>::
insert(const T& data, std::size_t index) {
    if (index > size_) {
        throw std::out_of_range("Index inválido");
    }
    if (empty() || index == 0) {
        return push_front(data);
    } else {
        Node *new_node = new Node(data);
        if (new_node == nullptr) {
            throw std::out_of_range("Lista cheia");
        } else {
            Node *before = head;
            for (int i = 0; i < index - 1; i++) {
                before = before->next();
            }
            new_node->next(before->next());
            before->next(new_node);
            new_node->prev(before);

            if (new_node->next() != nullptr) {
                new_node->next()->prev(new_node);
            } else {
                tail = new_node;
            }
        }
    }
    ++size_;
}

template<typename T>
void structures::DoublyCircularList<T>::insert_sorted(const T& data) {
    if (empty()) {
        return push_front(data);
    }

    Node *current = head;
    int i_ = 0;
    while (current->next() != nullptr) {
        if (data <= at(i_)) {
            break;
        }
        ++i_;
        current = current->next();
    }
    if (current->data() < data) {
        return insert(data, ++i_);
    }
    return insert(data, i_);
}

template<typename T>
T structures::DoublyCircularList<T>::pop(std::size_t index) {
    T poped_data;
    if (empty()) {
        throw std::out_of_range("Lista vazia");
    } else if (index >= size()  || index < 0) {
        throw std::out_of_range("Index inválido");
    } else if (index == 0) {
        return pop_front();
    } else {
        Node *before = head;
        Node *current = head;

        for (int i = 0; i < index; i++) {
            before = current;
            current = current->next();
        }

        before->next(current->next());
        Node *next_node = current->next();
        if (next_node == nullptr) {
            tail = before;
        } else {
            next_node->prev(before);
        }
        poped_data = current->data();
        delete current;
        --size_;
    }

    return poped_data;
}

template<typename T>
T structures::DoublyCircularList<T>::pop_back() {
    return pop(size() - 1);
}

template<typename T>
T structures::DoublyCircularList<T>::pop_front() {
    T poped_data;
    if (empty()) {
        throw std::out_of_range("Lista vazia");
    }  else {
        Node *should_be_deleted = head;
        Node *second = head->next();
        poped_data = head->data();
        head = second;
        if (head == nullptr) {
            tail = nullptr;
        } else {
            head->prev(nullptr);
        }
        delete should_be_deleted;
        --size_;
    }

    return poped_data;
}

template<typename T>
void structures::DoublyCircularList<T>::remove(const T& data) {
    pop(find(data));
}

template<typename T>
bool structures::DoublyCircularList<T>::empty() const {
    return (size() == 0);
}

template<typename T>
bool structures::DoublyCircularList<T>::contains(const T& data) const {
    if (empty()) {
        throw std::out_of_range("Lista vazia");
    }
    Node *current = head;
    for (int i = 0; i < size(); i++) {
        if (current->data() == data) {
            return 1;
        }
        if (i < size() - 1) {
            current = current->next();
        }
    }

    return 0;
}

template<typename T>
T& structures::DoublyCircularList<T>::at(std::size_t index) {
    if (index >= size() || index < 0) {
        throw std::out_of_range("Index inválido");
    }

    Node *current = head;
    for (int i = 0; i < index; i++) {
        current = current->next();
    }

    return current->data();
}

template<typename T>
const T& structures::DoublyCircularList<T>::at(std::size_t index) const {
    if (index >= size() || index < 0) {
        throw std::out_of_range("Index inválido");
    }

    Node *current = head;
    for (int i = 0; i < index; i++) {
        current = current->next();
    }

    return current->data();
}

template<typename T>
std::size_t structures::DoublyCircularList<T>::find(const T& data) const {
    if (empty()) {
        throw std::out_of_range("Lista vazia");
    }
    std::size_t i = 0;
    Node *current = head;
    while (current != nullptr) {
        if (current->data() == data) {
            break;
        }
        ++i;
        current = current->next();
    }
    return i;
}

template<typename T>
std::size_t structures::DoublyCircularList<T>::size() const {
    return size_;
}
