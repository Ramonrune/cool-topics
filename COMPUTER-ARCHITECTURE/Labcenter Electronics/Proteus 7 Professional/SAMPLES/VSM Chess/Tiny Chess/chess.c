/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****              PROTEUS VSM TINY CHESS SAMPLE               *****/
/*****                                                          *****/
/*****                        Main File                         *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include "chess.h"

// General Variables.
ZPAGE BOARD board;
ZPAGE MASK validmovemask;
ZPAGE MASK capturemask;
ZPAGE INT movecount;
ZPAGE BYTE movetype;
ZPAGE BYTE rate;
ZPAGE BYTE piecerate;
ZPAGE BYTE lastmove;
// Check/Checkmate.
ZPAGE LOC wh_king_pos;
ZPAGE LOC bl_king_pos;
ZPAGE LOC opp_king_pos;
ZPAGE BOOL kingcapture;
//Castling.
ZPAGE BYTE wh_base_cont;
ZPAGE BYTE bl_base_cont;

ZPAGE MASK currcapturemask;
ZPAGE MASK currmovemask;


FUNCPTR validate[7] = {&val_empty,&val_pawn,&val_rook,&val_knight,&val_bishop,&val_queen,&val_king};

   extern void sleep (int);

main (void )
// Initialise the board and go to the
// designated play control function. 
 { movecount   = 1;
   kingcapture = FALSE;
   movetype = NO_MOVE;      
   panel_init();
   init_board();
   cpuplay();
 }
 
VOID cpuplay()
// Control Function for a single player game.
 { LOC from, to, cpufrom,cputo;
   PIECE p;
   BYTE i = 0, j = 0;
   BYTE movefrom,bestfrom,moveto,bestto; 
   BYTE illegal = FALSE;

   while (TRUE)
    { // User Move (White).
      if ((movecount+1)%2 == 0)
       { printf("Your Move :\n");
         if (!illegal)
            sound_yourmove();
         else
            illegal = FALSE;   

         // Get the move.
         while (!panel_getmove(from, to))
            ;
         p = board[from[0]][from[1]];
         //getindex(to[0],to[1]);
            
         // Get valid moves for given piece.
         validate[piecetype(p)] (from,WHITE);
         
         // Next, Verify that we can make the move and
         // deal with the King/Check logic.          
         if (is_valid_move(to[0],to[1]) && test_singlemove(from,to,board[from[0]][from[1]]))
          { draw_move(from,to,p);
            printf("%c%c -> %c%c\n", from[1]+'a', from[0]+'1',to[1]+'a', to[0]+'1');
            movecount++;
          }
         else
          { printf ("\nInvalid move for specified piece\n");
            sound_illegal();
            illegal = TRUE;
          }

         // Finally, Clear our masks and reset bools.
         for (i = 0; i < 8;++i)
          {// Clear our mask.
            validmovemask[i] = 0;
            capturemask[i] = 0;
          }
       }
  
      // CPU move.
      else if ((movecount+1)%2 == 1)
       { bestfrom = bestto = NO_MOVE;
         rate = piecerate = 0;
         printf ("My Move...Thinking:\n");
      
         // For every black piece... 
         for (i = 0; i < 8;++i)
          { for (j = 0;j < 8;++j)
             { if (board[i][j] & 0x08)
                { // Get possible moves.
                  cpufrom[0] = i;
                  cpufrom[1] = j;
                  p = board[i][j];
                  validate[piecetype(p)](cpufrom,BLACK);

                  // Get best move for that piece. 
                  moveto   = getbestpiecemove(cpufrom);
                  movefrom = getindex(cpufrom[0],cpufrom[1]); 
               
                  if (((board[cpufrom[0]][cpufrom[1]]&0x07) == lastmove) && (movetype < 3))
                   { // Prevent consistent moving of the same piece.
                     piecerate -= 3;
                   }
                  
                 if (piecerate > rate)
                   { rate     = piecerate;
                     bestfrom = movefrom;
                     bestto   = moveto;
                   }

                  moveto = movefrom = -1;
                }
               movetype = NO_MOVE;  
             }  
          }
        if (rate != 0) 
         { // We can move.
           getcoord (cpufrom[0],cpufrom[1],bestfrom);   
           getcoord (cputo[0],cputo[1],bestto);   
           p = board[(cpufrom[0])][(cpufrom[1])];
           draw_move(cpufrom,cputo,p);
           lastmove = (((p&0x07) != PAWN) && ((p&0x07) != KING)) ? p&0x07 : 0;
           printf("%c%c -> %c%c\n", cpufrom[1]+'a', cpufrom[0]+'1',cputo[1]+'a', cputo[0]+'1');
           movecount++;
         }
        else
         { //Checkmate.
           printf("Another Crushing Defeat for the CPU - You Win\n\n");
           movecount++;   
         } 

       }

      else
       { // Trying to move CPU piece.
         printf("\nNice Try Amigo\n");
       }
    }
 }

INT getbestpiecemove(LOC from)
// This function tests all the valid moves for
// the specified piece and returns the index
// of the best move.
 { BYTE i,j,k;
   BYTE tmp;
   LOC to;
   BYTE move,bestmove,curr_pos_rate;
   bestmove = NO_MOVE;
   piecerate = tmp = 0;

   // validmovemask and capturemask at this point
   // refer to our piece. That is, pieces we can take
   // and moves we can make with the current piece.
   // We need to take a copy and then clear these masks
   // prior to testing for opponents positions/captures.
   for (i = 0; i < 8;++i)
    { currmovemask[i]    = validmovemask[i];
      currcapturemask[i] = capturemask[i];
      validmovemask[i] = 0;
      capturemask[i] = 0;
    }

   for (i = 0; i < 8; ++i)
    { for (j = 0; j < 8; ++j)
       { if (currmovemask[i] & 0x01)
          { // Test a Valid Move.
            to[0] = i;
            to[1] = j; 
            if (test_singlemove(from,to,board[from[0]][from[1]]))
             { // At this point the validmovemask and capturemask
               // refer to our opponents pieces. Of interest to us is
               // the capturemask as it tells us if we are moving into danger.
               move = getindex(to[0],to[1]);
               movetype = NORMAL;  
               if ((validmovemask[from[0]] >> from[1]) & 1)            
                { // Piece can be taken - add some weight to escape. 
                  tmp = (board[from[0]][from[1]] & 0x07)/2;
                }
   
               if((!((capturemask[i] >> j) & 1)) && ((currcapturemask[i] >> j) & 1))
                { // Best Case Scenario - We can Capture a piece and cannot be
                  // captured in turn.
                  movetype = SAFECAPTURE;
                }
               else if ((currcapturemask[i] >> j) & 1)
                { // Can Capture a piece.
                  movetype = CAPTURE;
                }
               else if (!((capturemask[i] >> j) & 1))
                { // Safe move.
                  movetype = SAFE;
                }  
                              

               // Rate the position of the move against our designates ideal pos.(3,3).
               curr_pos_rate  = (to[0] > 3)? to[0]-3 : 3-to[0];
               k  = (to[1] > 3)? to[1]-3 : 3-to[1];
               curr_pos_rate += k;      
               
               // Rate the move.               
               tmp += rate_move((board[from[0]][from[1]]),to,curr_pos_rate);

               if (tmp > piecerate)
                { // A better move that any so far with this piece.
                  piecerate = tmp;
                  bestmove = move;
                }   
               tmp = 0;  
             }
            for (k = 0; k < 8; ++k)
             { // Reset Masks.
               validmovemask[k] = 0;
               capturemask[k]   = 0;
             }
          }
         currmovemask[i] = currmovemask[i] >> 1;
       }
    }
  if (bestmove != NO_MOVE) printf("bm : %d,from : %d,%d, rate: %d  movetype : %d\n",bestmove,from[0],from[1],piecerate,movetype); 
  return bestmove;
 }

BOOL test_singlemove (LOC from,LOC to,PIECE p)
// When a piece can move into a position we check whether
// that violates rules such as check, castling.
// Return true if move ok, false otherwise.
 { INT i = 0,j = 0; 
   LOC opp_pos;
   PIECE opp_piece,tmpdest;

   // If a king has moved update our internal record.
   if ((p & 0x07) == KING) updatekingpos(to,(p & 0x08));

   // Take a copy of the destination contents in case our
   // move is invalid.
   tmpdest = board[to[0]][to[1]];

   // Update our internal matrix with the move.
   board[from[0]][from[1]] = EMPTY;
   board[to[0]][to[1]] = p;
    
           
   // Test our opponents pieces to see if any can capture our king.
   kingcapture = FALSE;
   i = j = 0;
   while ((i < 8) && (!kingcapture))
    { // scan rows.
      while ((j < 8) && (!kingcapture))
       { // scan columns.
         if (is_opp_piece(i,j,(p&0x08)))
          { // Opponents Piece - Get valid moves.
            opp_pos[0] = i, opp_pos[1] = j,opp_piece = board[i][j];
            validate[piecetype(opp_piece)] (opp_pos,(opp_piece & 0x08));
          }
         j++;
        }
       j = 0;
       i++;
    }
   // Finished Testing - Restore our internals. 
   board[to[0]][to[1]] = tmpdest;
   board[from[0]][from[1]] = p;
   if ((p & 0x07) == KING) updatekingpos(from,(p & 0x08));

   return (kingcapture) ? FALSE : TRUE;
 }

INT rate_move(PIECE piece, LOC to,BYTE posrate)
// Calculate the relative worth of making
// a move. Based on the type of move, piece
// being moved, position moved to and subsequent danger.
// posrate is a level between 0-8  indicating closeness to
// the center of the board.
// Some manual 'fudging' is involved here to improve performance.
 { BYTE tmp, value, rating;
   
   // We dont want our king charging down the board...
   value = ((piece & 0x07)== KING) ? 0 : (piece&0x07);    

   switch (movetype)
    { case NORMAL     : // Move low value pieces if possible.
                        rating = (6-value) + posrate/2;  
                        break;
      case SAFE       : // Manouver better pieces to better positions.
                        rating = (value)+((8-posrate));      
                        break;
      case SAFECAPTURE: // Capture safely if possible.
                        rating = 14;                            
                        break;
      case CAPTURE    : // Take an opponents piece here if it is better than our own.
                        // Values are arbitrary.
                        tmp = (board[to[0]][to[1]]&0x07)-(value);
                        rating = (tmp < 249) ? 12 : 4;
                        break; 
      default         : rating = 0;
                        break;
    }
   return rating;
 }



VOID draw_move (LOC from, LOC to,PIECE p)
// Update the panel with a move.
 { BYTE *basemask,baserow;
   basemask = (p & 0x08) ? &bl_base_cont : &wh_base_cont;
   baserow = (p & 0x08) ? 7 : 0;

   if (piecetype(p) == KING) 
    { // King Move.
      updatekingpos(to,(p&0x08));
      panel_draw(from[0],from[1],EMPTY);
      panel_draw(to[0],to[1],p);
      board[from[0]][from[1]] = EMPTY;
      board[to[0]][to[1]] = p;
      if (((to[1] - from[1]) != 1) && ((from[1] - to[1]) != 1))
       { // Castle Move.
         if (((*basemask) & 0x1F)== 0x11)
          { panel_draw(to[0],0,EMPTY);
            panel_draw(to[0],3,((p&0x08)|ROOK));
            board[to[0]][0] = EMPTY;
            board[to[0]][3] = ((p&0x08)|ROOK);
            printf("Queenside Castle\n");
          }
        else if (((*basemask) & 0xF0) == 0x90)
          { panel_draw(to[0],7,EMPTY);
            panel_draw(to[0],5,((p&0x08)|ROOK));
            board[to[0]][7] = EMPTY;
            board[to[0]][5] = ((p&0x08)|ROOK);
            printf("Kingside Castle\n");
          }
       }
    }
   else if (((p == 0x09) && (to[0] == 0)) || ((p == 1) && (to[0] == 7)))
    {// Queening a pawn.
     panel_draw(from[0],from[1], EMPTY);
     panel_draw(to[0],to[1], QUEEN|(p&0x08)); 
     board[from[0]][from[1]] = EMPTY;
     board[to[0]][to[1]] = QUEEN |(p&0x08);
    }       
   else
    { // Normal move.
      panel_draw(from[0], from[1], EMPTY);
      panel_draw(to[0], to[1], p);

      if (board[to[0]][to[1]] != EMPTY)
         sound_capture();

      board[from[0]][from[1]] = EMPTY;
      board[to[0]][to[1]] = p;
    }

   if ((from[0] == baserow) && ((*basemask) & (1 << from[1])))
    { // Reflect any changes in the base row. After a Castle this
      // becomes superflous.
      (*basemask) &= ~(1 << from[1]);
    }
 }

VOID updatekingpos(LOC to, BOOL piececolour)
 // Update our record of the kings position.
 { if (!piececolour)
    { wh_king_pos[0] = to[0];
      wh_king_pos[1] = to[1];
    }
   else
    { bl_king_pos[0] = to[0];
      bl_king_pos[1] = to[1];
    }
 }

VOID init_board () 
 { COORD i, j;
   panel_cls();
   
   board[7][0] = board[7][7] = BLACK|ROOK;
   board[7][1] = board[7][6] = BLACK|KNIGHT;
   board[7][2] = board[7][5] = BLACK|BISHOP;
   board[7][3] = BLACK|QUEEN;
   board[7][4] = BLACK|KING;

   board[0][0] = board[0][7] = WHITE|ROOK;
   board[0][1] = board[0][6] = WHITE|KNIGHT;
   board[0][2] = board[0][5] = WHITE|BISHOP;
   board[0][3] = WHITE|QUEEN;
   board[0][4] = WHITE|KING;

   for (i=3; i<6; ++i)
      for (j=0; j<8; ++j)
         board[i][j] = 0;
      
   for (i=0; i<8; ++i)
    { board[6][i] = BLACK|PAWN;
      board[1][i] = WHITE|PAWN;
    }
   
   for (i=0; i<8; ++i)
      for (j=0; j<8; ++j)
         if (board[i][j] != EMPTY)
            panel_draw(i, j, board[i][j]);   

   // Initialise our records of the kings position
   wh_king_pos[0] = 0;
   wh_king_pos[1] = 4;
   bl_king_pos[0] = 7;
   bl_king_pos[1] = 4;  

   // Base rows fully occupied.
   wh_base_cont = bl_base_cont = 0xFF;
 }
