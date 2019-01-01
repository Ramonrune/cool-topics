/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****              PROTEUS VSM TINY CHESS SAMPLE               *****/
/*****                                                          *****/
/*****                Move Validation Control                   *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/

#include "chess.h"


/************************************************************************
***** Piece Validation Functions *****
**************************************/

VOID val_empty(LOC from,BOOL piececolour)
 {// Do nothing...
  from = from;
  piececolour = piececolour;
 }


VOID val_pawn(LOC from,BOOL piececolour)
// Find all Valid moves for a pawn.
 { COORD row = from[0],col = from[1];
   BOOL piecefound = FALSE;
 
  // Get the opponents king position.
  if (piececolour == WHITE)
   { opp_king_pos[0] = bl_king_pos[0];
     opp_king_pos[1] = bl_king_pos[1];
   }
  else
   { opp_king_pos[0] = wh_king_pos[0];
     opp_king_pos[1] = wh_king_pos[1];
   }
   
   // Increment the row towards the opponents pieces. 
   if (piececolour == WHITE)
      row++;
   else
      row--;

   // We can move into an empty square directly in front of us.
   if (board[row][col] == EMPTY)
    { validmovemask[row] |= (1<<col);
    }
   else
    piecefound = TRUE;


   // We can diagonally take an opponents piece.
   if ((is_opp_piece(row,col-1,piececolour)) && (col > MIN_COL))
     { //left
        validmovemask[row] |= (1<<(col - 1));
        capturemask[row]   |= (1<<(col - 1));
        if (capturemask[opp_king_pos[0]]  & (1 << opp_king_pos[1])) kingcapture = TRUE;
     }

   if ((is_opp_piece(row,col+1,piececolour)) && (col < MAX_COL))
     { //right
        validmovemask[row] |= (1<<(col + 1));
        capturemask[row]   |= (1<<(col + 1));
        if (capturemask[opp_king_pos[0]]  & (1 << opp_king_pos[1])) kingcapture = TRUE;
     }

   // If a pawn is on it's base row it can move two squares.
   if ((piececolour == BLACK  && from[0] == BL_PAWN_BASEROW) || (piececolour == WHITE && from[0] == WH_PAWN_BASEROW))
     {  if (piececolour == WHITE)
           row++;
        else
           row--;
        if ((board[row][col] == EMPTY) && (piecefound ==FALSE))
         { validmovemask[row] |= (1<<col);
         }
     }

 }


VOID val_bishop(LOC from,BOOL piececolour)
// Find all valid moves for a bishop. We look at
// all 4 directions and travel until either the 
// edge of the board or until a piece is encountered.
 { 
   // Get the opponents king position.
   if (piececolour == WHITE)
    { opp_king_pos[0] = bl_king_pos[0];
      opp_king_pos[1] = bl_king_pos[1];
    }
   else
    { opp_king_pos[0] = wh_king_pos[0];
      opp_king_pos[1] = wh_king_pos[1];
    }

   // Check Valid Moves.
   val_northeast (from,piececolour,-1);
   val_northwest (from,piececolour,-1);
   val_southeast (from,piececolour,-1);
   val_southwest (from,piececolour,-1);
 }

