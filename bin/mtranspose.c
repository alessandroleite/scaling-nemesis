#include <stdio.h>
#include <stdlib.h>

// #define L 4000
#define R 10

int main(int argc, char **argv) {

	long int t, n;	
	long s = 0;

	int *m;
	int i, j, it;

	if (argc < 4) {
		printf("Usage <matrix size> <sleep time in seconds> <number of iteractions>\n");
		exit(-1);
	} else {
		if (sscanf(argv[1], "%d", &n) != 1) {
			printf("Matrix size scanf failed.\n");
			exit(-1);
		}

		if (sscanf(argv[2], "%d", &t) != 1) {
			printf("Sleep time scanf failed.\n");
			exit(-1);
		}
		
		if (sscanf(argv[3], "%d", &it) != 1) {
			printf("Iterations scanf failed.\n");
			exit(-1);
		}
	}

	m = malloc(n * n * sizeof(int));	

	for (i = 0; i < n; i++)
	{
		for (j = 0; j < n; j++)
		{
			m[i * n + j] = rand();
		}
	}
		

	printf("Going to sleep\n");
	sleep(t);
	printf("I am awake\n");

    while (it > 0)
	{
		for (i = 0; i < n; i++)
		{
			for (j = 0; j < n; j++)
			{
				s += m[i * n + j];
			}
		}
		it--;
	}
	
	printf("S = %lu\n", s);
	free(m);
}

