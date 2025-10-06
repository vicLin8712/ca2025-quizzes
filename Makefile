all: build/q1-vector build/q1-uf8 build/q1-bfloat16

build:
	mkdir -p build

build/q1-vector: q1-vector.c | build
	gcc -Wall -O2 -o $@ $<

build/q1-uf8: q1-uf8.c | build
	gcc -Wall -O2 -o $@ $<

build/q1-bfloat16: q1-bfloat16.c | build
	gcc -Wall -O2 -o $@ $<

clean:
	rm -rf build
