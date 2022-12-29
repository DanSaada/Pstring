a.out: main.o run_main.o func_select.o pstring.o
	gcc -g -o a.out main.o run_main.o func_select.o pstring.o -no-pie

main.o: main.c pstring.h
	gcc -g -c -o main.o main.c

run_main.o: run_main.s pstring.h
	gcc -g -c -o run_main.o run_main.s

func_select.o: func_select.s pstring.h
	gcc -g -c -o func_select.o func_select.s

pstring.o: pstring.s
	gcc -g -c -o pstring.o pstring.s

clean:
	rm -f *.o a.out
