/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

// c:\Xilinx\Vivado\2015.2\bin/updatemem --meminfo robot01.mmi --bit robot01.bit --proc microblaze_mcs_0
// --data c:\users\glen\Documents\workspace-robot\robot01-console\Debug\robot01-console.elf --out program.bit
// write_cfgmem -format BIN -size 4 -interface SPIx1 -loadbit "up 0x0 c:/users/glen/desktop/robot/program.bit" c:/users/glen/desktop/robot/flash
// spansion s25fl032p-spi-x1_x2_x4_0

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xiomodule.h"
#include "registers.h"

XIOModule iomodule;

void InitCommandProcessing (void);
int32_t GetCommand (void);
void ProcessCommand (void);
void ResetGetArgument (void);
char *GetArgument (void);
uint32_t hexatoi (char *a);
int32_t decatoi (char *a);
uint8_t fromhex (char a);

void MoveToCommand (void);
void InfoCommand (void);

int32_t ComputeMoveTime (int32_t acceleration, int32_t velocity, int32_t distance, int32_t *asamps, int32_t *csamps);
int MoveTo (int32_t tc, int32_t tb, int32_t ta, int32_t tz, int32_t ty, int32_t tx);

void MoveXToCommand (void);
void MoveYToCommand (void);
void MoveZToCommand (void);
void MoveAToCommand (void);
void MoveBToCommand (void);
void MoveCToCommand (void);
int MoveXTo (int32_t target);
int MoveYTo (int32_t target);
int MoveZTo (int32_t target);
int MoveATo (int32_t target);
int MoveBTo (int32_t target);
int MoveCTo (int32_t target);

void EnterTrainingMode (void);
void ExitTrainingMode (void);

#define CMD_MAX_LEN 80

uint8_t commandState;
uint8_t commandLength;
uint8_t commandBuffer[CMD_MAX_LEN];
uint8_t wordBegin, wordEnd;

int32_t accelerations[6] = {
    20<<7,         //  base       10000 steps / second /second
    15<<7,         //  shoulder   10000 steps / second /second
    33<<7,         //  elbow       5000 steps / second /second
    67<<7,         //  lower arm  10000 steps / second /second
    67<<7,         //  wrist      10000 steps / second /second
    335<<7,        //  gripper    50000 steps / second /second
};

// vel value = (vel in steps / second) * 2^24 / 50000
int32_t velocities[6] = {
     8388608<<7,   // base       25000 steps / second
     1048576<<7,   // shoulder   25000 steps / second
     4194304<<7,   // elbow      12500 steps / second
     8388608<<7,   // lower arm  25000 steps / second
     8388608<<7,   // wrist      25000 steps / second
   (16777215<<7)-1 // gripper    50000 steps / second
};

int main()
{
	init_platform();

	XIOModule_Initialize(&iomodule, XPAR_IOMODULE_0_DEVICE_ID);
	XIOModule_Start(&iomodule);
	// XIOModule_CfgInitialize(&iomodule, NULL, 1);

	xil_printf ("\n\r\n\rRobot Console v0.01\n\r\n\r");

	Xil_Out32 (MX_LIMIT_LO, -14400);	// gripper rotate
	Xil_Out32 (MX_LIMIT_HI,  14400);
	Xil_Out32 (MX_POSITION,      0);

	Xil_Out32 (MY_LIMIT_LO,  -3000);	// wrist
	Xil_Out32 (MY_LIMIT_HI,   3960);
	Xil_Out32 (MY_POSITION,  -3000);

	Xil_Out32 (MZ_LIMIT_LO,  -7200);	// lower arm rotate
	Xil_Out32 (MZ_LIMIT_HI,   7200);
	Xil_Out32 (MZ_POSITION,      0);

	Xil_Out32 (MA_LIMIT_LO,  -9257);	// elbow
	Xil_Out32 (MA_LIMIT_HI,  12750);
	Xil_Out32 (MA_POSITION,  12750);

	Xil_Out32 (MB_LIMIT_LO,  -5520);	// shoulder
	Xil_Out32 (MB_LIMIT_HI,   6900);
	Xil_Out32 (MB_POSITION,  -5520);

	Xil_Out32 (MC_LIMIT_LO,  -2823);	// base
	Xil_Out32 (MC_LIMIT_HI,   2823);
	Xil_Out32 (MC_POSITION,      0);

	Xil_Out32 (MOTION_ALARM, 0x3f);

	Xil_Out32 (TRAINING,       0);

	Xil_Out32 (MX_TRAIN_ACCEL, accelerations[5]);
	Xil_Out32 (MX_TRAIN_SPEED, 0);
	Xil_Out32 (MX_TRAIN_POS,   Xil_In32 (MX_POSITION));

	Xil_Out32 (MY_TRAIN_ACCEL, accelerations[4]);
	Xil_Out32 (MY_TRAIN_SPEED, 0);
	Xil_Out32 (MY_TRAIN_POS,   Xil_In32 (MY_POSITION));

	Xil_Out32 (MZ_TRAIN_ACCEL, accelerations[3]);
	Xil_Out32 (MZ_TRAIN_SPEED, 0);
	Xil_Out32 (MZ_TRAIN_POS,   Xil_In32 (MZ_POSITION));

	Xil_Out32 (MA_TRAIN_ACCEL, accelerations[2]);
	Xil_Out32 (MA_TRAIN_SPEED, 0);
	Xil_Out32 (MA_TRAIN_POS,   Xil_In32 (MA_POSITION));

	Xil_Out32 (MB_TRAIN_ACCEL, accelerations[1]);
	Xil_Out32 (MB_TRAIN_SPEED, 0);
	Xil_Out32 (MB_TRAIN_POS,   Xil_In32 (MB_POSITION));

	Xil_Out32 (MC_TRAIN_ACCEL, accelerations[0]);
	Xil_Out32 (MC_TRAIN_SPEED, 0);
	Xil_Out32 (MC_TRAIN_POS,   Xil_In32 (MC_POSITION));

	InitCommandProcessing ();

	for (;;) {
		if (GetCommand ()) {
			ProcessCommand ();
		}
	}
}


