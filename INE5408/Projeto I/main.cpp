#include <iostream>
#include <fstream>
#include "XMLValidation.h"

using namespace std;

int main() {

    char xmlfilename[100];

    cin >> xmlfilename;  // Entra (Nome do arquivo)

    validation(xmlfilename); // Função responsável por validar e iniciar a segunda etápa
    
    return 0;
}
