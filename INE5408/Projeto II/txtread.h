#include <iostream>
#include "Lista.h"
#include <fstream>
#include <string>
#include <sstream>
#include <tuple>

using namespace std;

void txt_read(string arquivo, Branch *root) {
    ifstream arquivotxt;
    string word = "";
    bool onWord = 0;
    int count_char = 0;
    int count_line = 0;
    int count_global = 0;
    arquivotxt.open(arquivo);

    if (arquivotxt.is_open()) {
        string linha;
        while(getline(arquivotxt, linha)) {
            for (int i = 0; i < linha.size(); i++) {
                if (linha[i] == '[' && i == 0) {
                    if (count_global != 0) {
                        insert(root, word, count_char, count_line);
                        count_global++;
                    }
                    count_char = count_global;
                    word = "";
                    count_line = linha.size();
                    onWord = 1;
                }
                if (linha[i] == ']') {
                    onWord = 0;
                }
                if (onWord == 1) {
                    if (linha[i] != '[' && linha[i] != ']') {
                        word += linha[i];
                    }
                }
                ++count_global;
            }
        }
    }
    insert(root, word, count_char, count_line);
}