void InitCommandProcessing (void)
{
	commandState = 0;
	commandLength = 0;
}


int32_t GetCommand (void)
{
	uint32_t length;
	uint8_t ch;

	if (commandState == 0) {
		commandLength = 0;
		commandBuffer[0] = 0;
		xil_printf ("ROBOT> ");
		commandState++;
	} else if (commandState == 1) {
		// try to get a character
		length = XIOModule_Recv (&iomodule, &ch, 1);
		// if character received, add it to the command buffer
		if (length == 1) {
            // process character
            if (ch == 0x0d) {                           // return
                // carriage return and linefeed
            	outbyte (0x0d);
            	outbyte (0x0a);
                commandState++;
            } else if (ch == 0x08) {                    // backspace
                if (commandLength > 0) {
                	outbyte (0x08);
                	outbyte (' ');
                	outbyte (0x08);
                    commandBuffer[--commandLength] = 0;
                }
            } else if (ch == 0x15) {                    // ctrl-u is rub out
                while (commandLength > 0) {
                	outbyte (0x08);
                	outbyte (' ');
                	outbyte (0x08);
                	commandBuffer[--commandLength] = 0;
                }
            } else if (ch >= 0x20 && ch <= 0x7e) {      // printable characters
                if (commandLength < (CMD_MAX_LEN - 1)) {
                	outbyte (ch);
                	commandBuffer[commandLength++] = ch;
                    commandBuffer[commandLength] = 0;
                }
            }
		}
	} else if (commandState != 2) {
		// handle bad states
		commandState = 0;
	}

	return (commandState == 2);
}


