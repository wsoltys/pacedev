/*
 * Copyright (C) 2010 Virtual Logic Pty Ltd
 * All rights reserved.
 *
 * Developed by Chris Johns.
 */

#ifndef OXU210_INTR_H
#define OXU210_INTR_H

/*
 * Type of handler.
 */
typedef void (*oxu210_intr_handler)(void* self);

/*
 * Sources of interrupts.
 */
typedef enum
{
  oxu210_intr_shc = 0,
  oxu210_intr_otg = 1
} oxu210_intr_source;

/*
 * No locking involved.
 */
int  oxu210_intr_attach (oxu210_intr_source  source,
                         oxu210_intr_handler handler,
                         void*               self);
void oxu210_intr_detach (oxu210_intr_source source);

#endif
