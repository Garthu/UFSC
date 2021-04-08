T removeDoInicio(Lista *p) {
    if (p->tamanho == 0) {
        throw std::out_of_range("Lista vazia");
    }
    T copyData = p->movel->dado;
    --tamanho;

    if (p->tamanho == 1) {
        delete p->movel;
        p->movel = nullptr;
        p->pos_movel = 0;
    } else {
        while (p->pos_movel > 0) {
            p->movel = p->movel->ant();
            --p->pos_movel;
        }
        Node* t = p->movel;
        p->movel->ant->next = p->movel->next;
        p->movel->next->ant = p->movel->ant;
        delete t;
    }
    return copyData;
}