void ProcessCommand (void)
{
	char *command;
	uint32_t address;
	uint32_t data;

	ResetGetArgument ();

/*
	while ((command = GetArgument ()) != NULL) {
		xil_printf ("[%s]\n\r", command);
	}
*/

	if ((command = GetArgument ()) != NULL) {
		if (!strcmp (command, "r")) {
			// read register
			if ((command = GetArgument ()) != NULL) {
				address = hexatoi (command);
				data = Xil_In32 (address);
				xil_printf ("%08x: %08x\n\r", address, data);
			}
		} else if (!strcmp (command, "w")) {
			// write register
			if ((command = GetArgument ()) != NULL) {
				address = hexatoi (command);
				if ((command = GetArgument ()) != NULL) {
					data = hexatoi (command);
					Xil_Out32 (address, data);
					xil_printf ("%08x: %08x\n\r", address, data);
				}
			}
		} else if (!strcmp (command, "mt")) {
			MoveToCommand ();
		} else if (!strcmp (command, "mx")) {		// gripper
			MoveXToCommand ();
		} else if (!strcmp (command, "my")) {		// wrist
			MoveYToCommand ();
		} else if (!strcmp (command, "mz")) {		// lower arm rotate
			MoveZToCommand ();
		} else if (!strcmp (command, "ma")) {		// elbow
			MoveAToCommand ();
		} else if (!strcmp (command, "mb")) {		// shoulder
			MoveBToCommand ();
		} else if (!strcmp (command, "mc")) {		// base
			MoveCToCommand ();
		} else if (!strcmp (command, "?")) {
			InfoCommand ();
		} else if (!strcmp (command, "seq1")) {
			do {
				if (MoveTo (    0,     0,     0, 0,     0,     0) < 0) { break; }

				if (MoveTo (    0,  3000,  6000, 0,  2800, -7200) < 0) { break; }
				if (MoveTo (    0,  4350,  6000, 0,  1900,     0) < 0) { break; }
				Xil_Out32 (GPOUT0, 1);
				if (MoveTo (    0,  3000,  6000, 0,  2800, -7200) < 0) { break; }
				if (MoveTo ( 2000,  1400,  8100, 0,  3000,     0) < 0) { break; }
				if (MoveTo ( 2000,  2000,  9000, 0,  2200,     0) < 0) { break; }
				Xil_Out32 (GPOUT0, 0);
				if (MoveTo ( 2000,  1400,  8100, 0,  3000,     0) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  3960, -7200) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  1000,  7200) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  3960, -7200) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  1000,  7200) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  3960, -7200) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  1000,  7200) < 0) { break; }

				if (MoveTo (    0,  3000,  6000, 0,  2800, -7200) < 0) { break; }
				if (MoveTo (    0,  4350,  6000, 0,  1900,     0) < 0) { break; }
				Xil_Out32 (GPOUT0, 1);
				if (MoveTo (    0,  3000,  6000, 0,  2800, -7200) < 0) { break; }
				if (MoveTo ( 2000,  1400,  8100, 0,  3000,     0) < 0) { break; }
				if (MoveTo ( 2000,  2000,  9000, 0,  2200,     0) < 0) { break; }
				Xil_Out32 (GPOUT0, 0);
				if (MoveTo ( 2000,  1400,  8100, 0,  3000,     0) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  3960, -7200) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  1000,  7200) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  3960, -7200) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  1000,  7200) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  3960, -7200) < 0) { break; }
				if (MoveTo (    0, -3000,  7000, 0,  1000,  7200) < 0) { break; }

				if (MoveTo (    0, -5520, 12750, 0, -3000,  0) < 0) { break; }
			} while (0);

/*
		} else if (!strcmp (command, "seq0")) {
			do {
				if (MoveTo (    0,     0,     0, 0,     0, 0) < 0) { break; }
				if (MoveTo (    0,  -946,  7765, 0,  1080, 0) < 0) { break; }
				if (MoveTo (    0,  6870, -5812, 0, -2000, 0) < 0) { break; }
				if (MoveTo ( 1792,  5385,  6222, 0,  1100, 0) < 0) { break; }
				if (MoveTo (    0,  2521, 11313, 0, -2500, 0) < 0) { break; }
				if (MoveTo (    0,  -946,  7765, 0,  1080, 0) < 0) { break; }
				if (MoveTo (-1792,  5385,  6222, 0,  1100, 0) < 0) { break; }
				if (MoveTo (    0,  6870, -5812, 0,  2720, 0) < 0) { break; }
				if (MoveTo (-1792,  5385,  6222, 0,  1100, 0) < 0) { break; }
				if (MoveTo (    0,  2521, 11313, 0, -2500, 0) < 0) { break; } // was 720 instead of 2500
				if (MoveTo ( 1792,  5385,  6222, 0,  1100, 0) < 0) { break; }
				if (MoveTo (    0, -5520, 12750, 0, -3000, 0) < 0) { break; }
			} while (0);
*/
		} else if(!strcmp (command, "o")) {
			// open gripper
			xil_printf ("open gripper\n\r");
			Xil_Out32 (GPOUT0, 0);
		} else if(!strcmp (command, "c")) {
			// close gripper
			xil_printf ("close gripper\n\r");
			Xil_Out32 (GPOUT0, 1);
		} else if(!strcmp (command, "train")) {
			EnterTrainingMode ();
		} else if(!strcmp (command, "notrain")) {
			ExitTrainingMode ();
		}
	}

	// reset command buffer
	commandState = 0;
}


void ResetGetArgument (void)
{
	wordBegin = 0;
	wordEnd = 0;
}


char *GetArgument (void)
{
	// start with end of previous word
	wordBegin = wordEnd;

	// find start of word
	while (((commandBuffer[wordBegin] == ' ') || (commandBuffer[wordBegin] == 0x00)) && (wordBegin < commandLength)) {
		wordBegin++;
	}

	// find end of word
	wordEnd = wordBegin;
	while ((commandBuffer[wordEnd] != ' ') && (wordEnd < commandLength)) {
		wordEnd++;
	}

	if ((wordEnd - wordBegin) > 0) {
		// terminate and return the string
		commandBuffer[wordEnd] = 0;
		return (char *)&commandBuffer[wordBegin];
	}

	return NULL;
}


uint32_t hexatoi (char *a)
{
	char ch;
	uint32_t v = 0;

	while ((ch = *a++) != 0) {
		v = (v << 4) | fromhex (ch);
	}

	return v;
}


