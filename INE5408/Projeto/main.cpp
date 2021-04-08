#include <iostream>
#include <fstream>
#include "XMLValidation.h"

using namespace std;

int main() {

    char xmlfilename[100];

    cin >> xmlfilename;  // entrada

    ifstream arquivoXML;
    string linha;
    arquivoXML.open(xmlfilename);

    if (arquivoXML.is_open()) {
    	for (getline(arquivoXML, linha)) {
    		cout << linha << endl;
    	}
    } else {
    	cout << "Erro" << endl;
    }

    return 0;
}