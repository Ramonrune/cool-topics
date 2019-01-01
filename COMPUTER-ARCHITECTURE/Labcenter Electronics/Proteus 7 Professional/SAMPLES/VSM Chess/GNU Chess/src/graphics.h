/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****               PROTEUS VSM GNU CHESS SAMPLE               *****/
/*****                                                          *****/
/*****                       Main Header                        *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/
                                                                
// Portability types:
#define VOID void
typedef float FLOAT;
typedef double DOUBLE;
typedef char CHAR;
typedef short SHORT;
typedef int INT;
typedef int BOOL;
typedef unsigned long FLAG;
typedef unsigned long LWORD;
typedef unsigned long DWORD;
typedef unsigned UINT;
typedef long LONG;
typedef unsigned char BYTE;
typedef unsigned short WORD;

// System Types
typedef BYTE COORD;
typedef COORD LOC[2];
typedef BYTE PIECE;
typedef BYTE BOARD[8][8];
typedef VOID (*FUNCPTR) (LOC,BOOL);
typedef BYTE MASK[8];

// Booleans
#define TRUE   1
#define FALSE  0

// Codes for chess piece tokens
#define EMPTY   0
#define PAWN    1
#define ROOK    2
#define KNIGHT  3
#define BISHOP  4
#define QUEEN   5
#define KING    6
#define WHITE   0
#define BLACK   8

// Codes for function buttons
#define BTN_NEW  0x01
#define BTN_SAVE 0x02
#define BTN_LOAD 0x04
#define BTN_GO   0x08
#define BTN_ALL  0x0F

// Translate coords into 0-based index.
#define getindex(r,c) (r * 8) + c;     
// Translate index into coords.      
#define getcoord(r,c,i) r = i/8; c = i%8; 
// Determine the type of piece.
#define piecetype(p) (p & 0x07)
//Boolean - True if piece is opponents, false if not.
#define is_opp_piece(r,c,p) ((((board[r][c] & 0x08) >> 3) ^ ((p & 0x08) >> 3)) && (board[r][c]))
//Boolean - True if move is valid, false if not.
#define is_valid_move(r,c) (validmovemask[r] & (1 << c))


// Touch Panel Interface
VOID panel_init (VOID);
VOID panel_cls  (VOID);
VOID panel_update (COORD row, COORD col, PIECE p);
BOOL panel_getmove (INT colour, LOC from, LOC to);
WORD panel_pollbtns();
BOOL panel_polltty();
BOOL panel_save();
BOOL panel_load();
CHAR *panel_getEPD ();

// Mid level (not called directly)
VOID panel_draw (COORD row, COORD col, PIECE p);
VOID panel_blit (COORD row, COORD col, const BYTE *sprite);
VOID panel_invert (LOC loc, BOOL flag);

// Sound Effects Interface
VOID sound_yourmove ();
VOID sound_mymove ();
VOID sound_illegal ();
VOID sound_capture();
VOID sound_youwin();
VOID sound_iwin();

VOID sound_tone (WORD period, WORD cycles);