uint8_t fromhex (char a)
{
	if ((a >= '0') && (a <= '9'))
		return a - '0';
	else if ((a >= 'a') && (a <= 'f'))
		return a - 'a' + 10;
	else if ((a >= 'A') && (a <= 'F'))
		return a - 'A' + 10;
	return 0;
}

int32_t decatoi (char *a)
{
	char ch;
    int32_t sign = 1;
    int32_t result = 0;

	while ((ch = *a++) != 0) {
		if (ch == '-') {
            sign = -1;
        } else {
            result = 10 * result + (ch - '0');
        }
    }

    return sign * result;
}


void InfoCommand (void)
{
	uint32_t busy = Xil_In32 (MOTION_BUSY);
	uint32_t preq = Xil_In32 (MOTION_PRGM_REQ);
	uint32_t alarm = Xil_In32 (MOTION_ALARM);

	xil_printf ("      XYZABC\n\r");

	xil_printf ("Busy: %c%c%c%c%c%c\n\r",
			(busy & 0x20) ? '1' : '0',
			(busy & 0x10) ? '1' : '0',
			(busy & 0x08) ? '1' : '0',
			(busy & 0x04) ? '1' : '0',
			(busy & 0x02) ? '1' : '0',
			(busy & 0x01) ? '1' : '0');

	xil_printf ("PReq: %c%c%c%c%c%c\n\r",
			(preq & 0x20) ? '1' : '0',
			(preq & 0x10) ? '1' : '0',
			(preq & 0x08) ? '1' : '0',
			(preq & 0x04) ? '1' : '0',
			(preq & 0x02) ? '1' : '0',
			(preq & 0x01) ? '1' : '0');

	xil_printf ("Alrm: %c%c%c%c%c%c\n\r",
			(alarm & 0x20) ? '1' : '0',
			(alarm & 0x10) ? '1' : '0',
			(alarm & 0x08) ? '1' : '0',
			(alarm & 0x04) ? '1' : '0',
			(alarm & 0x02) ? '1' : '0',
			(alarm & 0x01) ? '1' : '0');

	xil_printf ("C (base): %6d %6d %6d\n\r", (signed)Xil_In32 (MC_LIMIT_LO), (signed)Xil_In32 (MC_POSITION), (signed)Xil_In32 (MC_LIMIT_HI));
	xil_printf ("B (shld): %6d %6d %6d\n\r", (signed)Xil_In32 (MB_LIMIT_LO), (signed)Xil_In32 (MB_POSITION), (signed)Xil_In32 (MB_LIMIT_HI));
	xil_printf ("A (elbw): %6d %6d %6d\n\r", (signed)Xil_In32 (MA_LIMIT_LO), (signed)Xil_In32 (MA_POSITION), (signed)Xil_In32 (MA_LIMIT_HI));
	xil_printf ("Z (larm): %6d %6d %6d\n\r", (signed)Xil_In32 (MZ_LIMIT_LO), (signed)Xil_In32 (MZ_POSITION), (signed)Xil_In32 (MZ_LIMIT_HI));
	xil_printf ("Y (wrst): %6d %6d %6d\n\r", (signed)Xil_In32 (MY_LIMIT_LO), (signed)Xil_In32 (MY_POSITION), (signed)Xil_In32 (MY_LIMIT_HI));
	xil_printf ("X (grot): %6d %6d %6d\n\r", (signed)Xil_In32 (MX_LIMIT_LO), (signed)Xil_In32 (MX_POSITION), (signed)Xil_In32 (MX_LIMIT_HI));
}


void MoveToCommand (void)
{
	char *command;
	int32_t targets[6];

	do {

		if (!(command = GetArgument ())) {
			break;
		}
		targets[0] = decatoi (command);
		if (!(command = GetArgument ())) {
			break;
		}
		targets[1] = decatoi (command);
		if (!(command = GetArgument ())) {
			break;
		}
		targets[2] = decatoi (command);
		if (!(command = GetArgument ())) {
			break;
		}
		targets[3] = decatoi (command);
		if (!(command = GetArgument ())) {
			break;
		}
		targets[4] = decatoi (command);
		if (!(command = GetArgument ())) {
			break;
		}
		targets[5] = decatoi (command);

		MoveTo (targets[0], targets[1], targets[2], targets[3], targets[4], targets[5]);

	} while (0);
}


