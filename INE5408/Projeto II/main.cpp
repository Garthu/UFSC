#include <iostream>

#include "trie_struct.h"
#include "txtread.h"

int main() {
    
    using namespace std;

    string filename;
    string word;

    cin >> filename;  // entrada

    struct Branch *root = getNode();
    txt_read(filename, root);
    
    while (1) {  // leitura das palavras ate' encontrar "0"
        cin >> word;
        if (word.compare("0") == 0) {
            break;
        }

        int prefix_number = search(root, word);

        if (prefix_number == 0) {
            cout << word << " is not prefix" << endl;
        } else {
            cout << word << " is prefix of " << search(root, word) << " words" << endl;
        }
        
        struct Branch *ptr = isOneWord(root, word);
        
        if (ptr == NULL) {
            continue;
        } else if (ptr->isOneWord == 0) {
            continue;
        } else {
            cout << word << " is at (" << ptr->count_char << "," << ptr->count_line << ")" << endl;
        }
    }

    return 0;
}
