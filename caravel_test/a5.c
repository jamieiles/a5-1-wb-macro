/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation, 2021 Jamie Iles
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

#include "defs.h"
#include "stub.c"

#define A5_ID_REG	(0x30000000 + 0x00)
#define A5_STATUS_REG	(0x30000000 + 0x04)
#define A5_CONTROL_REG	(0x30000000 + 0x08)
#define A5_DATA_REG	(0x30000000 + 0x0c)
#define A5_KEY_LO_REG	(0x30000000 + 0x10)
#define A5_KEY_HI_REG	(0x30000000 + 0x14)
#define A5_FRAME_REG	(0x30000000 + 0x18)

static uint32_t readl(unsigned long addr)
{
	return *(volatile uint32_t *)addr;
}

static void writel(unsigned long addr, uint32_t v)
{
	*(volatile uint32_t *)addr = v;
}

static void fail(void)
{
	reg_mprj_datal = 0x2;
	reg_mprj_datal = 0x3;

	for (;;)
		continue;
}

static void test_id_reg(void)
{
	if (readl(A5_ID_REG) != 0x41354135)
		fail();
}

static void test_reference_keystream(void)
{
	writel(A5_KEY_LO_REG, 0x67452312);
	writel(A5_KEY_HI_REG, 0xefcdab89);
	writel(A5_FRAME_REG, 0x00000134);
	writel(A5_CONTROL_REG, 0x00000001);
	while (!(readl(A5_STATUS_REG) & 0x1))
		continue;
	if (readl(A5_DATA_REG) != 0x1a5572ca)
		fail();
}

static void configure_io(void)
{
        reg_mprj_io_1  = GPIO_MODE_MGMT_STD_OUTPUT;
        reg_mprj_io_0  = GPIO_MODE_MGMT_STD_OUTPUT;

        /* Apply configuration */
        reg_mprj_xfer = 1;
        while (reg_mprj_xfer == 1)
		continue;
}

void main()
{
	configure_io();

	// Flag start of the test
	reg_mprj_datal = 0x00000000;

	// Activate design
	reg_la1_ena  = 0x00000000;
    reg_la1_data = 1 << 2; // our ID is 2

	// Reset A5 macro
	reg_la0_ena  = 0x00000000;
	reg_la0_data = 0x00000001;
	reg_la0_data = 0x00000000;
	reg_la0_data = 0x00000001;

	test_id_reg();
	test_reference_keystream();

	reg_mprj_datal = 0x00000001;
}