int MoveTo (int32_t tc, int32_t tb, int32_t ta, int32_t tz, int32_t ty, int32_t tx)
{
	int32_t distances[6];
	int32_t samples[6];
	int32_t asamps[6], csamps[6];
	int32_t newAccelerations[6], newVelocities[6];
	uint8_t ch;
	uint32_t length;
	int slowest;
	int i;
	int result = 0;

	do {
		distances[0] = tc - (signed)Xil_In32 (MC_POSITION);
		distances[1] = tb - (signed)Xil_In32 (MB_POSITION);
		distances[2] = ta - (signed)Xil_In32 (MA_POSITION);
		distances[3] = tz - (signed)Xil_In32 (MZ_POSITION);
		distances[4] = ty - (signed)Xil_In32 (MY_POSITION);
		distances[5] = tx - (signed)Xil_In32 (MX_POSITION);

		xil_printf ("C (base): %6d %6d %6d\n\r", (signed)Xil_In32 (MC_POSITION), tc, distances[0]);
		xil_printf ("B (shld): %6d %6d %6d\n\r", (signed)Xil_In32 (MB_POSITION), tb, distances[1]);
		xil_printf ("A (elbw): %6d %6d %6d\n\r", (signed)Xil_In32 (MA_POSITION), ta, distances[2]);
		xil_printf ("Z (larm): %6d %6d %6d\n\r", (signed)Xil_In32 (MZ_POSITION), tz, distances[3]);
		xil_printf ("Y (wrst): %6d %6d %6d\n\r", (signed)Xil_In32 (MY_POSITION), ty, distances[4]);
		xil_printf ("X (grot): %6d %6d %6d\n\r", (signed)Xil_In32 (MX_POSITION), tx, distances[5]);

		slowest = -1;
		for (i = 0; i < 6; i++) {
			samples[i] = ComputeMoveTime (accelerations[i], velocities[i], distances[i], &asamps[i], &csamps[i]);
			xil_printf ("axis: %d samples: %d\n\r", i, samples[i]);
			if (slowest < 0) {
				slowest = i;
			} else if (samples[i] > samples[slowest]) {
				slowest = i;
			}
		}

		xil_printf ("slowest axis is axis %d\n\r", slowest);

		for (i = 0; i < 6; i++) {

			newAccelerations[i] =
				(double)accelerations[i] * (double)samples[i] * (double)samples[i] /
				(double)samples[slowest] / (double)samples[slowest];
			newVelocities[i] = velocities[i] * (double)samples[i] / (double)samples[slowest];

			if (distances[i] != 0) {
				if (newAccelerations[i] == 0) {
					newAccelerations[i] = 1;
				}
				if (velocities[i] == 0) {
					velocities[i] = 1;
				}
			}

			samples[i] = ComputeMoveTime (newAccelerations[i], newVelocities[i], distances[i], &asamps[i], &csamps[i]);
			xil_printf ("axis %d: newa: %6d, asamps: %6d, csamps: %6d\n\r", i, newAccelerations[i], asamps[i], csamps[i]);
		}

		Xil_Out32 (MC_PRGM_DIR,    (distances[0] >= 0) ? 1 : -1);
		Xil_Out32 (MC_PRGM_ACC,    newAccelerations[0]);
		Xil_Out32 (MC_PRGM_ASAMPS, asamps[0]);
		Xil_Out32 (MC_PRGM_CSAMPS, csamps[0]);

		Xil_Out32 (MB_PRGM_DIR,    (distances[1] >= 0) ? 1 : -1);
		Xil_Out32 (MB_PRGM_ACC,    newAccelerations[1]);
		Xil_Out32 (MB_PRGM_ASAMPS, asamps[1]);
		Xil_Out32 (MB_PRGM_CSAMPS, csamps[1]);

		Xil_Out32 (MA_PRGM_DIR,    (distances[2] >= 0) ? 1 : -1);
		Xil_Out32 (MA_PRGM_ACC,    newAccelerations[2]);
		Xil_Out32 (MA_PRGM_ASAMPS, asamps[2]);
		Xil_Out32 (MA_PRGM_CSAMPS, csamps[2]);

		Xil_Out32 (MZ_PRGM_DIR,    (distances[3] >= 0) ? 1 : -1);
		Xil_Out32 (MZ_PRGM_ACC,    newAccelerations[3]);
		Xil_Out32 (MZ_PRGM_ASAMPS, asamps[3]);
		Xil_Out32 (MZ_PRGM_CSAMPS, csamps[3]);

		Xil_Out32 (MY_PRGM_DIR,    (distances[4] >= 0) ? 1 : -1);
		Xil_Out32 (MY_PRGM_ACC,    newAccelerations[4]);
		Xil_Out32 (MY_PRGM_ASAMPS, asamps[4]);
		Xil_Out32 (MY_PRGM_CSAMPS, csamps[4]);

		Xil_Out32 (MX_PRGM_DIR,    (distances[5] >= 0) ? 1 : -1);
		Xil_Out32 (MX_PRGM_ACC,    newAccelerations[5]);
		Xil_Out32 (MX_PRGM_ASAMPS, asamps[5]);
		Xil_Out32 (MX_PRGM_CSAMPS, csamps[5]);

		Xil_Out32 (MOTION_PRGM_REQ, 0x3f);

		while (Xil_In32(MOTION_PRGM_REQ) || Xil_In32(MOTION_BUSY)) {
			length = XIOModule_Recv (&iomodule, &ch, 1);
			if (length == 1) {
				result = -1;
				break;
			}
		}

	} while (0);

	return result;
}


