#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include "types.h"
#include <sys/queue.h>
#include "queue.c"

TicketCaller* pc;
pthread_mutex_t mutex_cliente;
pthread_mutex_t mutex_retrieved_ticket;
pthread_mutex_t mutex_queue;

sem_t sem_espera_cliente;

sem_t* sem_client;
sem_t* sem_clerk;

sem_t sem_cooker;

void client_inform_order(order_t* od, int clerk_id) {
	pc->clerks_order_spot[clerk_id] = od;
	sem_post(&sem_clerk[clerk_id]);
}

void client_think_order() {
	sleep(rand() % (clientMaxThinkSec + CLIENT_MIN_THINK_SEC) + CLIENT_MIN_THINK_SEC);
}

void client_wait_order(order_t* od) {
	sem_wait(&sem_client[od->client_id]);
}

void clerk_create_order(order_t* od) {
	pthread_mutex_lock(&mutex_queue);
    enqueue(od);
    pthread_mutex_unlock(&mutex_queue);
    sem_post(&sem_cooker);
}
void clerk_annotate_order() {
	sleep(rand() % (clerkMaxWaitSec + CLERK_MIN_WAIT_SEC) + CLERK_MIN_WAIT_SEC);
}

void cooker_wait_cook_time() {
	sleep(rand() % (cookMaxWaitSec + COOK_MIN_WAIT_SEC) + COOK_MIN_WAIT_SEC);
}

void* client(void *args) {
	client_t client = *(client_t *) args;

	// Pega o ticket único
	pthread_mutex_lock(&mutex_cliente);
	int senha_cliente = get_unique_ticket(pc);
	pthread_mutex_unlock(&mutex_cliente);

	// Avisa que chegou um client
	sem_post(&sem_espera_cliente);

	int numero_funcionario_chamado;

	int on_loop = 1;
	while(on_loop) {
		int *senhas = show_current_tickets(pc);
		for (int i = 0; i < numClerks; i++) {
			if (senhas[i] == senha_cliente) {
				numero_funcionario_chamado = i;
				on_loop = 0;
			}
		}
		free(senhas);
	}

	client_think_order();

	order_t pedido;
	pedido.password_num = senha_cliente;
	pedido.client_id = client.id;

	// Libera o funcionário
	client_inform_order(&pedido, numero_funcionario_chamado);
	client_wait_order(&pedido);
}

void* clerk(void *args) {
	clerk_t clerk = *(clerk_t *) args;

	while(true) {
		while (true) {
			// Espera um cliente
			sem_wait(&sem_espera_cliente);

			// Pega uma senha já retirada pelo cliente
			pthread_mutex_lock(&mutex_retrieved_ticket);
			int senha_cliente = get_retrieved_ticket(pc);
			pthread_mutex_unlock(&mutex_retrieved_ticket);
			// Coloca 
			set_current_ticket(pc, senha_cliente, clerk.id);
			if (senha_cliente != -1) {
				break;
			} else {
				sem_post(&sem_espera_cliente);
				return 0;
			}
		}

		// Espera o client fazer o pedido
		sem_wait(&sem_clerk[clerk.id]);

		clerk_annotate_order();

		order_t* order = pc->clerks_order_spot[clerk.id];
		pc->clerks_order_spot[clerk.id] = NULL;

		anounce_clerk_order(order);

		clerk_create_order(order);
	}
}

void* cooker(void *args) {
	int num_plates = 0;

	while(num_plates < numClients) {
		sem_wait(&sem_cooker);
		pthread_mutex_lock(&mutex_queue);
		order_t *poped_data = dequeue();
		pthread_mutex_unlock(&mutex_queue);
		if (poped_data == NULL) {
			continue;
		}
		num_plates++;

		cooker_wait_cook_time();
		anounce_cooker_order(poped_data);
		sem_post(&sem_client[poped_data->client_id]);
	}

	sem_post(&sem_espera_cliente);
}

int main(int argc, char *argv[]) {
	parseArgs(argc, argv);
	pc = init_ticket_caller();
	
	pthread_mutex_init(&mutex_cliente,NULL);
	pthread_mutex_init(&mutex_retrieved_ticket,NULL);
	pthread_mutex_init(&mutex_queue,NULL);

	sem_init(&sem_espera_cliente,0,0);
	sem_init(&sem_cooker,0,0);

	sem_client = malloc(numClients*sizeof(sem_t));
	sem_clerk = malloc(numClerks*sizeof(sem_t));

	for (int i = 0; i < numClients; i++) {
		sem_init(&sem_client[i], 0, 0);
	}
	for (int i = 0; i < numClerks; i++) {
		sem_init(&sem_clerk[i], 0, 0);
	}

	client_t cliente[numClients];
	clerk_t atendente[numClerks];

	pthread_t thread_clientes[numClients];
    pthread_t thread_funcionarios[numClerks];
    pthread_t thread_cooker;
	
	if (numClerks != 0) {
		for (int i = 0; i < numClients; i++) {
			cliente[i].id = i;
			pthread_create(&thread_clientes[i], NULL, client, (void *)&cliente[i]);
		}
		for (int i = 0; i < numClerks; i++) {
			atendente[i].id = i;
			pthread_create(&thread_funcionarios[i],NULL,clerk, (void *)&atendente[i]);
		}

		pthread_create(&thread_cooker, NULL, cooker, NULL);

		for (int i = 0; i < numClients; i++) {
			pthread_join(thread_clientes[i], NULL);
		}
		for (int i = 0; i < numClerks; i++) {
			pthread_join(thread_funcionarios[i],NULL);
		}

		pthread_join(thread_cooker, NULL);
	}


	for (int i = 0; i < numClients; i++) {
		sem_destroy(&sem_client[i]);
	}
	for (int i = 0; i < numClerks; i++) {
		sem_destroy(&sem_clerk[i]);
	}

	sem_destroy(&sem_espera_cliente);
	sem_destroy(&sem_cooker);

	pthread_mutex_destroy(&mutex_queue);
	pthread_mutex_destroy(&mutex_retrieved_ticket);
	pthread_mutex_destroy(&mutex_cliente);

	return 0;
}
