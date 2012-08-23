/*
*********************************************************************************************************
*                                                uC/OS-II
*                                          The Real-Time Kernel
*                                          BINARY SEMAPHORE MANAGEMENT
*
*                              (c) Copyright 1992-2007, Micrium, Weston, FL
*                                           All Rights Reserved
*                              (c) Copyright 2010 Chris Johns (chris@contemporary.net.au)
*
* File    : OS_SEM.C
* By      : Jean J. Labrosse
* Version : V2.86
*
* LICENSING TERMS:
* ---------------
*   uC/OS-II is provided in source form for FREE evaluation, for educational use or for peaceful research.  
* If you plan on using  uC/OS-II  in a commercial product you need to contact Micriµm to properly license 
* its use in your product. We provide ALL the source code for your convenience and to help you experience 
* uC/OS-II.   The fact that the  source is provided does  NOT  mean that you can use it without  paying a 
* licensing fee.
*
* This code is provide as an example by Chris Johns of a more standard mutex without priority fiddling
* and cannot be include in a commercial release or any derviative offering of uC/OS-II by Jean J. Labrosse
* unless authorised by Chris Johns (chris@contemporary.net.au). All commercial licencing requirements of
* uC/OS-II for orginal uC/OS-II code are valid and this code does not offer any exception to that licence.
* This code is free and comes with no warrenty.
*********************************************************************************************************
*/

#ifndef  OS_MASTER_FILE
#include <ucos_ii.h>
#endif

#if OS_SEM_EN > 0
/*
*********************************************************************************************************
*                                            LOCAL CONSTANTS
*********************************************************************************************************
*/

#define  OS_BSEM_KEEP_LOWER_8   ((INT16U)0x00FFu)
#define  OS_BSEM_KEEP_UPPER_8   ((INT16U)0xFF00u)

/*
*********************************************************************************************************
*                                           ACCEPT BINARY SEMAPHORE
*
* Description: This function checks the semaphore to see if a resource is available or, if an event
*              occurred.  Unlike OSSemPend(), OSSemAccept() does not suspend the calling task if the
*              resource is not available or the event did not occur.
*
* Arguments  : pevent     is a pointer to the event control block
*
* Returns    : >  0       if the resource is available or the event did not occur the semaphore is
*                         decremented to obtain the resource.
*              == 0       if the resource is not available or the event did not occur or,
*                         if 'pevent' is a NULL pointer or,
*                         if you didn't pass a pointer to a semaphore
*********************************************************************************************************
*/

#if OS_SEM_ACCEPT_EN > 0
INT16U  OSBinarySemAccept (OS_EVENT *pevent)
{
    INT8U      cnt;
    INT8U      prio;
#if OS_CRITICAL_METHOD == 3                           /* Allocate storage for CPU status register      */
    OS_CPU_SR  cpu_sr = 0;
#endif

#if OS_ARG_CHK_EN > 0
    if (pevent == (OS_EVENT *)0) {                    /* Validate 'pevent'                             */
        return (0);
    }
#endif
    if (pevent->OSEventType != OS_EVENT_TYPE_SEM) {   /* Validate event block type                     */
        return (0);
    }
    OS_ENTER_CRITICAL();
    prio = pevent->OSEventCnt & OS_BSEM_KEEP_LOWER_8;
    cnt = (pevent->OSEventCnt & OS_BSEM_KEEP_UPPER_8) >> 8;
    if ((cnt > 0) && (prio != OSTCBCur->OSTCBPrio)) {
        cnt = 0;
    }
    else {
        ++cnt;
        pevent->OSEventCnt = OSTCBCur->OSTCBPrio | (cnt << 8);
    }
    OS_EXIT_CRITICAL();
    return (cnt);                                     /* Return semaphore count                        */
}
#endif

/*$PAGE*/
/*
*********************************************************************************************************
*                                           CREATE A BINARY SEMAPHORE
*
* Description: This function creates a binary semaphore.
*
* Returns    : != (void *)0  is a pointer to the event control block (OS_EVENT) associated with the
*                            created semaphore
*              == (void *)0  if no event control blocks were available
*********************************************************************************************************
*/