int32_t ComputeMoveTime (int32_t acceleration, int32_t velocity, int32_t distance, int32_t *asamps, int32_t *csamps)
{
    int32_t accelSamples = 0, cruiseSamples = 0;
	int32_t cruiseVelocity = 0;
	int64_t accelDistance = 0, cruiseDistance = 0, decelDistance = 0;

    int64_t targetDistance = (int64_t)distance << (25+7);

	int32_t targetDirection = 0;
    if (targetDistance > 0) {
        targetDirection = 1;
    } else if (targetDistance < 0) {
        targetDirection = -1;
        targetDistance = -targetDistance;
    } else {
        targetDirection = 0;
    }

	if (targetDirection == 0) {

		// no move
		accelSamples = 0;
		cruiseSamples = 0;

	} else {

		accelSamples = velocity / acceleration;
		if (accelSamples == 0) {
			accelSamples = 1;
		}
		cruiseVelocity = acceleration * accelSamples;
		accelDistance = (int64_t)acceleration * accelSamples * accelSamples;
		decelDistance = accelDistance;

		cruiseDistance = targetDistance - accelDistance - decelDistance;
		cruiseSamples = ceil((double)cruiseDistance / (double)cruiseVelocity / 2.0);
		cruiseDistance = (int64_t)cruiseSamples * cruiseVelocity;

		if (cruiseDistance < 0) {

			// short move
			int64_t halfDistance = targetDistance >> 1;

			accelSamples = floor(sqrt((double)halfDistance/(double)acceleration));
			if (accelSamples == 0) {
				accelSamples = 1;
			}
			cruiseVelocity = acceleration * accelSamples;
			accelDistance = (int64_t)acceleration * accelSamples * accelSamples;

			decelDistance = accelDistance;

			cruiseDistance = targetDistance - accelDistance - decelDistance;
			cruiseSamples = ceil((double)cruiseDistance / (double)cruiseVelocity / 2.0);
			cruiseDistance = (int64_t)cruiseSamples * cruiseVelocity;

		}
	}

	*asamps = accelSamples;
	*csamps = cruiseSamples;

	return 2 * accelSamples + cruiseSamples;

}


void EnterTrainingMode (void)
{
	xil_printf ("Entering Training Mode\n\r");

	Xil_Out32 (MX_TRAIN_ACCEL, accelerations[5]);
	Xil_Out32 (MX_TRAIN_SPEED, 0);
	Xil_Out32 (MX_TRAIN_POS,   Xil_In32 (MX_POSITION));

	Xil_Out32 (MY_TRAIN_ACCEL, accelerations[4]);
	Xil_Out32 (MY_TRAIN_SPEED, 0);
	Xil_Out32 (MY_TRAIN_POS,   Xil_In32 (MY_POSITION));

	Xil_Out32 (MZ_TRAIN_ACCEL, accelerations[3]);
	Xil_Out32 (MZ_TRAIN_SPEED, 0);
	Xil_Out32 (MZ_TRAIN_POS,   Xil_In32 (MZ_POSITION));

	Xil_Out32 (MA_TRAIN_ACCEL, accelerations[2]);
	Xil_Out32 (MA_TRAIN_SPEED, 0);
	Xil_Out32 (MA_TRAIN_POS,   Xil_In32 (MA_POSITION));

	Xil_Out32 (MB_TRAIN_ACCEL, accelerations[1]);
	Xil_Out32 (MB_TRAIN_SPEED, 0);
	Xil_Out32 (MB_TRAIN_POS,   Xil_In32 (MB_POSITION));

	Xil_Out32 (MC_TRAIN_ACCEL, accelerations[0]);
	Xil_Out32 (MC_TRAIN_SPEED, 0);
	Xil_Out32 (MC_TRAIN_POS,   Xil_In32 (MC_POSITION));

	Xil_Out32 (TRAINING,       0x80000000);

	Xil_Out32 (MX_TRAIN_SPEED, velocities[5] / 4);
	Xil_Out32 (MY_TRAIN_SPEED, velocities[4] / 4);
	Xil_Out32 (MZ_TRAIN_SPEED, velocities[3] / 4);
	Xil_Out32 (MA_TRAIN_SPEED, velocities[2] / 4);
	Xil_Out32 (MB_TRAIN_SPEED, velocities[1] / 2);
	Xil_Out32 (MC_TRAIN_SPEED, velocities[0] / 16);
}

