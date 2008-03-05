#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main (int argc, char *argv[])
{
	double P_2dB = pow(10, -2.0/10.0);
	double A_2dB = sqrt(P_2dB);

	printf ("P_2dB = %lf\n", P_2dB);
	printf ("A_2dB = %lf\n", A_2dB);

	for (int i=1; i<15; i++)
	{
		double d = pow(A_2dB, i);
		int ii = (int)(16384.0 * d + 0.5);
		//printf ("d = %lf = %5d = ", d, ii);
		printf ("%2d => \"", i);
		for (int b=13; b>=0; b--)
			printf ("%d", (ii & (1<<b) ? 1 : 0));
		printf ("\", -- %+2ddB\n", -i*2);
	}
}