OS_EVENT  *OSBinarySemCreate (void)
{
    OS_EVENT  *pevent;
#if OS_CRITICAL_METHOD == 3                                /* Allocate storage for CPU status register */
    OS_CPU_SR  cpu_sr = 0;
#endif

    if (OSIntNesting > 0) {                                /* See if called from ISR ...               */
        return ((OS_EVENT *)0);                            /* ... can't CREATE from an ISR             */
    }
    OS_ENTER_CRITICAL();
    pevent = OSEventFreeList;                              /* Get next free event control block        */
    if (OSEventFreeList != (OS_EVENT *)0) {                /* See if pool of free ECB pool was empty   */
        OSEventFreeList = (OS_EVENT *)OSEventFreeList->OSEventPtr;
    }
    OS_EXIT_CRITICAL();
    if (pevent != (OS_EVENT *)0) {                         /* Get an event control block               */
        pevent->OSEventType    = OS_EVENT_TYPE_SEM;
        pevent->OSEventCnt     = 0;                        /* Set nesting count                        */
        pevent->OSEventPtr     = (void *)0;                /* Unlink from ECB free list                */
#if OS_EVENT_NAME_SIZE > 1
        pevent->OSEventName[0] = '?';                      /* Unknown name                             */
        pevent->OSEventName[1] = OS_ASCII_NUL;
#endif
        OS_EventWaitListInit(pevent);                      /* Initialize to 'nobody waiting' on sem.   */
    }
    return (pevent);
}

/*$PAGE*/
/*
*********************************************************************************************************
*                                         DELETE A BINARY SEMAPHORE
*
* Description: This function deletes a binary semaphore and readies all tasks pending on the semaphore.
*
* Arguments  : pevent        is a pointer to the event control block associated with the desired
*                            semaphore.
*
*              opt           determines delete options as follows:
*                            opt == OS_DEL_NO_PEND   Delete semaphore ONLY if no task pending
*                            opt == OS_DEL_ALWAYS    Deletes the semaphore even if tasks are waiting.
*                                                    In this case, all the tasks pending will be readied.
*
*              perr          is a pointer to an error code that can contain one of the following values:
*                            OS_ERR_NONE             The call was successful and the semaphore was deleted
*                            OS_ERR_DEL_ISR          If you attempted to delete the semashore from an ISR
*                            OS_ERR_INVALID_OPT      An invalid option was specified
*                            OS_ERR_TASK_WAITING     One or more tasks were waiting on the semaphore
*                            OS_ERR_EVENT_TYPE       If you didn't pass a pointer to a semaphore
*                            OS_ERR_PEVENT_NULL      If 'pevent' is a NULL pointer.
*
* Returns    : pevent        upon error
*              (OS_EVENT *)0 if the semaphore was successfully deleted.
*
* Note(s)    : 1) This function must be used with care.  Tasks that would normally expect the presence of
*                 the semaphore MUST check the return code of OSMutexPend().
*              3) This call can potentially disable interrupts for a long time.  The interrupt disable
*                 time is directly proportional to the number of tasks waiting on the semaphore.
*              4) Because ALL tasks pending on the semaphore will be readied, you MUST be careful in
*                 applications where the semaphore is used for mutual exclusion because the resource(s)
*                 will no longer be guarded by the semaphore.
*********************************************************************************************************
*/

