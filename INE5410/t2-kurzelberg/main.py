import sys
import time
from datetime import timedelta
import multiprocessing

from threading import Thread
from multiprocessing import Process, current_process
from concurrent.futures import ThreadPoolExecutor
from concurrent.futures import ProcessPoolExecutor
from multiprocessing import Pool

def process_work(matrizes, threads_number, process_id, matrix_number):
    with ThreadPoolExecutor(max_workers = threads_number) as pool:
        return_text = ''
        total_erros = 0
        thread_futures = []
        tarefas = [x for x in range(27)]

        if (threads_number > 27):
            threads_number = 27

        for i in range(len(matrizes)):
            return_text += '\nProcesso %d resolve quebra-cabeças %d:\n' % ((process_id), (matrix_number+i))
            matriz = matrizes[i]

            values = array_division(tarefas, threads_number)

            for j in range(threads_number):
                thread_futures.append(pool.submit(thread_work, matriz, values[j], j))
            for j in range(threads_number):
                total_erros += thread_futures[j].result()[0]
                return_text += thread_futures[j].result()[1]
            
            thread_futures = []

            if (i == len(matrizes)-1):
                return_text += 'Erros encontrados: %d.' % total_erros
            else:
                return_text += 'Erros encontrados: %d.\n' % total_erros

            total_erros = 0
        
        for i in range(threads_number):
            pool.shutdown()

    return return_text

def thread_work(matriz, values, thread):
    erros = 0
    mensagem = ''
    for i in range(len(values)):
        value = values[i]
        if (value < 9):
            response = verifica_linha(matriz, value, thread)
            if (response[0] == 1):
                erros += 1
                mensagem += response[1]
        elif (value < 18):
            response = verifica_coluna(matriz, value-9, thread)
            if (response[0] == 1):
                erros += 1
                mensagem += response[1]
        elif (value < 27):
            response = verifica_regiao(matriz, value-18, thread)
            if (response[0] == 1):
                erros += 1
                mensagem += response[1]

    return (erros, mensagem)

def array_division(values, threads_number):
    return [values[i*len(values) // threads_number: (i+1)*len(values) // threads_number]for i in range(threads_number)]

def verifica_linha(matriz, linha, thread):
    numeros = []
    for i in range(9):
        if (matriz[linha][i] in numeros):
            return (1, "Thread %d: erro na linha %d.\n" % ((thread+1), (linha+1)))
        else:
            numeros.append(matriz[linha][i])
    
    return (0, '')

def verifica_coluna(matriz, coluna, thread):
    numeros = []
    for i in range(9):
        if (matriz[i][coluna] in numeros):
            return (1, "Thread %d: erro na coluna %d.\n" % ((thread+1), (coluna+1)))
        else:
            numeros.append(matriz[i][coluna])
    
    return (0, '')

def verifica_regiao(matriz, index, thread):
    regioes = [(0,0),(0,3),(0,6),(3,0),(3,3),(3,6),(6,0),(6,3),(6,6)]
    linha = regioes[index-1][0]
    coluna = regioes[index-1][1]
    numeros = []
    for i in range(linha, linha+3):
        for j in range(coluna, coluna+3):
            if (matriz[i][j] in numeros):
                return (1, "Thread %d: erro na regiao %d.\n" % ((thread+1), (index)))
            else:
                numeros.append(matriz[i][j])
    return (0, '')

def main(argv):
    start_time = time.monotonic()
    process_number = int(argv[2])
    threads_number = int(argv[3])
    lista_de_matrizes = []
    matriz = []
    linha = []
    
    with open(argv[1], 'r') as matrizes:
        for line in matrizes:
            if (line != '\n'):
                linha = (list(map(int, line.split())))
                matriz.append(linha)
            else:
                lista_de_matrizes.append(matriz)
                matriz = []
        else:
            lista_de_matrizes.append(matriz)

    
    if (process_number > len(lista_de_matrizes)):
        process_number = len(lista_de_matrizes)

    values = array_division(lista_de_matrizes, process_number)
    matriz_base = 1
    
    with ProcessPoolExecutor(max_workers = process_number) as executor:
        futures = []
        for i in range(process_number):
            futures.append(executor.submit(process_work, values[i], threads_number, i+1, matriz_base))
            matriz_base += len(values[i])
        for i in range(process_number):
            lista_de_matrizes.pop(-1)
            if i != process_number-1:
                print(futures[i].result())
            else:
                print(futures[i].result(), end='')
            
        for i in range(process_number):
            executor.shutdown()

    end_time = time.monotonic()
    print()
    print('Tempo total: ', timedelta(seconds=end_time - start_time))
    print(multiprocessing.cpu_count())

if __name__ == "__main__":
    main(sys.argv)