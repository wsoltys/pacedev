/*  This software is distributed under GPL license - see gpl.txt
    This is a part of WheelBusMouse and ps2m packages,
    you can obtain latest versions at Aminet:

ftp://ftp.wustl.edu/pub/aminet/util/mouse/WheelBusMouse.lha
ftp://ftp.wustl.edu/pub/aminet/util/mouse/WheelBusMouse.readme

ftp://ftp.wustl.edu/pub/aminet/hard/hack/ps2m.lha
ftp://ftp.wustl.edu/pub/aminet/hard/hack/ps2m.readme

Don't forget to disable startup code! */

#include <exec/memory.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/input_protos.h>
#include <clib/graphics_protos.h>
#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/input_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <dos/dostags.h>

#include <devices/input.h>
#include <devices/inputevent.h>
#include "newmouse.h"

struct Library *DOSBase, *SysBase, *GfxBase, *InputBase;
struct IOStdReq *req;
struct InputEvent FakeEvent;

ULONG code, tPRA, tPOTGOR;

#define COORDX *((STRPTR)0xdff00d)
#define COORDY *((STRPTR)0xdff00c)
#define POTGOR *((STRPTR)0xdff016)
#define PRA *((STRPTR)0xbfe001)
#define TEMPLATE "REVERSE/S,REVERSEX=RX/S,REVERSEY=RY/S,LMB/S,MMB/S,RMB/S,JOYFIRE0=JF0/S,JOYFIRE1=JF1/S,JOYFIRE2=JF2/S,CTRL/S,LSHIFT=LSH/S,RSHIFT=RSH/S,LALT/S,RALT/S,LCOMMAND=LCMD/S,RCOMMAND=RCMD/S,LFOURTHBUTTON=LFB/S,RFOURTHBUTTON=RFB/S,BUTTONSCROLL=BS/S,PRIORITY/N,QUIET/S"

struct {
	ULONG reverse;
	ULONG rx;
	ULONG ry;
	ULONG lmb;
	ULONG mmb;
	ULONG rmb;
	ULONG jf0;
	ULONG jf1;
	ULONG jf2;
	ULONG ctrl;
	ULONG lsh;
	ULONG rsh;
	ULONG lalt;
	ULONG ralt;
	ULONG lcmd;
	ULONG rcmd;
	ULONG lfb;
	ULONG rfb;
	ULONG bs;
	ULONG *pri;
	ULONG quiet;
} arg = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };

void event(LONG);
void events(LONG);
void event2(ULONG);
void process(void);

__saveds main()
{
	SysBase = *((struct Library **)4L);
	if(DOSBase = OpenLibrary("dos.library",0))
	{
		if(GfxBase = OpenLibrary("graphics.library",36))
		{
			struct RDArgs *rda;
			if(rda = ReadArgs(TEMPLATE,(LONG *)&arg,NULL))
			{
				if(!arg.quiet)
				{
					Printf("%s  © Russian Digital Computing\n",6+"$VER: WheelBusMouse 1.5 "__AMIGADATE__);
				}
				if(FindTask("WheelBusMouse"))
				{
					Printf("%s already installed!\n","WheelBusMouse");
				}
				else
				{
					if(CreateNewProcTags(NP_Entry,process,NP_Name,"WheelBusMouse",NP_Priority,arg.pri?*arg.pri:0,NULL))
					{
						((struct CommandLineInterface *)((((struct Process *)FindTask(NULL))->pr_CLI)<<2))->cli_Module = NULL;
						return(0);
					}
					if(!arg.quiet)
					{
						Printf("Can't create daughter process\n");
					}
				}
				CloseLibrary(GfxBase);
			}
			else
			{
				Printf("Illegal option(s)\n");
			}
		}
		else
		{
			Write(Output(),"OS 2.0+ required\n",17);
		}
		CloseLibrary(DOSBase);
	}
	return(20);
}