VOID val_knight(LOC from,BOOL piececolour)
// Find all valid moves for a knight.We use a mask byte
// to flag available rows and columns.
//  |    0    |     1    |    2    |    3     |     4    |     5    |      6    |     7     |
//  | +1r_up  |  +2r_up  | +1r_dwn |  +2r_dwn | +1col_lft| +2col_lft| +1col_rgt | +2col_rgt |
 { BYTE mask = 0,i = 0;
   COORD row = 0,col = 0;

   // Set up row and column offsets for the various knight moves. All moves are initialised to zero.
   INT move[] = {0, 2, 1, 0, 2, -1, 0, 1, 2, 0, 1, -2, 0, -1, 2, 0, -1, -2, 0, -2, -1, 0, -2, 1};
 
   // Get the opponents king position.
   if (piececolour == WHITE)
    { opp_king_pos[0] = bl_king_pos[0];
      opp_king_pos[1] = bl_king_pos[1];
    }
   else
    { opp_king_pos[0] = wh_king_pos[0];
      opp_king_pos[1] = wh_king_pos[1];
    }

   // Set Bits to indicate how many rows we can move up or down.
   switch (from[0])
    { case 0 : mask |=  0x03;   break; // Two up  - None down.
      case 1 : mask |=  0x07;   break; // Two up  - One down.
      case 6 : mask |=  0x0D;   break; // One up  - Two down.
      case 7 : mask |=  0x0C;   break; // None up - Two down.
      case 2 :
      case 3 :
      case 4 :
      case 5 : mask |=  0x0F;   break; // Two up  - Two down.
    }

   // Set Bits to indicate how many columns we can move left or right.
   switch (from[1])
    { case 0 : mask |=  0xC0;   break; // None left - Two right.
      case 1 : mask |=  0xD0;   break; // One left  - Two right.
      case 6 : mask |=  0x70;   break; // Two left  - One right.
      case 7 : mask |=  0x30;   break; // Two left  - None right.
      case 2 :
      case 3 :
      case 4 :
      case 5 : mask |=  0xF0;   break; // Two left  - Two right.
    }

   // Define Boolean tests for each possible knight move.
   #define up2_rgt1  ((mask & 0x40) && (mask & 0x02))
   #define up2_lft1  ((mask & 0x10) && (mask & 0x02))
   #define up1_rgt2  ((mask & 0x80) && (mask & 0x01))
   #define up1_lft2  ((mask & 0x20) && (mask & 0x01))
   #define dwn1_rgt2 ((mask & 0x80) && (mask & 0x04))
   #define dwn1_lft2 ((mask & 0x20) && (mask & 0x04))
   #define dwn2_lft1 ((mask & 0x10) && (mask & 0x08))
   #define dwn2_rgt1 ((mask & 0x40) && (mask & 0x08))

   // Set Valid moves in our array.  
   move[0]  = up2_rgt1;
   move[3]  = up2_lft1;
   move[6]  = up1_rgt2;
   move[9]  = up1_lft2;
   move[12] = dwn1_rgt2;
   move[15] = dwn1_lft2;
   move[18] = dwn2_lft1;
   move[21] = dwn2_rgt1;
  
   // Deal with all the possibles.
   for (i = 0; i <= 21; i += 3)
    { if (move[i])
       { // Valid Move.
         row = (from[0] + move[i+1]);
         col = (from[1] + move[i+2]);
         if (board[row][col] == EMPTY)
          { // Empty Square.
            validmovemask[row] |= (1<<col);
          }
         else if (is_opp_piece(row,col,piececolour))
          { // Opponents Piece.
            validmovemask[row] |= (1<<col);
            capturemask[row]   |= (1<<col);
            if (capturemask[opp_king_pos[0]] & (1 << opp_king_pos[1])) kingcapture = TRUE;
          }
       }
    }
  }

VOID val_rook(LOC from,BOOL piececolour)
// Get all valid moves for a rook. We look
// at all 4 possible directions and extend until 
// a piece is encountered. 
 { // Get the opponents king position.
   if (piececolour == WHITE)
    { opp_king_pos[0] = bl_king_pos[0];
      opp_king_pos[1] = bl_king_pos[1];
    }
   else
    { opp_king_pos[0] = wh_king_pos[0];
      opp_king_pos[1] = wh_king_pos[1];
    }

   // Get all valid Moves.
   val_north (from,piececolour,-1);
   val_south (from,piececolour,-1);
   val_east  (from,piececolour,-1);
   val_west  (from,piececolour,-1);
 }

VOID val_queen(LOC from,BOOL piececolour)
// Calculate all valid moves for a queen.
// The Queen is in effect a rook and a bishop
// combined so all that is necessary here is to
// call all the directional validation functions.
 {
   // Get the opponents king position.
   if (piececolour == WHITE)
    { opp_king_pos[0] = bl_king_pos[0];
      opp_king_pos[1] = bl_king_pos[1];
    }
   else
    { opp_king_pos[0] = wh_king_pos[0];
      opp_king_pos[1] = wh_king_pos[1];
    }

   // Get all Valid Moves.
   val_north      (from,piececolour,-1);
   val_south      (from,piececolour,-1);
   val_east       (from,piececolour,-1);
   val_west       (from,piececolour,-1);
   val_northeast  (from,piececolour,-1);
   val_northwest  (from,piececolour,-1);
   val_southeast  (from,piececolour,-1);
   val_southwest  (from,piececolour,-1);
 }

