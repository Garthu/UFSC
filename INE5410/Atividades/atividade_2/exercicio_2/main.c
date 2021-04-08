#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

//                          (principal)
//                               |
//              +----------------+--------------+
//              |                               |
//           filho_1                         filho_2
//              |                               |
//    +---------+-----------+          +--------+--------+
//    |         |           |          |        |        |
// neto_1_1  neto_1_2  neto_1_3     neto_2_1 neto_2_2 neto_2_3

// ~~~ printfs  ~~~
//      principal (ao finalizar): "Processo principal %d finalizado\n"
// filhos e netos (ao finalizar): "Processo %d finalizado\n"
//    filhos e netos (ao inciar): "Processo %d, filho de %d\n"

// Obs:
// - netos devem esperar 5 segundos antes de imprmir a mensagem de finalizado (e terminar)
// - pais devem esperar pelos seu descendentes diretos antes de terminar
void raise_grandson() {
    fflush(stdout);
    pid_t grandson_pid = fork();

    if (grandson_pid < 0) {
        printf("Erro na criação do processo!\n");
    }

    if (grandson_pid == 0) {
        printf("Processo %d, filho de %d\n", getpid(), getppid());
        sleep(5);
        printf("Processo %d finalizado\n", getpid());
        exit(0);
    }
}

void raise_sun() {
    fflush(stdout);
    pid_t pid = fork();

    if (pid < 0) {
        printf("Erro na criação do processo!\n");
    }

    if (pid == 0) {

        printf("Processo %d, filho de %d\n", getpid(), getppid());

        for (int j = 0; j <= 2; j++) {
            raise_grandson();
        }
        wait(NULL);
        wait(NULL);
        wait(NULL);
        printf("Processo %d finalizado\n", getpid());
        exit(0);
    }
}

int main(int argc, char** argv) {
    
       for (int i = 0; i <= 1; i++) {
           raise_sun();
       }

    /*************************************************
     * Dicas:                                        *
     * 1. Leia as intruções antes do main().         *
     * 2. Faça os prints exatamente como solicitado. *
     * 3. Espere o término dos filhos                *
     *************************************************/
       wait(NULL);
       wait(NULL);

    printf("Processo principal %d finalizado\n", getpid());    
    return 0;
}