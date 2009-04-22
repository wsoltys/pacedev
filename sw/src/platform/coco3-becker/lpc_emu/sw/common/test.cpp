#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

typedef struct _MENTRY
{
	char	name[64];
	char	oper[64];
	char	arg1[64];

} MENTRY, *PMENTRY;

typedef struct _MENU
{
	char 		title[64];
	char 		tag[64];
	int			nEntries;
	MENTRY	entries[8];

} MENU, *PMENU;

MENU menus[16];

typedef enum
{
	eKeyMenu, 
	eKeyTitle, eKeyTag, eKeyEntries

} eKEY;

int dump_menu (int nMenus)
{
	printf ("- menu: (%d)\n"
					"  title: \"%s\"\n"
					"  tag: %s\n"
					"  entries: (%d)\n", 
					nMenus+1, menus[nMenus].title, menus[nMenus].tag, menus[nMenus].nEntries);
	for (int i=0; i<menus[nMenus].nEntries; i++)
		printf ("  - name: \"%s\"\n"
						"    oper: %s\n"
						"    arg1: %s\n",
						menus[nMenus].entries[i].name, menus[nMenus].entries[i].oper, menus[nMenus].entries[i].arg1);
}

int parse_menu_yml (char *yml_name, bool verbose=false)
{
	FILE *fp = fopen (yml_name, "rt");
	if (!fp)
		return (-1);

	int nMenus = -1;
	eKEY key;

	while (!feof (fp))
	{
		char buf[256], *p;

		fgets (buf, 255, fp);
		p = buf;

		// trim carriage-return
		while (strlen(p) && isspace(p[strlen(p)-1]))
			buf[strlen(p)-1] = '\0';

		// handle top-level key
		if (*p == '-')
		{
			if (nMenus != -1)
			{
				if (verbose)
					dump_menu (nMenus);
			}

			p += 2;
			if (!strncmp (p, "menu:", 5))
			{
				nMenus++;
				*menus[nMenus].title = '\0';
				*menus[nMenus].tag = '\0';
				menus[nMenus].nEntries = 0;
				key = eKeyMenu;
				continue;
			}
			if (strncmp (p, "EOF", 3))
				fprintf (stderr, "unsupported _menu_ key: \"%s\"\n", p);
			continue;
		}

		// need to find a menu first
		if (nMenus == -1)
			continue;

		// skip leading spaces
		while (isspace(*p)) p++;
		if (!*p) continue;

		if (!strncmp (p, "title:", 6))
		{
			p = strchr (p, '"') + 1;
			strcpy (menus[nMenus].title, p);
			if (p = strchr (menus[nMenus].title, '"')) *p = '\0';
			key = eKeyTitle;
		}
		else if (!strncmp (p, "tag:", 4))
		{
			for (p+=4; isspace(*p); p++);
			strcpy (menus[nMenus].tag, p);
			key = eKeyTag;
		}
		else if (!strncmp (p, "entries:", 8))
		{
			key = eKeyEntries;
		}
		else
		{
			if (key == eKeyEntries)
			{
				if (!strncmp (p, "- name:", 7))
				{
					menus[nMenus].nEntries++;
					p = strchr (p, '"') + 1;
					strcpy (menus[nMenus].entries[menus[nMenus].nEntries-1].name, p);
					if (p = strchr (menus[nMenus].entries[menus[nMenus].nEntries-1].name, '"')) *p = '\0';
					*menus[nMenus].entries[menus[nMenus].nEntries-1].oper = '\0';
					*menus[nMenus].entries[menus[nMenus].nEntries-1].arg1 = '\0';
				}
				else if (!strncmp (p, "oper:", 5))
				{
					for (p+=5; isspace(*p); p++);
					strcpy (menus[nMenus].entries[menus[nMenus].nEntries-1].oper, p);
				}
				else if (!strncmp (p, "arg1:", 5))
				{
					for (p+=5; isspace(*p); p++);
					strcpy (menus[nMenus].entries[menus[nMenus].nEntries-1].arg1, p);
				}
				else
					fprintf (stderr, "unsupported _entry_ key: \"%s\"\n", p);
			}
			else
				fprintf (stderr, "error\n");
		}
	}

	if (verbose)
		dump_menu (nMenus);

	fclose (fp);

	return (0);
}

void usage (char *argv0)
{
	printf ("usage: %s [-v] <yml_name>[.yml]\n", argv0);
	printf ("  options:\n");
	printf ("    -v  : verbose output\n");

	exit (0);
}

int main (int argc, char *argv[])
{
	char yml_name[64] = "menu.yml";
	bool verbose = false;

	while (--argc)
	{
		switch (argv[argc][0])
		{
			case '-' :
			case '/' :
				switch (tolower (argv[argc][1]))
				{
					case 'v' :
						verbose = true;
						break;
					default :
						usage (argv[0]);
						break;
				}
				break;
			default :
				strcpy (yml_name, argv[argc]);
				break;
		}
	}
	if (!strrchr (yml_name, '.'))
		strcat (yml_name, ".yml");

	if (parse_menu_yml (yml_name, verbose) < 0)
		fprintf (stderr, "error parsing file \"%s\"\n", yml_name);
}
