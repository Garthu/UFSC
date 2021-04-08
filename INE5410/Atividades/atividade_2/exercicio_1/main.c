#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

//       (pai)      
//         |        
//    +----+----+
//    |         |   
// filho_1   filho_2


// ~~~ printfs  ~~~
// pai (ao criar filho): "Processo pai criou %d\n"
//    pai (ao terminar): "Processo pai finalizado!\n"
//  filhos (ao iniciar): "Processo filho %d criado\n"

// Obs:
// - pai deve esperar pelos filhos antes de terminar!
void raise_child() {
    fflush(stdout);
    pid_t pid = fork();

    if (pid < 0) {
        printf("Erro na criação do processo\n");
        fflush(stdout);
    }

    else if (pid == 0) {
        printf("Processo filho %d criado\n", getpid());
        fflush(stdout);
        exit(0);
    } else {
    	printf("Processo pai criou %d\n", pid);
    	fflush(stdout);
    }
}

int main(int argc, char** argv) {

    for (int i = 0; i <= 1; i++) {
        raise_child();
    }

    /*************************************************
     * Dicas:                                        *
     * 1. Leia as intruções antes do main().         *
     * 2. Faça os prints exatamente como solicitado. *
     * 3. Espere o término dos filhos                *
     *************************************************/
    wait(NULL);
    wait(NULL);

    printf("Processo pai finalizado!\n");   
    return 0;
}