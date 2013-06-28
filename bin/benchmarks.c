#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "wattsup.h"

#define N 10


float mean(float a[], int n) 
{
	int i;
	float sum = 0;
	
	for (i = 0; i < n; i++)
	{
		sum += a[i];
	}
	
	return (sum / n);	
}

float variance (float a[], int n, float m)
{
	int i;
	float sum = 0;
	
	for (i = 0; i < n; i++)
	{
		sum += pow(a[i] - m, 2);
	}
	
	return (sum / n);
}

void mean_and_variance(double a[], double b[], float e[], int i, int n)
{
  a[i] = mean(e, n);
  b[i] = variance(e, n, a[i]);
}



//For floating point multiplication
void floating_point_multiplication(double a[], double b[], int argc, char ** argv)
{
   double s = 0.25;
   int i,j, n;
   float e[10000];

   for (n = 10000, j = 0; n < 1000000; n+= 100, j++)
   {
      s = 0.25;
      set_energy_counter(argc, argv);
      for (i = 0; i < n; i++) 
        s = s * 0.3141516;
       
      e[j] = get_consumed_energy();      
      mean_and_variance(a, b, e, 0, j);
   }
}

void addition_substraction(double a[], double b[], int argc, char ** argv)
{
   double s = 0.25;
   int i,j, n;
   float e[10000];

   for (n = 10000, j = 0; n < 1000000; n+= 100, j++)
   {
      s = 0.25;
      set_energy_counter(argc, argv);
      for (i=0; i < n; i++) 
        s = s + 0.3141516;
       
      e[j] = get_consumed_energy();
      // (a[1],b[1]) = mean_and_variance(e, j);
      mean_and_variance(a, b, e, 1, j);
   }
}

void division (double a[], double b[], int argc, char ** argv)
{
   double s = 0.25;
   int i,j, n;
   float e[10000];

   for (n = 10000, j = 0; n < 1000000; n+= 100, j++)
   {
      s = 0.25;
      set_energy_counter(argc, argv);
      for (i = 0; i < n; i++) 
        s = s / 0.3141516;
       
      e[j] = get_consumed_energy();
      mean_and_variance(a, b, e, 2, j);
   }
}

void comparison (double a[], double b[], int argc, char ** argv)
{
   double s = 0.25;
   int i,j, n;
   float e[10000];

   for (n = 10000, j = 0; n < 1000000; n+= 100, j++)
   {
      s = 0.25;
      set_energy_counter(argc, argv);
      for (i = 0; i < n; i++) 
        //an inline assembly code that compare the values of two registers;
		;
       
      e[j] = get_consumed_energy();
      // (a[3],b[3]) = mean_and_variance(e, j);
      mean_and_variance(a, b, e, 3, j);
   }
}

void memory_read (double a[], double b[], int argc, char ** argv)
{
   double s = 0.25;
   int i,j, n;
   float e[10000];

   for (n = 10000, j = 0; n < 1000000; n+= 100, j++)
   {
      s = 0.25;
      set_energy_counter(argc, argv);
      for (i = 0; i < n; i++) 
        //an inline assembly code that load s from memory to a register
		;
       
      e[j] = get_consumed_energy(argc, argv);
      mean_and_variance(a, b, e, 4, j);
   }
}


void memory_write (double a[], double b[], int argc, char ** argv)
{
   double s = 0.25;
   int i,j, n;
   float e[10000];

   for (n = 10000, j = 0; n < 1000000; n+= 100, j++)
   {
      s = 0.25;
      set_energy_counter(argc, argv);
      for (i = 0; i < n; i++) 
        //by an inline assembly code that store the content of a register (or a direct constant) into s on memory.
		;
       
      e[j] = get_consumed_energy();
      //(a[5],b[5]) = mean_and_variance(e, j);
      mean_and_variance(a, b, e, 5, j);
   }
}

int main(int argc, char ** argv)
{
   double a[N];
   double b[N];

   floating_point_multiplication (a, b, argc, argv);
   printf("a = %f, b = %f\n", a[0], b[0]);
   return 0;
   
}