OS_EVENT  *OSBinarySemDel (OS_EVENT *pevent, INT8U opt, INT8U *perr)
{
    BOOLEAN    tasks_waiting;
    OS_EVENT  *pevent_return;
#if OS_CRITICAL_METHOD == 3                                /* Allocate storage for CPU status register */
    OS_CPU_SR  cpu_sr = 0;
#endif

#if OS_ARG_CHK_EN > 0
    if (perr == (INT8U *)0) {                              /* Validate 'perr'                          */
        return (pevent);
    }
    if (pevent == (OS_EVENT *)0) {                         /* Validate 'pevent'                        */
        *perr = OS_ERR_PEVENT_NULL;
        return (pevent);
    }
#endif
    if (pevent->OSEventType != OS_EVENT_TYPE_SEM) {        /* Validate event block type                */
        *perr = OS_ERR_EVENT_TYPE;
        return (pevent);
    }
    if (OSIntNesting > 0) {                                /* See if called from ISR ...               */
        *perr = OS_ERR_DEL_ISR;                             /* ... can't DELETE from an ISR             */
        return (pevent);
    }
    OS_ENTER_CRITICAL();
    if (pevent->OSEventGrp != 0) {                         /* See if any tasks waiting on semaphore    */
        tasks_waiting = OS_TRUE;                           /* Yes                                      */
    } else {
        tasks_waiting = OS_FALSE;                          /* No                                       */
    }
    switch (opt) {
        case OS_DEL_NO_PEND:                               /* Delete semaphore only if no task waiting */
             if (tasks_waiting == OS_FALSE) {
#if OS_EVENT_NAME_SIZE > 1
                 pevent->OSEventName[0] = '?';             /* Unknown name                             */
                 pevent->OSEventName[1] = OS_ASCII_NUL;
#endif
                 pevent->OSEventType    = OS_EVENT_TYPE_UNUSED;
                 pevent->OSEventPtr     = OSEventFreeList; /* Return Event Control Block to free list  */
                 pevent->OSEventCnt     = 0;
                 OSEventFreeList        = pevent;          /* Get next free event control block        */
                 OS_EXIT_CRITICAL();
                 *perr                  = OS_ERR_NONE;
                 pevent_return          = (OS_EVENT *)0;   /* Semaphore has been deleted               */
             } else {
                 OS_EXIT_CRITICAL();
                 *perr                  = OS_ERR_TASK_WAITING;
                 pevent_return          = pevent;
             }
             break;

        case OS_DEL_ALWAYS:                                /* Always delete the semaphore              */
             while (pevent->OSEventGrp != 0) {             /* Ready ALL tasks waiting for semaphore    */
                 (void)OS_EventTaskRdy(pevent, (void *)0, OS_STAT_SEM, OS_STAT_PEND_OK);
             }
#if OS_EVENT_NAME_SIZE > 1
             pevent->OSEventName[0] = '?';                 /* Unknown name                             */
             pevent->OSEventName[1] = OS_ASCII_NUL;
#endif
             pevent->OSEventType    = OS_EVENT_TYPE_UNUSED;
             pevent->OSEventPtr     = OSEventFreeList;     /* Return Event Control Block to free list  */
             pevent->OSEventCnt     = 0;
             OSEventFreeList        = pevent;              /* Get next free event control block        */
             OS_EXIT_CRITICAL();
             if (tasks_waiting == OS_TRUE) {               /* Reschedule only if task(s) were waiting  */
                 OS_Sched();                               /* Find highest priority task ready to run  */
             }
             *perr                  = OS_ERR_NONE;
             pevent_return          = (OS_EVENT *)0;       /* Semaphore has been deleted               */
             break;

        default:
             OS_EXIT_CRITICAL();
             *perr                  = OS_ERR_INVALID_OPT;
             pevent_return          = pevent;
             break;
    }
    return (pevent_return);
}

