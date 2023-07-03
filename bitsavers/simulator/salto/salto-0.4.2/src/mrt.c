/*****************************************************************************
 * SALTO - Xerox Alto I/II Simulator.
 *
 * Copyright (C) 2007 by Juergen Buchmueller <pullmoll@t-online.de>
 * Partially based on info found in Eric Smith's Alto simulator: Altogether
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * Memory refresh task
 *
 * $Id: mrt.c,v 1.1.1.1 2008/07/22 19:02:07 pm Exp $
 *****************************************************************************/
#include <stdlib.h>

#include "alto.h"
#include "cpu.h"
#include "mrt.h"

/** @brief block the display word task */
static void f1_block_0(void)
{
	/* clear the wakeup for the memory refresh task */
	CPU_CLR_TASK_WAKEUP(cpu.task);
	LOG((0,2,"	BLOCK %s\n", task_name[cpu.task]));
}

/** @brief called by the CPU when MRT becomes active */
static void activate(void)
{
	/* TODO: what do we do here? */
	CPU_CLR_TASK_WAKEUP(cpu.task);
}

/**
 * @brief memory refresh task slots initialization
 */
int init_mrt(int task)
{
	SET_FN(f1, block,		f1_block_0,	NULL);

	/* auto block */
	CPU_SET_ACTIVATE_CB(task, activate);
	return 0;
}
