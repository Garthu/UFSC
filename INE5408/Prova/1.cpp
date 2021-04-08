template<typename T>
void structures::ArrayQueur<T>::inverteFila(ArrayQueue *f) {
	copyData = new T[f->size()];
	int size = f->size();

	for (int i = 0; i < (size - 1); i++) {
		copyData[i] = f->dequeue();
	}

	f->clear();

	for (int i = 0; i < (size - 1); i++) {
		f->enqueue(copyData[i]);
	}
}