/*$PAGE*/
/*
*********************************************************************************************************
*                                           PEND ON BINARY SEMAPHORE
*
* Description: This function waits for a binary semaphore.
*
* Arguments  : pevent        is a pointer to the event control block associated with the desired
*                            semaphore.
*
*              timeout       is an optional timeout period (in clock ticks).  If non-zero, your task will
*                            wait for the resource up to the amount of time specified by this argument.
*                            If you specify 0, however, your task will wait forever at the specified
*                            semaphore or, until the resource becomes available (or the event occurs).
*
*              perr          is a pointer to where an error message will be deposited.  Possible error
*                            messages are:
*
*                            OS_ERR_NONE         The call was successful and your task owns the resource
*                                                or, the event you are waiting for occurred.
*                            OS_ERR_TIMEOUT      The semaphore was not received within the specified
*                                                'timeout'.
*                            OS_ERR_PEND_ABORT   The wait on the semaphore was aborted.
*                            OS_ERR_EVENT_TYPE   If you didn't pass a pointer to a semaphore.
*                            OS_ERR_PEND_ISR     If you called this function from an ISR and the result
*                                                would lead to a suspension.
*                            OS_ERR_PEVENT_NULL  If 'pevent' is a NULL pointer.
*                            OS_ERR_PEND_LOCKED  If you called this function when the scheduler is locked
*
* Returns    : none
*********************************************************************************************************
*/
/*$PAGE*/
void  OSBinarySemPend (OS_EVENT *pevent, INT16U timeout, INT8U *perr)
{
    volatile INT8U cnt;
    volatile INT8U prio;
#if OS_CRITICAL_METHOD == 3                           /* Allocate storage for CPU status register      */
    OS_CPU_SR  cpu_sr = 0;
#endif

#if OS_ARG_CHK_EN > 0
    if (perr == (INT8U *)0) {                         /* Validate 'perr'                               */
        return;
    }
    if (pevent == (OS_EVENT *)0) {                    /* Validate 'pevent'                             */
        *perr = OS_ERR_PEVENT_NULL;
        return;
    }
#endif
    if (pevent->OSEventType != OS_EVENT_TYPE_SEM) {   /* Validate event block type                     */
        *perr = OS_ERR_EVENT_TYPE;
        return;
    }
    if (OSIntNesting > 0) {                           /* See if called from ISR ...                    */
        *perr = OS_ERR_PEND_ISR;                      /* ... can't PEND from an ISR                    */
        return;
    }
    if (OSLockNesting > 0) {                          /* See if called with scheduler locked ...       */
        *perr = OS_ERR_PEND_LOCKED;                   /* ... can't PEND when locked                    */
        return;
    }
    *perr = OS_ERR_NONE;
    OS_ENTER_CRITICAL();
    prio = pevent->OSEventCnt & OS_BSEM_KEEP_LOWER_8;
    cnt = (pevent->OSEventCnt & OS_BSEM_KEEP_UPPER_8) >> 8;
    while ((prio != OSTCBCur->OSTCBPrio) && (cnt != 0)) {
        OSTCBCur->OSTCBStat     |= OS_STAT_SEM; /* Resource not available, pend on semaphore   */
        OSTCBCur->OSTCBStatPend  = OS_STAT_PEND_OK;
        OSTCBCur->OSTCBDly       = timeout;     /* Store pend timeout in TCB                   */
        OS_EventTaskWait(pevent);               /* Suspend task until event or timeout occurs  */
        OS_EXIT_CRITICAL();
        OS_Sched();                             /* Find next highest priority task ready       */
        OS_ENTER_CRITICAL();
        switch (OSTCBCur->OSTCBStatPend) {      /* See if we timed-out or aborted              */
            case OS_STAT_PEND_OK:
                *perr = OS_ERR_NONE;
                break;

            case OS_STAT_PEND_ABORT:
                *perr = OS_ERR_PEND_ABORT;      /* Indicate that we aborted                    */
                break;

            case OS_STAT_PEND_TO:
            default:        
                OS_EventTaskRemove(OSTCBCur, pevent);
                *perr = OS_ERR_TIMEOUT;         /* Indicate that we didn't get event within TO */
                break;
        }
        OSTCBCur->OSTCBStat          =  OS_STAT_RDY;     /* Set   task  status to ready        */
        OSTCBCur->OSTCBStatPend      =  OS_STAT_PEND_OK; /* Clear pend  status                 */
        OSTCBCur->OSTCBEventPtr      = (OS_EVENT  *)0;   /* Clear event pointers               */
#if (OS_EVENT_MULTI_EN > 0)
        OSTCBCur->OSTCBEventMultiPtr = (OS_EVENT **)0;
#endif
        if (*perr != OS_ERR_NONE) {
            OS_EXIT_CRITICAL();
            return;
        }
        prio = pevent->OSEventCnt & OS_BSEM_KEEP_LOWER_8;
        cnt = (pevent->OSEventCnt & OS_BSEM_KEEP_UPPER_8) >> 8;
    }
    ++cnt;
    pevent->OSEventCnt = OSTCBCur->OSTCBPrio | (cnt << 8);
    OS_EXIT_CRITICAL();
}