void ExitTrainingMode (void)
{
	uint32_t inMotion;

	xil_printf ("Exiting Training Mode\n\r");

	Xil_Out32 (MX_TRAIN_SPEED, 0);
	Xil_Out32 (MY_TRAIN_SPEED, 0);
	Xil_Out32 (MZ_TRAIN_SPEED, 0);
	Xil_Out32 (MA_TRAIN_SPEED, 0);
	Xil_Out32 (MB_TRAIN_SPEED, 0);
	Xil_Out32 (MC_TRAIN_SPEED, 0);

	do {
		inMotion = Xil_In32 (TRAINING) & 0x3f;
		xil_printf ("axes in motions: 0x%02x\n\r", inMotion);
	} while (inMotion != 0);

	Xil_Out32 (TRAINING, 0);
}

void MoveXToCommand (void)
{
	char *command;
	if (!(command = GetArgument ())) {
		return;
	}
	MoveXTo (decatoi (command));
}

void MoveYToCommand (void)
{
	char *command;
	if (!(command = GetArgument ())) {
		return;
	}
	MoveYTo (decatoi (command));
}

void MoveZToCommand (void)
{
	char *command;
	if (!(command = GetArgument ())) {
		return;
	}
	MoveZTo (decatoi (command));
}

void MoveAToCommand (void)
{
	char *command;
	if (!(command = GetArgument ())) {
		return;
	}
	MoveATo (decatoi (command));
}

void MoveBToCommand (void)
{
	char *command;
	if (!(command = GetArgument ())) {
		return;
	}
	MoveBTo (decatoi (command));
}

void MoveCToCommand (void)
{
	char *command;
	if (!(command = GetArgument ())) {
		return;
	}
	MoveCTo (decatoi (command));
}

int MoveXTo (int32_t target)
{
	int32_t position, distance, samples, asamps, csamps;
	uint32_t length;
	int result = 0;
	uint8_t ch;

	position = (signed)Xil_In32 (MX_POSITION);
	distance = target - position;

	xil_printf ("X (grot): %6d %6d %6d\n\r", position, target, distance);

	samples = ComputeMoveTime (accelerations[5], velocities[5], distance, &asamps, &csamps);
	xil_printf ("axis %d: newa: %6d, asamps: %6d, csamps: %6d, tsamps: %6d\n\r", 5, accelerations[5], asamps, csamps, samples);

	Xil_Out32 (MX_PRGM_DIR,    (distance >= 0) ? 1 : -1);
	Xil_Out32 (MX_PRGM_ACC,    accelerations[5]);
	Xil_Out32 (MX_PRGM_ASAMPS, asamps);
	Xil_Out32 (MX_PRGM_CSAMPS, csamps);

	Xil_Out32 (MOTION_PRGM_REQ, 0x20);

	while (Xil_In32(MOTION_PRGM_REQ) || Xil_In32(MOTION_BUSY)) {
		length = XIOModule_Recv (&iomodule, &ch, 1);
		if (length == 1) {
			result = -1;
			break;
		}
	}

	return result;
}

int MoveYTo (int32_t target)
{
	int32_t position, distance, samples, asamps, csamps;
	uint32_t length;
	int result = 0;
	uint8_t ch;

	position = (signed)Xil_In32 (MY_POSITION);
	distance = target - position;
	xil_printf ("Y (wrst): %6d %6d %6d\n\r", position, target, distance);
	samples = ComputeMoveTime (accelerations[4], velocities[4], distance, &asamps, &csamps);
	xil_printf ("axis %d: newa: %6d, asamps: %6d, csamps: %6d, tsamps: %6d\n\r", 4, accelerations[4], asamps, csamps, samples);

	Xil_Out32 (MY_PRGM_DIR,    (distance >= 0) ? 1 : -1);
	Xil_Out32 (MY_PRGM_ACC,    accelerations[4]);
	Xil_Out32 (MY_PRGM_ASAMPS, asamps);
	Xil_Out32 (MY_PRGM_CSAMPS, csamps);

	Xil_Out32 (MOTION_PRGM_REQ, 0x10);

	while (Xil_In32(MOTION_PRGM_REQ) || Xil_In32(MOTION_BUSY)) {
		length = XIOModule_Recv (&iomodule, &ch, 1);
		if (length == 1) {
			result = -1;
			break;
		}
	}

	return result;
}

