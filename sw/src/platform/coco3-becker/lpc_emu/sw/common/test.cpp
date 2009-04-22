#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <conio.h>

static char *ops[] =
{
  "NULL", "CONFIG_FILE", "CONFIG_SCRIPT", "GOTO_MENU"
};
#define NUM_OPS (sizeof(ops)/sizeof(char *))

int get_oper (char *oper)
{
  for (int i=0; i<NUM_OPS; i++)
    if (!strcmp (oper, ops[i]))
      return (i);
  return (-1);
}

typedef struct _MENTRY
{
	char	name[64];
  char szOper[64];  // debug
	int   oper;
	char	arg1[64];

  // quick-links
  int   to_menu;

} MENTRY, *PMENTRY;

typedef struct _MENU
{
	char 		title[64];
	char 		tag[64];
	int			nEntries;
	MENTRY	entries[8];

} MENU, *PMENU;

static MENU menus[16];
static int nMenus = -1;

int get_menu (char *tag)
{
  for (int i=0; i<nMenus; i++)
    if (!strcmp (tag, menus[i].tag))
      return (i);
  return (-1);
}

typedef enum
{
	eKeyMenu, 
	eKeyTitle, eKeyTag, eKeyEntries

} eKEY;

int dump_menu (PMENU menus, int nMenus)
{
	printf ("- menu: (%d)\n"
					"  title: \"%s\"\n"
					"  tag: %s\n"
					"  entries: (%d)\n", 
					nMenus+1, menus[nMenus].title, menus[nMenus].tag, menus[nMenus].nEntries);
	for (int i=0; i<menus[nMenus].nEntries; i++)
  {
		printf ("  - name: \"%s\"\n"
						"    oper: %s\n",
						menus[nMenus].entries[i].name, 
            (menus[nMenus].entries[i].oper == -1 ? "(UNKNOWN)" : ops[menus[nMenus].entries[i].oper]));
    if (*menus[nMenus].entries[i].arg1)
      printf ("    arg1: %s (%d)\n", 
              menus[nMenus].entries[i].arg1,
              menus[nMenus].entries[i].to_menu+1);
  }
  
}

void dump_all_menus (PMENU menu, int n)
{
  for (int m=0; m<n; m++)
  {
    dump_menu (menu, m);
    printf ("\n");
  }
}

int parse_menu_yml (char *yml_name, bool verbose=false)
{
	FILE *fp = fopen (yml_name, "rt");
	if (!fp)
		return (-1);

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
					dump_menu (menus, nMenus);
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
					menus[nMenus].entries[menus[nMenus].nEntries-1].oper = -1;
					*menus[nMenus].entries[menus[nMenus].nEntries-1].arg1 = '\0';
				}
				else if (!strncmp (p, "oper:", 5))
				{
					for (p+=5; isspace(*p); p++);
          char *q; for (q=p; *q && !isspace(*q); q++); *q = '\0';
					strcpy (menus[nMenus].entries[menus[nMenus].nEntries-1].szOper, p);
          menus[nMenus].entries[menus[nMenus].nEntries-1].oper = get_oper (p);
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
		dump_menu (menus, nMenus);
  nMenus++;

	fclose (fp);

	return (0);
}

int check_all_menus (PMENU menu, int n)
{
  for (int m=0; m<n; m++)
  {
    for (int e=0; e<menus[m].nEntries; e++)
    {
      menus[m].entries[e].to_menu = -1;
      if (menus[m].entries[e].oper == -1)
      {
        fprintf (stderr, "%s() : menu[%d].entry[%d].oper(%s) not found\n", 
                 __FUNCTION__, m, e, menus[m].entries[e].szOper);
        return (-1);
      }
      if (menus[m].entries[e].oper == 3)
        if ((menus[m].entries[e].to_menu = get_menu (menus[m].entries[e].arg1)) < 0)
        {
          fprintf (stderr, "%s() : menu[%d].entry[%d].GOTO_MENU(%s) not found\n", 
                    __FUNCTION__, m, e, menus[m].entries[e].arg1);
          return (-1);
        }
    }
  }
  return (0);
}

void display_menu (PMENU menu, int i)
{
  PMENU m = &menu[i];

  for (i=0; i<m->nEntries; i++)
  {
    printf ("%s\n", m->entries[i].name);
  }
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
  {
		fprintf (stderr, "error parsing file \"%s\"\n", yml_name);
    exit (0);
  }

  if (check_all_menus (menus, nMenus) < 0)
  {
		fprintf (stderr, "error validating menus\n");
    exit (0);
  }

  int cm = 0;
  while (1)
  {
    int c;

    //dump_all_menus (menus, nMenus);
    display_menu (menus, cm);
    printf ("\n");

    while (1)
    {
      c = getch();
      if (tolower(c) == 'x')
        break;

      if (c < '1' || c > '9')
        continue;

      int i = c - '1';
      if (i >= menus[cm].nEntries)
        continue;

      if (menus[cm].entries[i].oper != 3)
        continue;

      // change menu
      cm = menus[cm].entries[i].to_menu;
      break;
    }

    if (tolower(c) == 'x')
      break;
  }
}
