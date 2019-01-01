/********************************************************************/
/********************************************************************/
/*****                                                          *****/
/*****        L A B C E N T E R    E L E C T R O N I C S        *****/
/*****                                                          *****/
/*****              PROTEUS VSM TINY CHESS SAMPLE               *****/
/*****                                                          *****/
/*****                       Main Header                        *****/
/*****                                                          *****/
/********************************************************************/
/********************************************************************/
                                                                
// Constants:
#define TRUE  1
#define FALSE 0
#define ON    1
#define OFF   0
#define YES   1
#define NO    0
#define OK    0
#define ERR   -1

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

#define ZPAGE 

// System Types
typedef BYTE COORD;
typedef COORD LOC[2];
typedef BYTE PIECE;
typedef BYTE BOARD[8][8];
typedef VOID (*FUNCPTR) (LOC,BOOL);
typedef BYTE MASK[8];

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

//Play Control.
#define WH_PAWN_BASEROW 1
#define BL_PAWN_BASEROW 6
#define MAX_INDEX 63
#define MIN_INDEX 0
#define MAX_COL   7
#define MAX_ROW   7
#define MIN_COL   0
#define MIN_ROW   0

// CPU Move Types.
#define NO_MOVE     -1
#define NORMAL      1
#define SAFE        2
#define CAPTURE     3
#define SAFECAPTURE 4
#define ESCAPE      4

// Global Variables - Place in
// zero page for faster access.
extern ZPAGE BOARD board;
extern ZPAGE MASK  validmovemask;
extern ZPAGE MASK  capturemask;
//extern ZPAGE MASK  currcapturemask;
//extern ZPAGE MASK  currmovemask;
extern ZPAGE INT   movecount;
extern ZPAGE LOC   wh_king_pos;
extern ZPAGE LOC   bl_king_pos;
extern ZPAGE LOC   opp_king_pos;
extern ZPAGE BOOL  kingcapture;
extern ZPAGE BYTE  wh_base_cont;
extern ZPAGE BYTE  bl_base_cont;
extern ZPAGE BYTE  movetype;
extern ZPAGE BYTE  rate;
extern ZPAGE BYTE  piecerate;

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

// Play Control.
VOID twoplay();
VOID cpuplay();

// Piece Validation Functions. These functions set bits in our 
// board mask array indicating valid moves for the specified piece.
VOID val_empty  (LOC from, BOOL piececolour);
VOID val_pawn   (LOC from, BOOL piececolour);
VOID val_bishop (LOC from, BOOL piececolour);
VOID val_knight (LOC from, BOOL piececolour);
VOID val_rook   (LOC from, BOOL piececolour);
VOID val_queen  (LOC from, BOOL piececolour);
VOID val_king   (LOC from, BOOL piececolour);

extern FUNCPTR validate[7];

// Directional Validation functions.
VOID val_north     (LOC from,BOOL piececolour,BOOL depth);
VOID val_south     (LOC from,BOOL piececolour,BOOL depth);
VOID val_west      (LOC from,BOOL piececolour,BOOL depth);
VOID val_east      (LOC from,BOOL piececolour,BOOL depth);
VOID val_northwest (LOC from,BOOL piececolour,BOOL depth);
VOID val_northeast (LOC from,BOOL piececolour,BOOL depth);
VOID val_southwest (LOC from,BOOL piececolour,BOOL depth);
VOID val_southeast (LOC from,BOOL piececolour,BOOL depth);

//Utility.
VOID updatekingpos(LOC to, BOOL piececolour);
INT  getbestpiecemove(LOC from);
BOOL test_singlemove (LOC from,LOC to,PIECE p);
INT rate_move(PIECE piece,LOC to, BYTE posrate);
VOID draw_move(LOC from, LOC to,PIECE p);
VOID init_board ();

// Touch Panel Interface
VOID panel_init (VOID);
VOID panel_cls  (VOID);
VOID panel_draw (COORD row, COORD col, PIECE p);
BOOL panel_getmove (LOC from, LOC to);

// Mid level (not called directly)
VOID panel_blit (COORD row, COORD col, const BYTE *sprite);
VOID panel_invert (LOC loc, BYTE flag);

// Sound Effects Interface
VOID sound_yourmove ();
VOID sound_mymove ();
VOID sound_illegal ();
VOID sound_capture();
VOID sound_youwin();
VOID sound_iwin();

VOID sound_tone (WORD period, WORD cycles);
                                                           