int MoveZTo (int32_t target)
{
	int32_t position, distance, samples, asamps, csamps;
	uint32_t length;
	int result = 0;
	uint8_t ch;

	position = (signed)Xil_In32 (MZ_POSITION);
	distance = target - position;
	xil_printf ("Z (larm): %6d %6d %6d\n\r", position, target, distance);
	samples = ComputeMoveTime (accelerations[3], velocities[3], distance, &asamps, &csamps);
	xil_printf ("axis %d: newa: %6d, asamps: %6d, csamps: %6d, tsamps: %6d\n\r", 3, accelerations[3], asamps, csamps, samples);

	Xil_Out32 (MZ_PRGM_DIR,    (distance >= 0) ? 1 : -1);
	Xil_Out32 (MZ_PRGM_ACC,    accelerations[3]);
	Xil_Out32 (MZ_PRGM_ASAMPS, asamps);
	Xil_Out32 (MZ_PRGM_CSAMPS, csamps);

	Xil_Out32 (MOTION_PRGM_REQ, 0x08);

	while (Xil_In32(MOTION_PRGM_REQ) || Xil_In32(MOTION_BUSY)) {
		length = XIOModule_Recv (&iomodule, &ch, 1);
		if (length == 1) {
			result = -1;
			break;
		}
	}

	return result;
}

int MoveATo (int32_t target)
{
	int32_t position, distance, samples, asamps, csamps;
	uint32_t length;
	int result = 0;
	uint8_t ch;

	position = (signed)Xil_In32 (MA_POSITION);
	distance = target - position;
	xil_printf ("A (elbw): %6d %6d %6d\n\r", position, target, distance);
	samples = ComputeMoveTime (accelerations[2], velocities[2], distance, &asamps, &csamps);
	xil_printf ("axis %d: newa: %6d, asamps: %6d, csamps: %6d, tsamps: %6d\n\r", 2, accelerations[2], asamps, csamps, samples);

	Xil_Out32 (MA_PRGM_DIR,    (distance >= 0) ? 1 : -1);
	Xil_Out32 (MA_PRGM_ACC,    accelerations[2]);
	Xil_Out32 (MA_PRGM_ASAMPS, asamps);
	Xil_Out32 (MA_PRGM_CSAMPS, csamps);

	Xil_Out32 (MOTION_PRGM_REQ, 0x04);

	while (Xil_In32(MOTION_PRGM_REQ) || Xil_In32(MOTION_BUSY)) {
		length = XIOModule_Recv (&iomodule, &ch, 1);
		if (length == 1) {
			result = -1;
			break;
		}
	}

	return result;
}

int MoveBTo (int32_t target)
{
	int32_t position, distance, samples, asamps, csamps;
	uint32_t length;
	int result = 0;
	uint8_t ch;

	position = (signed)Xil_In32 (MB_POSITION);
	distance = target - position;
	xil_printf ("B (shld): %6d %6d %6d\n\r", position, target, distance);
	samples = ComputeMoveTime (accelerations[1], velocities[1], distance, &asamps, &csamps);
	xil_printf ("axis %d: newa: %6d, asamps: %6d, csamps: %6d, tsamps: %6d\n\r", 1, accelerations[1], asamps, csamps, samples);

	Xil_Out32 (MB_PRGM_DIR,    (distance >= 0) ? 1 : -1);
	Xil_Out32 (MB_PRGM_ACC,    accelerations[1]);
	Xil_Out32 (MB_PRGM_ASAMPS, asamps);
	Xil_Out32 (MB_PRGM_CSAMPS, csamps);

	Xil_Out32 (MOTION_PRGM_REQ, 0x02);

	while (Xil_In32(MOTION_PRGM_REQ) || Xil_In32(MOTION_BUSY)) {
		length = XIOModule_Recv (&iomodule, &ch, 1);
		if (length == 1) {
			result = -1;
			break;
		}
	}

	return result;
}

int MoveCTo (int32_t target)
{
	int32_t position, distance, samples, asamps, csamps;
	uint32_t length;
	int result = 0;
	uint8_t ch;

	position = (signed)Xil_In32 (MC_POSITION);
	distance = target - position;
	xil_printf ("C (base): %6d %6d %6d\n\r", position, target, distance);
	samples = ComputeMoveTime (accelerations[0], velocities[0], distance, &asamps, &csamps);
	xil_printf ("axis %d: newa: %6d, asamps: %6d, csamps: %6d, tsamps: %6d\n\r", 0, accelerations[0], asamps, csamps, samples);

	Xil_Out32 (MC_PRGM_DIR,    (distance >= 0) ? 1 : -1);
	Xil_Out32 (MC_PRGM_ACC,    accelerations[0]);
	Xil_Out32 (MC_PRGM_ASAMPS, asamps);
	Xil_Out32 (MC_PRGM_CSAMPS, csamps);

	Xil_Out32 (MOTION_PRGM_REQ, 0x01);

	while (Xil_In32(MOTION_PRGM_REQ) || Xil_In32(MOTION_BUSY)) {
		length = XIOModule_Recv (&iomodule, &ch, 1);
		if (length == 1) {
			result = -1;
			break;
		}
	}

	return result;
}