VOID val_king(LOC from,BOOL piececolour)
// Calculate the possible valid moves for a King.
 { BYTE tmp,row;
   
   // Get the opponents king position.
   if (piececolour == WHITE)
    { opp_king_pos[0] = bl_king_pos[0];
      opp_king_pos[1] = bl_king_pos[1];
    }
   else
    { opp_king_pos[0] = wh_king_pos[0];
      opp_king_pos[1] = wh_king_pos[1];
    }
   
   // King can move in any direction but
   // only by 1 square. 
   val_north      (from,piececolour,1);
   val_south      (from,piececolour,1);
   val_east       (from,piececolour,1);
   val_west       (from,piececolour,1);
   val_northeast  (from,piececolour,1);
   val_northwest  (from,piececolour,1);
   val_southeast  (from,piececolour,1);
   val_southwest  (from,piececolour,1);

   // King Castle.
   if (piececolour & 0x08) 
    { tmp = bl_base_cont;
      row = MAX_ROW;
    }
   else
    { tmp = wh_base_cont;
      row = MIN_ROW;
    }

   if ((tmp & 0x1F)== 0x11)
    { // Can Castle QueenSide.
      validmovemask[row] |= 0x04;
    }   

   if ((tmp & 0xF0)==0x90) 
    {// Can Castle KingSide.
      validmovemask[row] |= 0x40;
    }
 }


/************************************************************************
***** Directional Validation Functions *****
*******************************************/

VOID val_north (LOC from,BOOL piececolour,BOOL depth)
// Validate Squares directly above the current position.
 { COORD row = from[0],col = from[1];
   BOOL piecefound = FALSE;
   while ((row++ < MAX_ROW) && (!piecefound) && (depth--))
    { if (board[row][col] == EMPTY)
       { // Empty Square.
         validmovemask[row] |= (1<<col);
       }
      else if (is_opp_piece(row,col,piececolour))
       { // Opponents Piece.
         validmovemask[row] |= (1<<col);
         capturemask[row]   |= (1<<col);
         if (capturemask[opp_king_pos[0]]  & (1 << opp_king_pos[1])) kingcapture = TRUE;
         piecefound = TRUE;
       }
      else
       { //Our Piece.
         piecefound = TRUE;
       }
    }
 }

VOID val_south (LOC from,BOOL piececolour,BOOL depth)
 { // Validate directly down from the current location.
   CHAR row = from[0], col = from[1];
   BOOL piecefound = FALSE;
   while ((row-- > MIN_ROW) && (!piecefound) && (depth--))
    { if (board[row][col] == EMPTY)
       { // Empty Square.
         validmovemask[row] |= (1<<col);
       }
      else if (is_opp_piece(row,col,piececolour))
       { // Opponents Piece.
         validmovemask[row] |= (1<<col);
         capturemask[row]   |= (1<<col);
         if (capturemask[opp_king_pos[0]]  & (1 << opp_king_pos[1])) kingcapture = TRUE;
         piecefound = TRUE;
       }
      else
       { //Our Piece.
         piecefound = TRUE;
       }
    }
 }

VOID val_east (LOC from,BOOL piececolour,BOOL depth)
 { // Validate directly to the right of the current location.
   COORD row = from[0],col = from[1];
   BOOL piecefound = FALSE;
   while ((col++ < MAX_COL) && (!piecefound) && (depth--))
    { if (board[row][col] == EMPTY)
       { // Empty Square.
         validmovemask[row] |= (1<<col);
       }
      else if (is_opp_piece(row,col,piececolour))
       { // Opponents Piece.
         validmovemask[row] |= (1<<col);
         capturemask[row]   |= (1<<col);
         if (capturemask[opp_king_pos[0]]  & (1 << opp_king_pos[1])) kingcapture = TRUE;
         piecefound = TRUE;
       }
      else
       { //Our Piece.
         piecefound = TRUE;
       }
    }
 }

