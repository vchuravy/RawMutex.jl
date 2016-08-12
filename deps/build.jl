run(`gcc -c -Wall -fpic uv.c`)
run(`gcc -shared -o libshimuv.so uv.o`)
