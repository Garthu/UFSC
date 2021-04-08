#ifndef VALIDATION_H
#define VALIDATION_H

#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <stdexcept>
#include "array_stack.h"
#include "recursiveXML.h"

using namespace std;
//! validation
/*!
* Função serve para validação dos arquivos XML e extrair seus dados:
* -> As matrizes
* -> As dimensões
* Passamos o XML como parametro da funçao
* Passos do Programa
* 1) Abre o arquivo XML.
* 2) Percorre a linha procurando um "<".
* 3) Salva conteúdo de height,width e matriz em variáveis separadas.
* 4) Quando o cursor está na tag a tag é escrita.
* 5) Quando o cursor está nos dados o contents é escrito.
* 6) Quando verifica que existe um / verifica que é uma tag de fechamento.
* 7) Se a tag ">" é de fechamento tiramos o elemento da pilha
* 8) Verifica se todos os elementos da pilha foram retirados se não retorna erro
*/
bool validation(char arquivo[100]){
    structures::ArrayStack<string> arrayStack(7);  // Construtor simples
    ifstream arquivoXML;
    int height = 0;  // Define a altura da "matriz"
    int width = 0;  // Define a largura da "matriz"
    bool onTag = 0;  // Nos informa se o cursor está dentro da tag
    bool openTag = 1;  // Nos informa se a Tag é de fechamento ou abertura
    bool onContent = 0;  // Nos informa se estamos na parte de dados
    string linha;  // Armazena temporariamente a linha x do arquivo
    string tag = "";  // Armazena temporariamente a tag
    string content = "";  // Armazena temporariamente o dado principal
    string name = "";  // Armazena temporariamente o nome do arquivo em loop
    string result = ""; // Armazena até o fim do programa o resultado

    //! Abre o arquivo XML
    arquivoXML.open(arquivo);

    //! Faz a verificação para saber se o arquivo foi aberto com sucesso
    if (arquivoXML.is_open()) {
        string linha;

        //! Percorre as linhas do arquivo
        while(getline(arquivoXML, linha)) {
            for(int i = 0; i < linha.size(); i++) {
                //! Quando o arquivo tem um < no cursor, a tag foi aberta
                if (linha[i] == '<') {

                    if (content != "") {
                        if (tag == "height") {
                            height = stoi(content);
                        } else if (tag == "width") {
                            width = stoi(content);
                        } else if (tag == "name") {
                            name = content;
                        } else if (tag == "data") {
                        	if (result != "") {
                        		result += "\n";
                        	}
                            int number = recursiveXML(&content, &height, &width);
                            result += name + " " + to_string(number);
                        }
                    }
                    tag = "";

                    onTag = 1;
                    onContent = 0;
                    content = "";
                    openTag = 1;

                 //! Quando o arquivo tem uma / no cursor, a tag é de fechamento
                } else if (linha[i] == '/') {
                    openTag = 0;
                    //! Quando o arquivo tem um > no cursor, a tag foi fechada
                } else if (linha[i] == '>') {
                    //! Se é tag de abertura, colocamos na pilha
                    if (openTag) {
                        arrayStack.push(tag);
                    //! Se é tag de fechamento, tiramos o elemento da pilha
                    } else {
                        if (arrayStack.top() == tag) {
                            arrayStack.pop();
                        //! Caso o elemento do topo seja distinto da tag, um erro é gerado
                        } else {
                            cout << "error";
                            return 0;
                        }
                    }
                    onTag = 0;
                    onContent = 1;
                }

                //! Quando o cursor está na tag, a tag é escrita
                if (onTag == 1) {
                    if (linha[i] != '<' && linha[i] != '/')
                        tag += linha[i];
                //! Quando o cursor está nos dados, o content é escrito
                } else if (onContent = 1) {
                    if (linha[i] != '>') {
                        content += linha[i];
                    } 
                }
            }
        }

    //! Valida se todos os elementos foram retirados da pilha
        if (!arrayStack.empty()) {
            cout << "error";
            return 0;
        }
    
    //! Se o arquivo teve problemas para abrir, retorna um erro
    } else {
    	cout << "error";
        return 0;
    }

    // Printa o resultado
    cout << result;

    return 1;
}


#endif