VOID val_west (LOC from,BOOL piececolour,BOOL depth)
 { // Validate directly to the left of the current location.
   CHAR row = from[0],col = from[1];
   BOOL piecefound = FALSE;
   while ((col-- > MIN_COL) && (!piecefound) && (depth--))
    { if (board[row][col] == EMPTY)
       { // Empty Square.
         validmovemask[row] |= (1<<col);
       }
      else if (is_opp_piece(row,col,piececolour))
       { // Opponents Piece.
         validmovemask[row] |= (1<<col);
         capturemask[row]   |= (1<<col);
         if (capturemask[opp_king_pos[0]]  & (1 << opp_king_pos[1])) kingcapture = TRUE;
         piecefound = TRUE;
       }
      else
       { //Our Piece.
         piecefound = TRUE;
       }
    }
 }

VOID val_northwest (LOC from,BOOL piececolour,BOOL depth)
 { // Validate diagonally left and up from the current location.
   // This corresponds to an index increment of 7.
   COORD row = from[0], col = from[1];
   BOOL piecefound = FALSE;
   while ((col-- > MIN_COL) && (row++ < MAX_ROW) && (!piecefound) &&  (depth--))
    { // We haven't found a piece, are still in scope and within search depth.
      if (board[row][col] == EMPTY)
       {// Empty Square.
        validmovemask[row] |= (1<<col);
       }
      else if ((board[row][col] & 0x08) ^ piececolour)
       {// Opponents Piece.
        validmovemask[row] |= (1<<col);
        capturemask[row]   |= (1<<col);
        if (capturemask[opp_king_pos[0]]  & (1 << opp_king_pos[1])) kingcapture = TRUE;
        piecefound = TRUE;
       }
      else
       {// Our Piece.
         piecefound = TRUE;
       }
    }
 }

VOID val_northeast(LOC from,BOOL piececolour,BOOL depth)
 { // Validate diagonally right and up from the current location.
   // This corresponds to an index increment of 9;
   COORD row = from[0], col = from[1];
   BOOL piecefound = FALSE;
   while ((col++ < MAX_COL) && (row++ < MAX_ROW) && (!piecefound) && (depth--))
    { // We haven't found a piece, are still in scope and within search depth.
      if (board[row][col] == EMPTY)
       {// Empty Square.
        validmovemask[row] |= (1<<col);
       }
      else if ((board[row][col] & 0x08) ^ piececolour)
       {// Opponents Piece.
        validmovemask[row] |= (1<<col);
        capturemask[row]   |= (1<<col);
        if (capturemask[opp_king_pos[0]]  & (1 << opp_king_pos[1])) kingcapture = TRUE;
        piecefound = TRUE;
       }
      else
       {// Our Piece.
         piecefound = TRUE;
       }
    }
 }

VOID val_southeast (LOC from,BOOL piececolour,BOOL depth)
 { // Validate diagonally right and down from the current location.
   // This translates as an index decrement of 7.
   COORD row = from[0], col = from[1];
   BOOL piecefound = FALSE;
   while ((col++ < MAX_COL) && (row-- > MIN_ROW) && (!piecefound) && (depth--))
    { // We haven't found a piece, are still in scope and within search depth.
      if (board[row][col] == EMPTY)
       {// Empty Square.
        validmovemask[row] |= (1<<col);
       }
      else if ((board[row][col] & 0x08) ^ piececolour)
       {// Opponents Piece.
        validmovemask[row] |= (1<<col);
        capturemask[row]   |= (1<<col);
        if (capturemask[opp_king_pos[0]]  & (1 << opp_king_pos[1])) kingcapture = TRUE;
        piecefound = TRUE;
       }
      else
       {// Our Piece.
         piecefound = TRUE;
       }
    }
 }

VOID val_southwest(LOC from,BOOL piececolour,BOOL depth)
 {// Validate Left and Down from the current location.
   // This corresponds to an index subtraction of 9.
   COORD row = from[0], col = from[1];
   BOOL piecefound = FALSE;
   while ((col-- > MIN_COL) && (row-- > MIN_ROW) && (!piecefound) && (depth--))
    {  // We haven't found a piece, are still in scope and within search depth.
      if (board[row][col] == EMPTY)
       {// Empty Square.
        validmovemask[row] |= (1<<col);
       }
      else if ((board[row][col] & 0x08) ^ piececolour)
       {// Opponents Piece.
        validmovemask[row] |= (1<<col);
        capturemask[row]   |= (1<<col);
        if (capturemask[opp_king_pos[0]]  & (1 << opp_king_pos[1])) kingcapture = TRUE;
        piecefound = TRUE;
       }
      else
       {// Our Piece.
         piecefound = TRUE;
       }
    }
 }

