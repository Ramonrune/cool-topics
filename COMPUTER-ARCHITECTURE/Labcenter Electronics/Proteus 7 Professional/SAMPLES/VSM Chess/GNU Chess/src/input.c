/* GNU Chess 5.0 - input.c - Input thread and related

Bastardized version since we have no RTOS - unless we were
to try an interrupt driven UART input scheme.

*/

/*
 * All the pthread stuff should be hidden here, all the
 * readline things, too. (I.e., all the potentially troublesome
 * libraries.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "graphics.h"

/*
 * input_status is a boolean to indicate if a command
 * is being parsed and processed. It is set by
 * input function, and must be cleared by the thread
 * that uses the input.
 *
 * The main loop may explicitly wait_for_input, or
 * when pondering will examine the input_status
 * variable in Iterate.
 *
 */

// Since we are not multithreading, we report that input is always available.
volatile int input_status = INPUT_AVAILABLE; 
  
char inputstr[MAXSTR];

extern void getline_standard(char *p);
extern void getline_restore(char *p);

void InitInput(void)
// Initialize the input system.
{ 

  getline = getline_standard;

}

void CleanupInput(void)
// Shutdown the input system.
{

}

void wait_for_input(void)
// Gets a new line of input into inputstr.
// This is called directly from main().
 { char prompt[MAXSTR] = "";

   sprintf(prompt,"%s (%d) : ", 
	      RealSide ? "Black" : "White", 
	      (RealGameCnt+1)/2 + 1 );

  	sound_yourmove();

   getline(prompt);

}

void input_wakeup(void)
// Not needed here. Used to signal that input had been consumed, and
// thus re-activates the input stream.
{
	  
  // pthread_mutex_lock(&input_mutex);
  // input_status = INPUT_NONE;
  // pthread_mutex_unlock(&input_mutex);
  // pthread_mutex_lock(&wakeup_mutex);
  // pthread_cond_signal(&wakeup_cond);
  // pthread_mutex_unlock(&wakeup_mutex);
}

/* The generic input routine. */

void getline_standard(char *p)
 { LOC from, to;
   WORD btns;

   if (!(flags & XBOARD)) 
    { fputs(p, stdout);
      fflush(stdout);
    }

   *inputstr = 0;
   do
    { if (panel_getmove(RealSide ? BLACK : WHITE, from, to))
       { // Process touchpad event
         sprintf(inputstr, "%c%c%c%c\n", from[1]+'a', from[0]+'1', to[1]+'a', to[0]+'1');
         printf("User move: %s", inputstr);
       }
      else if ((btns=panel_pollbtns()) != 0)
       { // Process special function buttons
         if (btns & BTN_NEW)
          { strcpy(inputstr, "new\n");
            printf(inputstr);
          }
         else if (btns & BTN_SAVE)
          { printf("Saving game position...\n");            
            panel_save();
          }
         else if (btns & BTN_LOAD)
          { if (panel_load())
             { printf("Loading game position...\n");
               sprintf(inputstr, "setboard %s\n", panel_getEPD());

             }
            else
               printf("*** ERROR - no saved position");               
          }
         else if (btns & BTN_GO)
          { strcpy(inputstr, "go\n");
            printf(inputstr);
          }

         // Wait for button release
         while (panel_pollbtns() != 0)
            ;
       }
	  else if (panel_polltty())
	   { // Process TTY command:
        gets(inputstr);
 	   }
    } while (*inputstr == 0);

  }
  
