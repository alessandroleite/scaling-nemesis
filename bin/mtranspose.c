#include <stdio.h>
#include <stdlib.h>

// #define L 4000
#define R 10
#define NEW_LINE printf("\n")

void print(void *src, int h, int w)
{
	int i, j;
	int (*m)[h] = src;
	
	for (i = 0; i < h; i++)
	{
		for (j = 0; j < w; j++)
		{
			printf("%d ", m[i][j]);
		}
		NEW_LINE;
	}
}

void fillUp (void *m, int h, int w)
{
	int i, j;
	int (*d)[h] = m;
	
	srand(time(NULL ));
	
	for (i = 0; i < h; i++)
	{
		for (j = 0; j < w; j++)
		{
			d[i][j] = rand();
		}
	}
}

void transpose(void *src, int n)
{
	int i, j, t;
	int (*m)[n] = src;
	
	for (i = 0; i < n - 1; i++)
	{
		for (j = i + 1; j < n; j++)
		{
			t = m[i][j];
			m[i][j] = m[j][i];
			m[j][i] = t;
		}
	}
	src = m;
}

void initialize (int argc, char **argv, int *h, int *w, int *t, int *it/*, int *pid*/)
{
	if (argc < 5) 
	{
		printf("Usage <number of rows> <number of columns> <sleep time in seconds> <number of iteractions> <meter's id>\n");
		exit(-1);
	} 
	else 
	{
		if (sscanf(argv[1], "%d", h) != 1) 
		{
			printf("Number of rows scanf failed.\n");
			exit(-1);
		}
		
		if (sscanf(argv[2], "%d", w) != 1) 
		{
			printf("Number of columns scanf failed.\n");
			exit(-1);
		}

		if (sscanf(argv[3], "%d", t) != 1) 
		{
			printf("Sleep time scanf failed.\n");
			exit(-1);
		}
		
		if (sscanf(argv[4], "%d", it) != 1) 
		{
			printf("Number of iterations scanf failed.\n");
			exit(-1);
		}

		/*if (sscanf(argv[5], "%d", pid) != 1) 
		{
			printf("Meter pid scanf failed.\n");
			exit(-1);
		}*/
	}
}

int main(int argc, char **argv) 
{
	int t, h, w;	
	long s = 0;

	int *m;
	int i, j, it,pid;

	initialize(argc, argv, &h, &w, &t, &it/*,&pid*/);
	
	m = malloc(h * w * sizeof(int));	
	
	fillUp(m, h, w);
			
	printf("Going to sleep\n");
	sleep(t);
	printf("I am awake\n");

	while (it > 0)
	{
		transpose(m,h);
		it--;
	}

	free(m);
}