void __saveds process(void)
{
	struct MsgPort *replyport;
	if(replyport = CreateMsgPort())
	{
		if(req = CreateIORequest(replyport,sizeof(struct IOStdReq)))
		{
			if(!OpenDevice("input.device",NULL,(struct IORequest *)req,NULL))
			{
				BYTE LastByteX = COORDX;
				BYTE LastByteY = COORDY;
				BYTE LastJA = 0;
				BYTE LastJP = 0;
				ULONG qualc = arg.ctrl | arg.lalt | arg.ralt | arg.lsh | arg.rsh | arg.lcmd | arg.rcmd;
				ULONG qualp = arg.mmb | arg.rmb | arg.jf2 | arg.jf1;
				ULONG quala = arg.lmb | arg.jf0;
				ULONG qual = quala | qualp | qualc;
				InputBase = (struct Library *)req->io_Device;
				while(!CheckSignal(0xf000))
				{
					BYTE CurrByteX = COORDX;
					BYTE CurrByteY = COORDY;
					LONG diffx = (BYTE)(CurrByteX - LastByteX);
					LONG diffy = (BYTE)(CurrByteY - LastByteY);
					if(arg.lfb|arg.bs)
					{
						tPRA = PRA;
						if((tPRA&128)!=(LastJA&128))
						{
							if(!(tPRA&128))
							{
								if(arg.lfb)
								{
									event2(NM_BUTTON_FOURTH);
								}
								if(arg.bs)
								{
									event2(NM_WHEEL_LEFT);
								}
							}
						}
						LastJA = tPRA;
					}
					if(arg.rfb|arg.bs)
					{
						tPOTGOR = POTGOR;
						if((tPOTGOR&128)!=(LastJP&64))
						{
							if(!(tPOTGOR&64))
							{
								if(arg.rfb)
								{
									event2(NM_BUTTON_FOURTH);
								}
								if(arg.bs)
								{
									event2(NM_WHEEL_RIGHT);
								}
							}
						}
						LastJP = tPOTGOR;
					}
					if(diffx || diffy)
					{
						if(arg.reverse)
						{
							diffx = -diffx;
							diffy = -diffy;
						}
						if(qual)
						{
							ULONG qua = 0;
							if(qualc)
							{
								UWORD t = PeekQualifier();
								if((arg.ctrl&&(t&IEQUALIFIER_CONTROL))||
									(arg.lsh&&(t&IEQUALIFIER_LSHIFT))||
									(arg.rsh&&(t&IEQUALIFIER_RSHIFT))||
									(arg.lcmd&&(t&IEQUALIFIER_LCOMMAND))||
									(arg.rcmd&&(t&IEQUALIFIER_RCOMMAND))||
									(arg.lalt&&(t&IEQUALIFIER_LALT))||
									(arg.ralt&&(t&IEQUALIFIER_RALT)))
								{
									qua = 1;
								}
							}
							if(quala)
							{
								if(!arg.lfb)
								{
									tPRA = PRA;
								}
								if((arg.lmb&&(!(tPRA&64)))||
									(arg.jf0&&(!(tPRA&128))))
								{
									qua = 1;
								}
							}
							if(qualp)
							{
								if(!arg.rfb)
								{
									tPOTGOR = POTGOR;
								}
								if((arg.mmb&&(!(tPOTGOR&1)))||
									(arg.rmb&&(!(tPOTGOR&4)))||
									(arg.jf2&&(!(tPOTGOR&16)))||
									(arg.jf1&&(!(tPOTGOR&64))))
								{
									qua = 1;
								}
							}
							if(qua)
							{
								LONG temp = diffx;
								diffx = diffy;
								diffy = temp;
							}
						}
						if(diffx)
						{
							code = NM_WHEEL_LEFT;
							if(arg.rx)
							{
								diffx = -diffx;
							}
							if(diffx<0)
							{
								code++;
								diffx = -diffx;
							}
							events(diffx);
						}
						if(diffy)
						{
							code = NM_WHEEL_UP;
							if(arg.ry)
							{
								diffy = -diffy;
							}
							if(diffy<0)
							{
								code++;
								diffy = -diffy;
							}
							events(diffy);
						}
						LastByteX=CurrByteX;
						LastByteY=CurrByteY;
					}
					WaitTOF();
				}
				CloseDevice((struct IORequest *)req);
			}
			DeleteIORequest(req);
		}
		DeleteMsgPort(replyport);
	}
	CloseLibrary(GfxBase);
	CloseLibrary(DOSBase);
}

void event2(ULONG ecode)
{
	code = ecode;
	event(IECLASS_RAWKEY);
	event(IECLASS_NEWMOUSE);
}

void events(LONG count)
{
	while(count--)
	{
		event(IECLASS_RAWKEY);
		event(IECLASS_NEWMOUSE);
	}
}

void event(LONG class)
{
	FakeEvent.ie_NextEvent = NULL;
	FakeEvent.ie_Class = class;
	FakeEvent.ie_Code = code;
	FakeEvent.ie_Qualifier = NULL;
	req->io_Data = (APTR)&FakeEvent;
	req->io_Length = sizeof(struct InputEvent);
	req->io_Command = IND_WRITEEVENT;
	DoIO((struct IORequest *)req);
}
