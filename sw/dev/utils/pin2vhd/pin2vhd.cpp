#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define MAX_PINS		500

typedef struct
{
	char name[256];
	bool vector;
	int lower;
	int upper;

} PIN_T;

PIN_T pin[MAX_PINS];
int npins;

// returns true if a vector
bool strip_name (char *name)
{
	char *p;

	// remove trailing '[' off vector
	if ((p = strrchr (name,'[')) != 0)
	{
		*p = '\0';
		return (true);
	}
	return (false);
}

int find_pin (char *name)
{
	char s_name[256];
	strcpy (s_name, name);
	strip_name (s_name);
	//printf ("%s(%s)\n", __FUNCTION__, s_name);

	for (int i=0; i<npins; i++)
		if (!strcmp (s_name, pin[i].name))
			return (i);

	return (-1);
}

int add_pin (char *name)
{
	char s_name[256];

	strcpy (s_name, name);
	bool vec = strip_name (s_name);
	//printf ("%s(%s)\n", __FUNCTION__, name);

	strcpy (pin[npins].name, s_name);
	pin[npins].vector = vec;
	if (vec)
	{
		char *p = strchr (name, '[');
		if (!p) exit (0);
		p++;
		int n = atoi(p);
		//printf ("i = %d\n", i);
		pin[npins].lower = n;
		pin[npins].upper = n;
	}
	npins++;
}

int update_pin (int i, char *name)
{
	char s_name[256];

	strcpy (s_name, name);
	bool vec = strip_name (s_name);
	//printf ("%s(%s)\n", __FUNCTION__, name);

	if (vec)
	{
		char *p = strchr (name, '[');
		if (!p) exit (0);
		p++;
		int n = atoi(p);
		//printf ("i = %d\n", n);
		if (n < pin[i].lower)
			pin[i].lower = n;
		else if (n > pin[i].upper)
			pin[i].upper = n;
	}
}

int main (int argc, char *argv[])
{
	if (--argc != 1)
		exit (0);

	FILE *fp = fopen (argv[1], "rt");
	if (!fp) exit (0);

	char buf[1024];
	npins = 0;

	while (!feof (fp))
	{
		fgets (buf, 1023, fp);
		if (!strstr (buf, "set_location_assignment"))
			continue;

		char *p = strstr (buf, "PIN_");
		if (!p)
		{
			fprintf (stderr, buf);
			fprintf (stderr, "\"PIN_\" not found!\n");
			continue;
		}
		p = strstr (p, "-to ");
		if (!p)
		{
			fprintf (stderr, "\"-to \" not found!\n");
			continue;
		}
		p += 4;
		while (isspace(*p)) p++;

		char *q = p;
		while (!isspace(*q)) q++;
		*q = '\0';

		int i;
		//printf ("name=%s\n", p);
		if ((i = find_pin (p)) == -1)
			add_pin (p);
		else
			update_pin (i, p);

		if (npins == MAX_PINS)
			break;
	}

	fclose (fp);

	int i;
	for (i=0; i<npins; i++)
	{
		printf ("%-32.32s : in std_logic", pin[i].name);
		if (pin[i].vector)
			printf ("_vector(%d downto %d)", pin[i].upper, pin[i].lower);
		printf (";\n");
	}
	fprintf (stderr, "npins = %d\n", npins);
}
