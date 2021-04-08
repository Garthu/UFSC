#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
#include <pthread.h>
#include <time.h>
#include <semaphore.h>

int produzir(int value);    //< definida em helper.c
void consumir(int produto); //< definida em helper.c
void *produtor_func(void *arg);
void *consumidor_func(void *arg);

int indice_produtor, indice_consumidor, tamanho_buffer;
int* buffer;

sem_t buffer_sem;
sem_t size_sem;

sem_t produtor_sem;
sem_t consumidor_sem;

//Você deve fazer as alterações necessárias nesta função e na função
//consumidor_func para que usem semáforos para coordenar a produção
//e consumo de elementos do buffer.
void *produtor_func(void *arg) {
    //arg contem o número de itens a serem produzidos
    int max = *((int*)arg);
    for (int i = 0; i <= max; ++i) {
        int produto;
        if (i == max)
            return NULL;          //envia produto sinlizando FIM
        else 
            produto = produzir(i); //produz um elemento normal
        
        sem_wait(&size_sem);

        sem_wait(&produtor_sem);
        indice_produtor = (indice_produtor + 1) % tamanho_buffer; //calcula posição próximo elemento
        buffer[indice_produtor] = produto; //adiciona o elemento produzido à lista
        sem_post(&consumidor_sem);

        sem_post(&buffer_sem);
    }

    return NULL;
}

void *consumidor_func(void *arg) {
    int max = *((int*)arg);
    for (int j = 0; j < max; j++) {
        sem_wait(&buffer_sem);

        sem_wait(&consumidor_sem);

        indice_consumidor = (indice_consumidor + 1) % tamanho_buffer; //Calcula o próximo item a consumi
        int produto = buffer[indice_consumidor]; //obtém o item da lista

        sem_post(&produtor_sem);

        sem_post(&size_sem);

        consumir(produto);
    }
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc < 5) {
        printf("Uso: %s tamanho_buffer itens_produzidos n_produtores n_consumidores \n", argv[0]);
        return 0;
    }

    tamanho_buffer = atoi(argv[1]);
    int itens = atoi(argv[2]);
    int n_produtores = atoi(argv[3]);
    int n_consumidores = atoi(argv[4]);
    printf("itens=%d, n_produtores=%d, n_consumidores=%d\n",
	   itens, n_produtores, n_consumidores);

    //Iniciando buffer
    indice_produtor = 0;
    indice_consumidor = 0;
    buffer = malloc(sizeof(int) * tamanho_buffer);

    // Crie threads e o que mais for necessário para que n_produtores
    // threads criem cada uma n_itens produtos e o n_consumidores os
    // consumam.

    pthread_t produtor_thread[n_produtores], consumidor_thread[n_consumidores];

    // Inicia os semáforos
    sem_init(&buffer_sem, 0, 0);
    sem_init(&size_sem, 0, tamanho_buffer);

    sem_init(&produtor_sem, 0, 1);
    sem_init(&consumidor_sem, 0, 1);

    int resto = (itens * n_produtores);
    int number[n_consumidores];
    for (int i = 0; i < n_consumidores; i++) {
        number[i] = (itens * n_produtores) / n_consumidores;
        if (i == (n_consumidores - 1)) {
            number[i] = resto;
        }

        resto -= number[i];
    }

    // Inicia as threads
    for (int i = 0; i < n_produtores; i++) {
        pthread_create(&produtor_thread[i], NULL, (void *)produtor_func, (void *)&itens);
    }
    for (int i = 0; i < n_consumidores; i++) {
        pthread_create(&consumidor_thread[i], NULL, consumidor_func, (void *)&number[i]);
    }

    // Finaliza a threads
    for (int i = 0; i < n_produtores; i++) {
        pthread_join(produtor_thread[i], NULL);
    }
    for (int i = 0; i < n_consumidores; i++) {
        pthread_join(consumidor_thread[i], NULL);
    }

    // Finaliza os semáforos
    sem_destroy(&buffer_sem);
    sem_destroy(&size_sem);

    sem_destroy(&produtor_sem);
    sem_destroy(&consumidor_sem);
    
    //Libera memória do buffer
    free(buffer);

    return 0;
}

