#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

//        (pai)
//          |
//      +---+---+
//      |       |
//     sed    grep

// ~~~ printfs  ~~~
//        sed (ao iniciar): "sed PID %d iniciado\n"
//       grep (ao iniciar): "grep PID %d iniciado\n"
//          pai (ao iniciar): "Processo pai iniciado\n"
// pai (após filho terminar): "grep retornou com código %d,%s encontrou adamantium\n"
//                            , onde %s é
//                              - ""    , se filho saiu com código 0
//                              - " não" , caso contrário

// Obs:
// - processo pai deve esperar pelo filho
// - 1º filho, após o término do 1º deve trocar seu binário para executar
//   sed -i /silver/axamantium/g;s/adamantium/silver/g;s/axamantium/adamantium/g text
//   + dica: leia as dicas do grep
// - 2º filho deve trocar seu binário para executar "grep adamantium text"
//   + dica: use execlp(char*, char*...)
//   + dica: em "grep adamantium text",  argv = {"grep", "adamantium", "text"}

void sed() {
    pid_t pid = fork();

    if (pid < 0) {
        printf("Erro na criação do processo!\n");
        fflush(stdout);
    }

    if (pid == 0) {
        printf("sed PID %d iniciado\n", getpid());
        fflush(stdout);
        execlp("/bin/sed", "sed", "-i", "-e", "s/silver/axamantium/g;s/adamantium/silver/g;s/axamantium/adamantium/g", "text", NULL);
        exit(0);
    }
}

void grep() {
    pid_t pid = fork();

    if (pid < 0) {
        printf("Erro na criação do processo!\n");
        fflush(stdout);
    }

    if(pid == 0) {
        printf("grep PID %d iniciado\n", getpid());
        fflush(stdout);
        execlp("/bin/grep", "grep", "adamantium", "text", NULL);
        exit(0);
    }
}

int main(int argc, char** argv) {
    printf("Processo pai iniciado\n");

    sed();
    wait(NULL);
    grep();

    int grep_exit;
    wait(&grep_exit);
    int grep_status = WEXITSTATUS(grep_exit);

    if (!grep_status) {
        printf("grep retornou com código 0, encontrou adamantium\n");
        fflush(stdout);
    } else {
        printf("grep retornou com código %d, não encontrou adamantium\n", grep_status);
        fflush(stdout);
    }

    return 0;
}#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>

//        (pai)
//          |
//      +---+---+
//      |       |
//     sed    grep

// ~~~ printfs  ~~~
//        sed (ao iniciar): "sed PID %d iniciado\n"
//       grep (ao iniciar): "grep PID %d iniciado\n"
//          pai (ao iniciar): "Processo pai iniciado\n"
// pai (após filho terminar): "grep retornou com código %d,%s encontrou adamantium\n"
//                            , onde %s é
//                              - ""    , se filho saiu com código 0
//                              - " não" , caso contrário

// Obs:
// - processo pai deve esperar pelo filho
// - 1º filho, após o término do 1º deve trocar seu binário para executar
//   sed -i /silver/axamantium/g;s/adamantium/silver/g;s/axamantium/adamantium/g text
//   + dica: leia as dicas do grep
// - 2º filho deve trocar seu binário para executar "grep adamantium text"
//   + dica: use execlp(char*, char*...)
//   + dica: em "grep adamantium text",  argv = {"grep", "adamantium", "text"}

void sed() {
    pid_t pid = fork();

    if (pid < 0) {
        printf("Erro na criação do processo!\n");
        fflush(stdout);
    }

    if (pid == 0) {
        printf("sed PID %d iniciado\n", getpid());
        fflush(stdout);
        execlp("/bin/sed", "sed", "-i", "-e", "s/silver/axamantium/g;s/adamantium/silver/g;s/axamantium/adamantium/g", "text", NULL);
        exit(0);
    }
}

void grep() {
    pid_t pid = fork();

    if (pid < 0) {
        printf("Erro na criação do processo!\n");
        fflush(stdout);
    }

    if(pid == 0) {
        printf("grep PID %d iniciado\n", getpid());
        fflush(stdout);
        execlp("/bin/grep", "grep", "adamantium", "text", NULL);
        exit(0);
    }
}

int main(int argc, char** argv) {
    printf("Processo pai iniciado\n");

    sed();
    wait(NULL);
    grep();

    int grep_exit;
    wait(&grep_exit);
    int grep_status = WEXITSTATUS(grep_exit);

    if (!grep_status) {
        printf("grep retornou com código 0, encontrou adamantium\n");
        fflush(stdout);
    } else {
        printf("grep retornou com código %d, não encontrou adamantium\n", grep_status);
        fflush(stdout);
    }

    return 0;
}