/*$PAGE*/
/*
*********************************************************************************************************
*                                         POST TO A BINARY SEMAPHORE
*
* Description: This function signals a binary semaphore
*
* Arguments  : pevent        is a pointer to the event control block associated with the desired
*                            binary semaphore.
*
* Returns    : OS_ERR_NONE         The call was successful and the semaphore was signaled.
*              OS_ERR_SEM_OVF      If the semaphore count exceeded its limit.  In other words, you have
*                                  signalled the semaphore more often than you waited on it with either
*                                  OSSemAccept() or OSSemPend().
*              OS_ERR_EVENT_TYPE   If you didn't pass a pointer to a semaphore
*              OS_ERR_PEVENT_NULL  If 'pevent' is a NULL pointer.
*********************************************************************************************************
*/

INT8U  OSBinarySemPost (OS_EVENT *pevent)
{
    INT8U      cnt;
    INT8U      prio;
#if OS_CRITICAL_METHOD == 3                           /* Allocate storage for CPU status register      */
    OS_CPU_SR  cpu_sr = 0;
#endif

#if OS_ARG_CHK_EN > 0
    if (pevent == (OS_EVENT *)0) {                    /* Validate 'pevent'                             */
        return (OS_ERR_PEVENT_NULL);
    }
#endif
    if (pevent->OSEventType != OS_EVENT_TYPE_SEM) {   /* Validate event block type                     */
        return (OS_ERR_EVENT_TYPE);
    }
    OS_ENTER_CRITICAL();
    if (pevent->OSEventCnt == 0) {
        OS_EXIT_CRITICAL();                           /* Semaphore value has reached its maximum       */
        return (OS_ERR_SEM_OVF);
    }
    prio = pevent->OSEventCnt & OS_BSEM_KEEP_LOWER_8;
    cnt = (pevent->OSEventCnt & OS_BSEM_KEEP_UPPER_8) >> 8;
    if (prio != OSTCBCur->OSTCBPrio) {
        OS_EXIT_CRITICAL();
        return (OS_ERR_NOT_MUTEX_OWNER);
    }
    if (cnt) {
        --cnt;
    }
    if (cnt == 0) {
        pevent->OSEventCnt = 0;
        if (pevent->OSEventGrp != 0) {                /* See if any task waiting for semaphore         */
                                                      /* Ready HPT waiting on event                    */
          (void)OS_EventTaskRdy(pevent, (void *)0, OS_STAT_SEM, OS_STAT_PEND_OK);
          OS_EXIT_CRITICAL();
          OS_Sched();                                /* Find HPT ready to run                         */
          return (OS_ERR_NONE);
        }
    } else {
        pevent->OSEventCnt = OSTCBCur->OSTCBPrio | (cnt << 8);
    }
    OS_EXIT_CRITICAL();
    return (OS_ERR_NONE);
}

/*$PAGE*/
/*
*********************************************************************************************************
*                                         OWN A BINARY SEMAPHORE
*
* Description: This function check is the current thread owns a binary semaphore
*
* Arguments  : pevent        is a pointer to the event control block associated with the desired
*                            binary semaphore.
*
* Returns    : 1             It owns the binary semaphore
*              0             It does not own the binary semaphore
*********************************************************************************************************
*/

BOOLEAN  OSBinarySemOwn (OS_EVENT *pevent)
{
    INT8U      prio;
    BOOLEAN    own;
#if OS_CRITICAL_METHOD == 3                           /* Allocate storage for CPU status register      */
    OS_CPU_SR  cpu_sr = 0;
#endif

#if OS_ARG_CHK_EN > 0
    if (pevent == (OS_EVENT *)0) {                    /* Validate 'pevent'                             */
        return (OS_ERR_PEVENT_NULL);
    }
#endif
    if (pevent->OSEventType != OS_EVENT_TYPE_SEM) {   /* Validate event block type                     */
        return (OS_ERR_EVENT_TYPE);
    }
    OS_ENTER_CRITICAL();
    prio = pevent->OSEventCnt & OS_BSEM_KEEP_LOWER_8;
    own = prio == OSTCBCur->OSTCBPrio ? 1 : 0;
    OS_EXIT_CRITICAL();
    return own;
}

#endif                                                /* OS_SEM_EN                                     */
