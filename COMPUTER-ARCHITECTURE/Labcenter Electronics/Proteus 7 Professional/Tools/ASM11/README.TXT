                        INSTRUCTIONS FOR ASM11
           Copyright (c) 1998-1999 by Tony G. Papadimitriou, M.S.
                        e-mail: tonyp@acm.org

Hi 68HC11 enthusiasts,

PLEASE TAKE THE TIME TO READ THE ENTIRE DOCUMENT (SPECIALLY IF THIS THE FIRST
TIME YOU USE THIS PROGRAM).  THIS WILL HELP YOU AVOID UNNECESSARY
HEAD-SCRATCHING FOR WHAT'S ALREADY DOCUMENTED.

This archive should contain the files listed in the file CRC

To extract the files from this archive, you should open with the "Create 
Directories" option for whatever archiver you use, (eg., UNZIP -D 
ASM11_xx.ZIP)

This README.TXT file is not intended to be an assembly language manual or
tutorial.  It assumes the user knows how to program in 68HC11 assembly or has
the desire to learn and has relevant literature to consult.  If you are not
familiar with 68HC11 you should get a 68HC11 Assembly Language Reference,
some of them are free, if you know where to look (hint: start with Motorola).

If you are converting your source from some other assembler, please read the
relevant section in this file.  It will save you time.

To most experienced 68HC11 users, a lot of the information in this document
may seem obvious and unnecessary to be mentioned.  I have to take into
account that some potential users are new to 68HC11 and assembly language
programming in general, so I've tried to make it a bit more comfortable for
them.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ABOUT THE SOURCE CODE EXAMPLE FILES INCLUDED (in the subdirectory SAMPLES)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Several assembly language source files are included. All example programs are
only meant to illustrate acceptable assembly language syntax for ASM11 more
than to provide accurate working programs.  These programs, although carefully
reviewed, may contain errors, or not do exactly what they claim to do.  They
only provide examples for you to work with.  I believe they are correct, but
some bugs may exist in them so please take the time to verify their
correctness yourself (ie., don't use them blindly).

FRAME.ASM and the *.MOD file in the OS11 directory are a set of files that 
provide a framework for actual programs.  All OS11 modules are fully
functional and ready to use in your program.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ABOUT THE EXTRA UTILITIES INCLUDED (in the subdirectory UTILS)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

M.EXE There is an extra utility included in this archive, M.EXE (a MORE type 
  program).  This is a utility for viewing text files.  Type M on the command
  line by itself to get a comprehensive help screen.  You may use this utility
  to view listings, source files, etc.  It will adjust to any screen display,
  whether you're working at 40, 80, or 132 column widths.  (In case you didn't
  know, most systems support wider than 80-column displays -- even under DOS,
  which for one thing makes it easy to view assembler listings in all their
  beauty without printing them out.)

  Another function of this utility is that it will act as a Unix-to-PC file 
  converter.  The assembler expects regular DOS text files and it will not
  correctly read files that aren't such, eg., files that do not end with CR/LF
  or simply a CR.  Please note that assembling such files does not always
  produce errors or warnings because if, for example, there is a CTRL-Z
  (end-of-file) character, the assembler will stop reading the source file
  assuming its the end of it.  Also, files having only LF as end-of-line
  marker will only have their first line processed, and in most cases this
  will not give any errors, since usually the first line is either a comment
  or some equate.  This may give you the impression you source has assembled
  correctly when in reality, only a portion of it has and it simply happened
  not to produce errors.  One way to quickly check for such problems is to
  look at the line number counter at the end of the assembly.

  If you still have problems, there may be nulls (ASCII 0) or other strange 
  control characters left in the file.  You could try clearing those away by
  loading the file into an ASCII editor, and re-saving it.  Not all ASCII
  editors will do that, though.

  Yet another function of M.EXE is to de-tab a file, ie., expand its tabs.  
  Although ASM11 can use the -Tn option or the $TABSIZE directive to control
  tab expansion of the source file, you may wish to convert someone else's
  source to a no-tabs text if you don't normally save your sources in tabbed
  form.  You set the -Xn option to whatever tab size the original is using,
  then redirect the output to the new file, eg.,

                    M -X10 TABBED.ASM >UNTABBED.ASM

  will create the file UNTABBED.ASM by expanding possible tabs inside 
  TABBED.ASM and using a tab size of 10.  What tab size to use is not easy to
  tell.  Normally, most editors use a default value of 8, but they also allow
  changing this value to any number.  Before converting, try viewing the file
  with different -Xn settings until you see instruction, operands, and
  comments align properly (although that's not always the case).

  Note, however, that M.EXE wraps lines at the width of the current video 
  mode, so if run from an 80-column display, everything beyond column 80 will
  be placed on a new line.  This may require some further editing to bring
  wrapped lines back up to the line they belong.  You can limit the wrapped
  line problems by running M from a 132-column display.

TERM.EXE One other extra utility included is TERM.EXE (a very basic terminal 
  program).  Type TERM -? to get a comprehensive help screen.  Set the options
  (such as COM port, BAUD, etc.) that apply to your setup, then save them with
  the -W option inside the TERM.EXE file so it will remember them.  TERM is
  not only meant for use with evaluation boards (actually it was written for
  remotely controlling a DOS PC using DOORWAY), but this is the reason for
  being included here.

  Once configured, typing TERM brings up a screen that let's you talk to an
  EVBU, EVM, EVS, or custom SCI-enabled 68HC11 system.  You can use the PgUp
  key on your keyboard to give the filename of an S19 file to upload to your
  system.  If the -E option is on, PgUp does not require having typed the
  "LOAD T" command beforehand.  If the -E option is off, you must type LOAD T
  in advance.  Although not tested with every system, it should work on all
  evaluation boards that accept the BUFFALO command LOAD T to load an S19
  file.  It has been tested on an EVBU and an EVS.  You may exit the terminal
  mode by pressing the SysRq key (usually CTRL-PrintScreen, laptops may
  require a different sequence).

  There are some reports that when the -E option is enabled the upload won't 
  work.  This is very likely a problem with delayed responses from the LOAD T
  to the beginning of the upload (I'll look into it, not so easy to fix when I
  can't reproduce the problem in my system).  Play with the -Ln option using
  different delay values, you should be able to make it work eventually.  If
  you keep having problems like this, turn off the -E switch and manually type
  the LOAD T command before commencing the upload.  It should work at speeds
  upto 9600; you may encounter problems at higher speeds as the MCU itself
  (running at 2MHz) isn't ready to read another line and gets out of sync.
  This will also depend to a certain extent on the length of your S19 records
  (longer ones are more likely to cause errors) and the coding of the loader
  itself.

SB2ASM11.EXE This utility is a "quick and *very* dirty" program to make SBasic 
  produced assembler programs ASM11 compatible.  It does not do any syntax
  checking, so it could make mistakes.  What it does, actually, is change all
  occurences of -*- to -$- in every line (wherever they may be found, even
  inside comments).  It also changes " incl " to " $include " in every line 
  (wherever they may be found, even inside comments).  I have found these two 
  changes to get all sample programs that come with SBasic compatible to 
  ASM11.  If you find more changes are needed, let me know so I can upgrade it
  accordingly.

  To use SB2ASM11, first compile your SBasic code to an .SBA (SBasic Asm) 
  file, using a command similar to:

                         SBASIC MYPROG.BAS >MYPROG.SBA

  Then, use SB2ASM11 to make it ASM11 compatible.  SB2ASM11 accepts the same 
  file parsing as ASM11, so you could type SB2ASM11 . to convert all .SBA
  files to .ASM files.  Note, that since this is a simple utility, I haven't
  taken the time to add luxuries such as options, etc.  So, input files should 
  always be with the extension .SBA and output files will always have the 
  extension .ASM (ASM11's default).  Perhaps you could write a small filter 
  yourself that is more efficient, does a better job, and allows something 
  like:

                      SBASIC MYPROG.BAS | filter >MYPROG.ASM

G.EXE is a general-purpose utility that allows one to execute a command-line 
  DOS program using the same wildcard system used by ASM11, however, without
  the default assembler extension that is special to ASM11.  Typing G by
  itself will give a short but comprehensive help screen. See the included
  KILL.BAT for an example batch file that will remove all ASM11 produced files
  from the current directory (and subdirectories if the -S option is used).

KILL.BAT example batch file for removing all ASM11 produced files.  Useful to 
  clean up your directories.  It uses the G.EXE utility which must be located
  somewhere in the path.

BSORT.EXE A general purpose ASCII file sorting program.  It can be used to
  sort the simple *.SYM files (-LS+ -LSS options) by name (with BSORT .SYM) or
  by value (BSORT .SYM -22).  Another use is for sorting S19 files with the
  command: "BSORT .S19 -1:2;5"

EXBIN.EXE lets you convert S19 files to binary.  It will simply convert an S19 
  file to an equivalent binary image.  EXBIN allows you to also give a 
  fill-value for unused bytes that are within various code/data sections.  The 
  default is $FF which is the erased state of E(E)PROM for the 68HC11.  The 
  image will contain all bytes from the first to the last bytes used (filling 
  missing bytes with the fill-value).  The current version does not need a 
  pre-sorted S19 file, it automatically sorts the file internally while 
  reading it without altering the actual file.  It also fixes a small bug that 
  caused to create wrong size fills in certain cases.  It is now believed to 
  be 100% correct.

To get updated versions of any of the accompanying little utilities visit:

               ftp://www.aspisys.com/public/freeware/

This is also a good place to check for updates to ASM11 (if you have received
your copy from a different source).  Look for filenames in the format
ASM11_xx.ZIP where xx is a number; higher numbers indicate newer versions.

(I cannot be certain for the continuous service of this site, it's likely to
be on and off.  If you believe there is a newer version available and can't
get an update anywhere else, write to me directly at <tonyp@acm.org> and I'll
send you the file by e-mail attachment.)

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FEATURES AND (FEW) LIMITATIONS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş Two-pass DOS based command-line 68HC11 cross-assembler.  You may also run
    the program from within a Windows DOS box, or have your favorite IDE (DOS
    or Windows) call it automatically at the press of a key.

  ş To get a full-screen of help simply type ASM11 without any filename
    specifications.  This screen also displays the default (saved) settings
    for each option.  Only a couple or so of the less important options are
    not shown due to space limitations.

The following is ASM11's help screen (displayed when you type ASM11 <ENTER>).
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ASM11 v1.84 ş Copyright (c) 1999 Tony Papadimitriou <tonyp@acm.org> *FREEWARE*
Usage: ASM11 [options] [@][path][/][mask][[,mask]...] [options] [> errfile]
       MC68HC11 two-pass cross-assembler for DOS-based systems
   ş Extra mnemonics         ³Equivalent [series of] instructions
     LDA/STA/LDB/STB/ORA/ORB ³LDAA/STAA/LDAB/STAB/ORAA/ORAB
     PSHD/PULD/CMPD/CMPX/CMPY³PSHB,PSHA/PULA,PULB/CPD/CPX/CPY
     CLRD/CLRX/CLRY/INCD/DECD³CLRA,CLRB/LDX #0/LDY #0/ADDD #1/SUBD #1
     COMD/NEGD/XGAB/ROLD/RORD³COMA,COMB/+INCD/PSHA,TBA,PULB/ROLB,ROLA/RORA,RORB
     CLS/CLX                 ³PSHA,TPA,ANDA #$7F/#$BF,TAP,PULA (Clear S/X flag)
     SES/XGXY/GETX Y/GIVEX Y ³PSHA,TPA,ORAA #$80,TAP,PULA/XGDX,XGDY,XGDX/docs
     WAIT/OS(W)/LBRA/LBSR/Jxx³CLI, WAI/SWI, DB(DW) x/see docs
   ş $IFDEF IFZ ELSE ENDIF IF e1 [=,<>,<,>,>=,<=] e2 IFEXISTS IFMAIN IFINCLUDED
     #INCLUDE LISTx WARNING ERROR FATAL S19FLUSH CASEx EXTRAx MAPx (x=ON/OFF)
     $MEMORY PUSH PULL MESSAGE OPTRELx OPTRTSx SPACESx ³ Seg: RAM/ROM/DATA/SEGn
   ş Modes: #IMM @DIR <DIR >EXT AUTO ,X ,Y INDEXED ³ String delimiters ' " `
   ş Operators: + - * / \mod >shr <shl &and |or ^xor ~swap [lobyte ]hibyte
   ş  -Ix   Set default INCLUDE directory (eg. -Ie:/asm/includes)
   -  -C[ñ] Case sensitive labels³ -Tn Tab columns   :   8³ -T[ñ] TP Error: NO
   -  -E[ñ] create *.ERR file(s) ³ -EH[ñ] Error Hide : YES³ -P[ñ] P1 Stop : YES
   +  -L[ñ] create *.LST file(s) ³ -LS[ñ] SYM file(s): NO ³ -LSx SYM Type : [S]
   +  -M[ñ] create *.MAP file(s) ³ -MTx MapType(x=P,A) [P]³ -O[ñ] Over/Mem: YES
  74  -Rn set n max S19 rec size ³ -R.ext default ext: ASM³ -Q[ñ] Quiet > : NO
   +  -S[ñ] create *.S19 file(s) ³ -SH[ñ] S0 header  : NO ³ -SP[ñ] Spaces : NO
   +  -X[ñ] allow eXtra mnemonics³ -W Write options in EXE³ -WRN[ñ] Warn  : YES
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş Assembles many files in a single command using wildcards or list files.
    Examples:

    Command              Files to be matched
    ÍÍÍÍÍÍÍ              ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
    ASM11 .              *.ASM
    ASM11 ,              *.ASM
    ASM11 .A11           *.A11 (Any extension may be specified except for
                               those used for files created by ASM11, ie.,
                               S19, LST, MAP, ERR, and SYM.  I hope you won't
                               find this too much of a restriction.)
    ASM11 *.S19          None  (S19 is used by ASM11 as object code output
                               and cannot be used for source programs.  ASM11
                               will ignore the invalid extension and skip
                               over the file(s).)
    ASM11 OS,TEST*       OS.ASM and any file matching TEST*.* in the order
                         they are found in the directory.  The default
                         extension applies only to the first file in a comma
                         delimited list.  The second (and following) file(s)
                         assume any allowed extension.  Use space-delimited
                         list to apply the default extension to all files, or
                         specify the extension mask as well.
    ASM11 /              \*.ASM
    ASM11 /temp          \TEMP.ASM
    ASM11 /temp/,?       \TEMP\*.ASM and any files matching ?.*
    ASM11 file1 file2    FILE1.ASM and FILE2.ASM in the order specified
    ASM11 .,.a11         *.ASM and *.A11 files in the current directory
    ASM11 ,.a11          -//- (note the missing dot)

    ASM11 @FILELIST      all files that match each wildcard spec inside
                         FILELIST.  If FILELIST contains the lines:
                              SAMPLE,DEMO
                              /PROJECT/
                              /PUBLIC/.A11
                         then files that match:
                              SAMPLE.ASM
                              DEMO.*
                              \PROJECT\*.ASM
                              \PUBLIC\*.A11
                         will be assembled

  NOTE: You may change the default extension from .ASM to some other of your
        liking.  See the -R.ext option later in this document.  The above
        examples assume you haven't changed the default .ASM extension.  Both
        forward and backward slashes may be used wherever you specify
        filenames (even inside the source code).

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
COMMAND-LINE OPTIONS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş Options are single- or multi- letter, always begin with a - and may be
    placed anywhere on the command line.  They may not be merged together, so
    to specify, say, options S and M, you must type -S -M but not -SM.

    Most options (those having an ON/OFF state) may be followed by a + or - 
    sign to indicate that the option is to be turned on or off, respectively.  
    Such options without the trailing sign will toggle the current (saved 
    default) switch state.  To see the default switch settings, run ASM11 
    without any arguments.  You will get a help screen along with the active 
    switch settings.  If, however, you supply a switch but no filename mask 
    (eg., ASM11 -X-), you will see the settings after this switch has been 
    processed (ie., not necessarily the saved default).  This is useful to 
    verify the options before either assembling or using the -W command.

    The same switches may appear on the command line as many times as you
    like.  Toggles will apply each time a switch without a + or - is
    encountered.  If you use + and - signs, the last one processed will be
    effective.  This allows to make batch files with some default options
    which can be changed for single runs.  Example batch:

          @ECHO OFF
          ASM11 -S+ -M+ -L- -LS- %1 %2 %3 %4 %5 %6 %7 %8 %9

    Also, take a look at the included ASM.BAT in the UTILS.ZIP archive.

    All options (regardless of their position with respect to supplied
    filenames) will be processed before filename parsing begins.  This means,
    you cannot use something like:

                         ASM11 -S- FILE1 -S+ FILE2

    expecting to assemble FILE1.ASM with no *.S19 and FILE2.ASM with *.S19.  
    Since the last option sets S19 production on, both files will produce 
    *.S19 files (on successful compilation).  This principle applies to all
    options.

    The -W option (actually a command) does not expect a + or - after it.  It 
    is used to Write (save) the state of all options appearing before it on 
    the command line inside the ASM11.EXE file.  I never liked separate 
    configuration files for such trivial things that get lost when copying 
    the program from one location to another.  For example, ASM11 -S+ -M- -W 
    -L+ will make default the production of *.S19 files and the omission of
    *.MAP files while leaving the L option unchanged because it follows -W.
    You will get a message saying that the configuration was saved (or not,
    if there was some error, normally, a disk-write or disk-protected error).
    Make sure the file's attributes allow writing to it (no read-only flags).
    Once you save your new defaults you may wish to protect ASM11 from
    accidental modifications by setting its Read-Only attribute with the DOS
    command ATTRIB +R ASM11.EXE No assembly will take place when the -W
    command is used.

    * ALL OPTIONS (EVEN THOSE NOT SHOWN IN THE HELP SCREEN) EXCEPT FOR THE
              -D OPTION (TO DEFINE SYMBOLS) AND -W ARE SAVEABLE *

  NOTE: If you use the -W option even once, the ASM11.EXE file will grow in
        size just by a few bytes (only the very first time) and its CRC
        checksum will change (almost everytime).  This may make some
        anti-virus programs think there was some sort of an infection.  Don't
        panic, it's normal for them to think so, that's how many anti-virus
        programs work.  (I know what some of you are thinking; if your copy
        of ASM11 ever does get infected by a virus and you also happened to
        have used the -W switch, how will you know if the anti-virus program
        is telling the truth?  Well, let's just hope that the virus will be
        an equal-opportunity one and strike other program files as well!
        This will be a good indication.)

    Having saved your default options, you may alter the current state of any 
    of them, by giving the option without a trailing + or - sign.  However, 
    if you create DOS batch (*.BAT) files to call the assembler, or invoke 
    the assembler from within an IDE which has been configured to run ASM11 
    by hitting a key, you may want to supply all available switches with
    trailing + and - signs as appropriate to guarantee the desired operation.
    For example, call ASM11 with a command similar to this:

                    ASM11 -S+ -M- -L+ -C- -X+ -LS+ ...

    but not like this:

                    ASM11 -S -M -L -C -X -LS ...

    This is to avoid problems when after having saved some configuration 
    within ASM11.EXE, you create a batch file (or setup your IDE) assuming
    that initial configuration, then later change the saved configuration to
    some other.  The first example will set each option explicitly on or off,
    in effect ignoring the saved defaults, while the second will simply
    toggle what's the current default.  If you don't specify options with +
    and - signs in your batch files (or wherever else the program is invoked
    automatically, such as from within an IDE), you will have to remember to
    modify them (batch or IDE), also.  All this, of course, assuming you want
    your batch file or IDE to behave the same regardless of what happens to
    ASM11's default settings from time to time.

  ş Optionally produces *.S19 object files.  Turn this option on with the
    command line switch -S+ (or simply -S to toggle on/off depending on
    the current state).  The default for this switch is ON.

    For those not familiar with them, S19 files are standard object code
    files.  They are accepted by most eprom programmers, simulators,
    emulators, and so on (especially if they are related to 68HC11 which is
    of interest to us, anyway).  They are ASCII files and can be edited by
    any ASCII text editor.  If your programmer (device, not human) or loader
    require a different format, you can get one of the several freely
    available utilities for converting from one format to another.

    Most S19 files of interest to us consist basically of two types of 
    records, one for code/data (those lines starting with S1) and one for end 
    of file (the line starting with S9, there should be just one of this 
    type).  Actually, you may even change the order of all S1 type records 
    without causing any damage, as each record holds its own address 
    information.  S9 records normally hold the starting address of the 
    program or module which some assemblers (including this one) produce 
    based on the expression or label next to the END statement, but since in 
    an MCU this is normally fetched from the appropriate reset vector, which 
    you must explicitly define in your program, this record will normally 
    point to address $0000, and you shouldn't worry about it.  However, if 
    you do specify an END statement with a label, that label's value will be 
    used when creating the S9 record.  This is sometimes useful for some 
    programs (such as the example S19 loader supplied, or Shadow11) that
    expect or recognize an execution address in the S9 record.  (By the way,
    many programs that *read* S19 files have wrongfully hardcoded the S9
    record assuming a zero address "S9030000FC", so using a different S9
    record will confuse them.  Do not use an END label or expression in those
    cases.)

    Although most S19 loaders will read files with just these two record
    types, some will try to be "cute" and require a third type of record (the
    header/info type that starts with S0).  Even though they should not be
    bothered by a missing S0 record, some will (just to make your life 
    harder).  If you come across such as program, use the -SH+ option to 
    enable dummy S0 record creation.  If you commonly use such a system, save 
    this option with the -W command.

    To define the maximum S19 record length use the -Rn option (see below).  
    The length is measured from the leading S character to last character of 
    the checksum but does not include the end-of-line CR/LF pair.  The
    default length is 74.  Larger numbers produce smaller file sizes on
    average.  Please note that some programs will load any length S19
    records, while others have a limit of less than 80, or so, characters per
    line.  The default value provides reasonable file size while being
    compatible with most S19 loaders.

    S19 files normally hold data in sequence until the full width of the 
    record is reached, unless an out-of-sequence address forces a "break" 
    sooner.  For various reasons, you may wish to force this break yourself, 
    see the $S19FLUSH directive.  One use for this is to compare your S19 
    output to that of other assemblers that incorrectly break the S19 record 
    when encountering an ORG even if the addresses are in sequence and, thus, 
    not justify breaking to a new line.  Another use is to make certain 
    sections of code appear separately in the S19 file so you may easily edit 
    those sections out without worrying about affecting neighboring 
    code/data.  (Example: you have updated a program based on the 
    MULTBOOT.ASM example and you want to burn only the new code -- last 
    session -- to an already programmed chip.  Using #S19FLUSH around the new 
    code to identify it easily, cut out the remaining code, then program only 
    the new code.)

    Some S19 loaders incorrectly use greater than 16-bit addresses after 
    $FFFF, although they are dealing with S1 type records that are intended 
    for 16-bit addresses only.  Instead, they should wrap around and start 
    over from zero.  To avoid problems with them, you could again use the 
    #S19FLUSH directive to "manually" break to a new record when reaching
    address $FFFF + 1.  To illustrate one example of when this might happen,
    consider the following (which has been "corrected" with the use of the
    directive):

               ORG       $FFFE
               DW        Start
    $S19FLUSH  ;Force the above and below lines on separate S1 records
               ORG       0
    Start      LDS       #$1FF

    The minimum record size value of 12 may be useful in circumstances during
    testing where you want to have each byte on a separate line so as to make
    editing of certain bytes a lot easier.  The *.S19 file size will grow
    significantly, however.

  ş Optionally produces *.MAP source-level map files.  Two types of MAP
    formats are supported (and a third one but in the form of a SYM file, see
    that section for more details).  The first is compatible with P&E's
    simulators and aevms.  The older P&E map format used in EVMs and older
    simulators is not supported as it does not allow source-level debugging,
    only symbolic debugging (and it has a lot of other inherent problems as
    well).  The second type of map format is pretty much an ASCII version of
    the same information.  Turn this option (map file creation) on with the
    command line switch -M+ (or simply -M to toggle on/off depending on the
    current state).  The default for this switch is ON.

    (Source Level debugging with the Ashling emulator is not supported,
    sorry.)

    I added the ASCII version of the source-level map file (-MTA option) in
    hopes that others will add support for it in their products (be it
    freeware/shareware, or commercial).  It is a lot easier to implement a
    loader for the ASCII map file than the secretive binary P&E one.
    Although the ASCII version of the map file is considerably larger than
    the binary P&E format, the purpose of MAP files is only valid during
    debugging, so it can be deleted afterwards.  The format of the ASCII file
    is self-explanatory.  Only the [FILES] and [LINKS] sections are required,
    [COMMENTS] is optional and may be left out (this assembler generates it
    to help others understand its format).  Assemble the supplied FRAME.ASM
    program with the command ASM11 FRAME -MTA -M+, then look at the resulting
    FRAME.MAP (it should be clear enough to be able to follow it).

    To define which of the two formats to produce, use the -MTx (Map Type)
    switch replacing x with either P (for P&E binary format) or A (for my own
    ASCII version of the same format).

    The -MTP MAP file format cannot be viewed directly.  You need specially
    written software to view these files.  One such utility (SHOWMAP.EXE) may
    be available for free from P&E.

    Since -MTA is a new format, at the time of this writing (Oct 98), nobody 
    is expected to support it.  It will only be useful if you're willing to 
    write a conversion utility from this to some other format your 
    development tools use (assuming you have enough information about that 
    other format).

    Source-level Map files are useful for tracing code in a simulator or
    emulator while looking at source code rather than disassembled
    instructions.  If you're using a P&E simulator, such as my favorite
    SIM11E and its counterpart, the EVM/EVS control program AEVM11 (both of
    which, although far from being the ideal tools, are good enough and I can
    highly recommend to those who haven't already decided yet), you will be
    able to single-step through your source code (using the command SS
    [Source Step], see your documentation for those products).  What's also
    nice with this assembler is that extra commands that are a series of
    instructions will appear as if they were single instructions, just the
    way you intended.  If this is not what you want you can always Trace
    through your code, or not use the extra instructions.

    You could also try Frans Gunawan's Win95/98 editor/debugger that's in
    many respects better than many commercial simulators, AND supports ASM11
    directly for source-level debugging.  Read below at the CREDITS sections
    for more information.

    Just a couple of quick notes on parsing the ASCII MAP file.  Search for
    lines starting with a left square bracket to identify sections.  Others
    may be willing to add more sections to accomodate their tools, also.  For
    compatibility reasons, they should also generate the [FILES] and [LINKS]
    section (as described) in addition to their own sections, even if there
    is duplication of information.  From ASM11's point of view, only [FILES]
    and [LINKS] are needed.  [COMMENTS] is optional and it only appears to
    give a short description of the MAP file itself, so others need not
    produce it.  Only these three sections are defined by myself, other
    sections may be defined by others (I would appreciate those doing so
    keeping me informed).  Blank lines within any section are for readability
    only and should be ignored.  The sequence of file names (which may
    include paths, either relative or absolute as obtained from the source
    code definitions) in the [FILES] section defines (indirectly) the file
    numbers used in the [LINKS] sections.  File numbers start from 1, 0 is
    used to indicate a non-file linked symbol, for example an equate that
    although definitely found in some file, has no source-line associated
    with it for the purposes of tracing code.  If the file number is zero,
    the possibly non-zero line number should be ignored as well, and the
    whole line is used only to associate the symbol name with the hexvalue.
    Zero file numbers with non-zero line numbers are the result of $MAPOFF
    being in effect (but others may choose to zero both values and completely
    hide the origin of those symbols).

    If you don't have software that utilizes any of the supported formats for
    a map file, turn the -M option off and save it with the -W command.

    If case-sensitive assembly was requested with the -C+ option, this will 
    also be reflected in the MAP and SYM files.  That means you must give 
    mixed- or lower-case symbol names using the same case as that in the 
    source program, or it won't work.  Unless you really have to do 
    case-sensitive assembly, I recommend leaving the -C option off.  There 
    are, however, some programs out there that make extensive use of upper 
    and lower case symbols that are the same, except for the case.  If when 
    assembling a file, you get too many "duplicate symbol" type errors along 
    with "phasing errors", try re-assembling with -C+ and you might be 
    surprised to see them go away.  If that's the case, edit the file and add 
    the #CASEON directive at the top (not to have to remember to use the -C+
    option next time).

    A case-insensitive assembly (using the default -C- option) will treat all
    symbols/labels as uppercase.  Many third-party tools treat all-uppercase
    symbols as case-insensitive.  However, some don't, or expect
    all-lowercase symbols instead to indicate case-insensitivity.  Depending
    on your situation, use the -C+ or -C- and write your code with
    appropriate case.

  ş Optionally produces *.LST assembly listing files.  Turn this option on
    with the command line switch -L+ (or simply -L to toggle on/off depending
    on the current state).  The default for this switch is ON.

    The listing format is:

    A header showing the filename, the assembler and version, and the full
    date and time of the compilation.

    Each source line is displayed as sections in the following format:

    1. Source File Line Number (5 digit space filled decimal number).  The
       line number may be displayed more than once (in consecutive lines) if
       the data produced for a line is longer than can fit in one (such as
       when an FCB with a relatively long string operand is encountered).

    2. Instruction/Data Address (4 digit hex number).  This is both for 
       instructions and pseudo-instructions (such as RMB and FDB) that cause 
       the Program Counter to change value.  This is followed by a colon (:), 
       period (.), or plus (+) to visually aid the separation from the
       code/data/RMB columns.

    3. Up to three words (as 4 digit hex numbers) of the opcode/data bytes 
       produced by the given [pseudo-]instruction, separated by single 
       spaces.  For Branch-type instructions (except for the extra LBRA and 
       LBSR), the effective address is also shown within parentheses.  The 
       extra conditional Jump instructions have the target address at the
       end, just like normal JMPs.

    4. A cycle counter in [xx] format where xx is a 2-digit space filled
       decimal number indicating the number of cycles required for the
       instruction to execute.  The minimum cycle count is displayed in cases
       where there are variations based on execution.  The special test mode
       instruction TEST is shown with a cycle count of 0, since this
       instruction, once executed, runs forever (or until a reset) and is not
       really meant for normal program use.  Built-in macros will display the
       aggregate cycle count of their component instructions, thus giving the
       impression they are actual 68HC11 instructions.  For some extras, like
       JEQ, this cycle count is not representative of the actual execution
       time in all cases because only when the comparison evaluates to true
       will the full series of instructions execute.

    5. The original source text.  This is unmodified, just the way it was
       read from the source file.  However, if the -Tn option is used with a
       non-zero value (as with the default value of 8) tabs will be expanded
       using spaces.  All other characters will be left as is.  To not have
       tabs expanded, use -T0 (zero).  Please note that the author of the
       source (assuming it's someone else's code) may have specified the
       $TABSIZE directive (if the source was specifically written for ASM11).
       In that case using the -Tn option has no effect (unless, you edit the
       file and remove the $TABSIZE directive).

    Those pseudo-instructions, such as the FCB, that can take multiple
    operands have their data and beginning address displayed separately for
    each operand.  This makes it easy to see where each starts and ends, even
    though they may be together in the source file.

    I M P O R T A N T: If using the :n repeater with FCB type pseudo-opcodes
    (FCC, DW, etc.), then the repeater will be applied to each parameter
    separately before the next parameter is parsed.  For example:

                    FCB:3     0,1,'String'
    is equivalent to:
                    FCB       0,0,0,1,1,1,'String','String','String'
    but *NOT* equivalent to:
                    FCB       0,1,'String',0,1,'String',0,1,'String'

    Also, FCS is really a FCB with an appended ,0 at the end so it behaves as
    if it were FCB 'String',0 given the above explanation.  For example:
                    FCS:3     'String'
    is equivalent to:
                    FCB       'String','String','String',0,0,0
    but not equivalent to:
                    FCB       'String',0,'String',0,'String',0

    If this is not how you would it to work, avoid using a repeater and
    simply copy the line several time, as you would do if repeaters were not
    available.

    #INCLUDE directives will display extra lines (surrounded by *** but no
    line number) indicating the beginning or end of processing included
    files.  This is necessary because line numbering is not cummulative, ie.,
    each included file has its own numbering starting from 1.  This, in my
    view, makes it easier from the listing to locate lines in the original
    files than if they were numbered as if they were part of a single larger
    file.

    One way to look at a sample of a listing, is to do the following with the
    source that's included with ASM11:

                         ASM11 FRAME -L+
                         M FRAME.LST -T

    At the end of the listing you will get a small report of the number of
    code/data/image bytes produced by your program.  This is useful for
    knowing EPROM requirements of your code.

    RAM represents the total byte size of memory defined in either RMB or DS 
    pseudo-opcodes.  Overlaps, as well as memory used directly in 
    instructions (such as STA $13) or via EQU statements, is NOT accounted
    for (it's not possible for the assembler to know, without elaborate 
    analysis).

    CODE represents the total byte size of opcodes and operands (including
    the implied FCB and FDB following the SWI in the OS and OSW extra
    instructions).

    DATA represents the total byte size of all FCB, FCC, and FDB type 
    statements that cause data bytes to be produced (excluding the implied 
    FCB and FDB in the OS and OSW extra instructions).  This will also 
    include vectors (eg., at the FFD6-FFFF range) you define with DW or FDB,
    etc.  It does not count RMB or DS sizes as these two do not produce data,
    they only advance the address/program counter.  (Since I added this, I
    have found it to be quite useful when trying to cut down the size of a
    program in order to fit smaller devices, such as the 811E2.  Some
    programs showed me CODE would fit, but DATA was too big in proportion.
    So I shortened messages and made them fit.)

    IMAGE represents the sum of CODE and DATA sizes, and is probably the one
    you're more interested in, since it's the total memory requirement of
    your program.  Note, however, that image size is only the number of bytes
    of storage required if the bytes were to be placed in sequence, without
    gaps in between. In other words, if an image size is less than 512, it
    doesn't necessarily mean that it will fit your 711E9 EEPROM.

    Here's a sample of that section of the listing:
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
    Total RAM   size:    248   $00F8    0.24 KB
    Total CODE  size:   1071   $042F    1.05 KB   (496 instructions)
    Total DATA  size:    248   $00F8    0.24 KB
    Total IMAGE size:   1319   $0527    1.29 KB

    Lowest address  :  53248   $D000
    Highest address :  65535   $FFFF
    Address Range   :  12288   $3000   12.00 KB   (Used Range: 10.73%)

    Number of INCLUDE files: 2

    Assembled 500 lines (No Errors, Warnings: 0)
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

    The second group of three lines shows the lowest and highest addresses
    used by either code or data, along with the calculated distance (range)
    between those two extremes.  This, in effect, gives you for many cases
    (but not all), the actual size and mapping of memory required to fit the
    program.  The "Used Range" percentage is in relation to the Address
    Range.  In the example above, we see that we need an E9 chip (based on
    addresses used, $D000..$FFFF, 12KB), but we have only utilized 10.73% of
    that chip's memory.  If the internal EEPROM is also mapped (or you use an
    E20 or other device with non-contiguous blocks of memory) the results
    will not be as obvious (because there are gaps in the physical mapping of
    memory) but will again give a pretty good idea of what's required in
    terms of memory.

    Finally, the last line will always show "No Errors" because in case of
    errors *.LST files are deleted.  The "Warnings:" part will show the
    number of warnings for this assembly.  Please note that the actual
    warnings will NOT appear within the listing but only in the corresponding
    *.ERR or redirected error file assuming one was requested (and/or the
    screen).  If the -WRN option is off, the "Warnings:" part will show OFF,
    not 0.

  ş Optionally produces *.ERR error files (provided there are errors or
    warnings).  Turn this option on with the command line switch -E+ (or
    simply -E to toggle on/off depending on the current state).  The default
    for this switch is OFF.

    There may appear several errors and/or warnings for a single source code 
    line.  This is normal.  Usually, fixing the problem indicated by one of 
    the errors, will make all of them (and some for different lines that 
    somehow relate to this one) go away.  Sometimes, especially for less
    experienced users, examining all error messages pertaining to a single
    line will give you enough clues as to the needed action to correct the
    problem.

    In the event of errors, corresponding *.S19, *.MAP, *.LST, and *.SYM 
    files will be deleted, provided the corresponding option was turned on 
    (otherwise, they will not be affected so that older versions of the 
    corresponding files will not be deleted).  Pressing ESC while assembling 
    a file will stop the assembly of the current file and also delete any of 
    the requested produced files.  Errors and warnings do not go into the
    *.LST file (as with other assemblers) but into the *.ERR file as well as
    the screen, so deleting the incomplete *.LST on a unsuccessful assembly
    does make sense.

    *.ERR files are deleted whenever there are neither errors nor warnings
    for a specific file, regardless of the state of the -E option.  After
    assembling a long list of files, you can do DIR .ERR to show a directory
    of all ERR files.  Only files that correspond to these ERR files should
    be considered to possibly have syntax or other assembly-time problems.

    NOTE: You may also send warning and error messages to whatever file you 
          like and in whatever directory you choose, using standard DOS 
          output redirection.  This ability does in no way interfere with 
          normal *.ERR file processing.  The -E and -EH switches have no 
          effect on the redirected error file, only the .ERR files.  In other 
          words, redirection is completely transparent.  Also, in case of no 
          errors/warnings, the redirected error file will not be deleted (it 
          will be blank), because ASM11 has no way of knowing which file this 
          is.  Another difference between *.ERR files and redirected errors 
          is that the latter will contain full path information, sometimes 
          used by IDEs to place the cursor at the appropriate file and line 
          number.  Finally, a third difference is that the redirected error 
          file will contain all errors/warnings for all files processed by 
          the command.  *.ERR files, on the other hand, are one per main file 
          assembled.  Besides Shadow11, another good (shareware) editor that
          I noticed it easily understands ASM11 error messages is WinEdit.

    You may even cause your own errors or warnings from within the source
    (normally under conditional assembly) to alarm the user to some fact s/he
    must know about or, perhaps, correct in the code.  See the #ERROR,
    #WARNING, and #FATAL directives.

    Using -EH followed by an optional + or - (just like most other options)
    lets you send error and warning messages to the *.ERR file but not the
    screen.  This is only meant to be used when the -E option is turned on,
    otherwise, it has no effect.  This option is useful when you assemble
    many files in a single operation, use the -E+ option because errors just 
    have to be directed somewhere (don't they?), and only care to see on 
    screen the summary of errors and warnings for each file that is displayed 
    at the end of the assembly next to the file name.  You can then go and 
    look at the *.ERR files for each one that had either errors or warnings.  
    If you always want errors and warnings to go the screen, regardless of 
    the state of -E switch, turn this option OFF with -EH- save it with -W
    and never worry about the -EH option again.  The default for this option
    is ON.

  ş Optionally produces *.SYM files, (by default) a plain list of symbols and
    their associated values in hex.  This list is not sorted in any
    particular order and does not have fancy headers or extra messages.  You
    can sort it by name or value with the included BSORT.EXE utility.  Turn
    this option on with the command line switch -LS+ (or simply -LS to toggle
    on/off depending on the current state).  The default for this switch is
    OFF.

    .SYM files come in two flavors, plain or deluxe :-) and more may be added
    later if requested.  The plain format (default) provides only some of the
    information available in an ASCII map file produced with the -MTA option,
    or in the SYM file produced when the -LSE option is used.

    The option -LSx allows x to be either S (for "Standard") or E (for the
    freeware EM11 emulator or the Shadow11 simulator).

  NOTE: All files produced (except for the stdout redirected one) will always
        reside in the same directory as their source files, regardless of
        what directory the user was in when giving the ASM11 command.  For
        this reason, it would be best to organize your projects in
        subdirectories each dedicated to a single project.  That also makes
        it easy to assemble all files in that directory by either going into
        the directory and giving the command "ASM11 ." (without the quotes)
        or giving only the directory name as a parameter, followed by a
        slash, eg. "ASM11 C:/ASM/OS11/" (this will assemble all
        C:\ASM\OS11\*.ASM files).

        In some rare situations, this may pose a problem.  For example, 
        trying to assemble from a directory on a CD-ROM disk (or a read-only 
        directory in a network).  You can easily overcome this problem by 
        creating on your hard disk a small dummy program that does nothing 
        more than include the actual file you want to assemble.  Then, simply 
        assemble the dummy file.  If this file has dependencies on that 
        CD-ROM you will want to also set the -I option (temporarily, without 
        using -W) to the appropriate directory.  If the dependencies are 
        absolute, you'll have no choice but to copy the files to your hard 
        disk, modify the include paths, and then assemble.

  ş User-defined symbols/labels can be case-sensitive.  This option does not
    apply to mnemonics or pseudo-instructions which are always
    case-insensitive.  Turn this option on with the command line switch -C+
    (or simply -C to toggle on/off depending on the current state).  The
    default for this switch is OFF.  Note that case is also reflected in the
    MAP and SYM files (read the MAP section for more information).

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
EXTRA MNEMONICS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş ASM11 provides a number of additional mnemonics that are either an alias
    to an original 68HC11 mnemonic or a built-in macro that translates
    (internally) to a series of instructions.  To enable recognition of these
    extra mnemonics, turn this option on with the command line switch -X+ (or
    simply -X to toggle on/off depending on the current state).  The default
    for this switch is ON.  This is also controlled from within the source
    with the $EXTRAON/$EXTRAOFF directives in case you want to allow the
    extra mnemonics in only some portions of your code or specific include
    files.

    Here's a list of all extra mnemonics and their equivalence.
    Instruction          Equivalent instruction (or series of instructions)
    ÍÍÍÍÍÍÍÍÍÍÍ          ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
     LDA                 LDAA
     STA                 STAA
     LDB                 LDAB
     STB                 STAB
     ORA                 ORAA
     ORB                 ORAB
     PSHD                PSHB, PSHA
     PULD                PULA, PULB
     CMPD                CPD
     CMPX                CPX
     CMPY                CPY
     CLRD                CLRA, CLRB
     CLRX                LDX #0
     CLRY                LDY #0
     COMD                COMA, COMB
     NEGD                COMA, COMB, ADDD #1
     XGAB                PSHA, TBA, PULB
     INCD                ADDD #1
     DECD                SUBD #1
     ROLD                ROLB, ROLA
     RORD                RORA, RORB
     CLS                 PSHA, TPA, ANDA #$7F, TAP, PULA  (Clear the S flag)
     CLX                 PSHA, TPA, ANDA #$BF, TAP, PULA  (Clear the X flag)
     SES                 PSHA, TPA, ORAA #$80, TAP, PULA  (Set the S flag)
     WAIT                CLI, WAI
     OS <byte value>     SWI, DB <byte value>  (Useful for calling OS
                         functions, eg. OS fWriteln)
     OSW <word value>    SWI, DW <word value>  (Useful for calling OS
                         functions, eg. OSW fWriteln)
     LBRA                A 22-byte/69-cycle sequence that jumps to a location
                         using relative-mode emulation (ie., with the help of
                         the assembler, it adjusts the PC using appropriate
                         offsets).  Not meant for casual use.
     LBSR                A 32-byte/92-cycle sequence that jumps to a
                         subroutine using relative-mode emulation (ie., with
                         the help of the assembler, it adjusts the PC using
                         appropriate offsets).  Not meant for casual use.
     JCC                 Jump equivalent to BCC (BCS $+5 followed by JMP)
     JCS                 Jump equivalent to BCS (BCC $+5 followed by JMP)
     JEQ                 Jump equivalent to BEQ (BNE $+5 followed by JMP)
     JGE                 Jump equivalent to BGE (BLT $+5 followed by JMP)
     JGT                 Jump equivalent to BGT (BLE $+5 followed by JMP)
     JHI                 Jump equivalent to BHI (BLS $+5 followed by JMP)
     JHS                 Jump equivalent to BHS (BLO $+5 followed by JMP)
     JLE                 Jump equivalent to BLE (BGT $+5 followed by JMP)
     JLO                 Jump equivalent to BLO (BHS $+5 followed by JMP)
     JLS                 Jump equivalent to BLS (BHI $+5 followed by JMP)
     JLT                 Jump equivalent to BLT (BGE $+5 followed by JMP)
     JMI                 Jump equivalent to BMI (BPL $+5 followed by JMP)
     JNE                 Jump equivalent to BNE (BEQ $+5 followed by JMP)
     JPL                 Jump equivalent to BPL (BMI $+5 followed by JMP)
     JVC                 Jump equivalent to BVC (BVS $+5 followed by JMP)
     JVS                 Jump equivalent to BVS (BVC $+5 followed by JMP)

     GETX  #<WORD>       TSX, XGDX, SUBD #<WORD>, XGDX, TXS (allocate stack temp at X)
     GETY  #<WORD>       TSY, XGDY, SUBD #<WORD>, XGDY, TYS (allocate stack temp at Y)
     GIVEX #<WORD>       TSX, XGDX, ADDD #<WORD>, XGDX, TXS (de-allocate stack temp at X)
     GIVEY #<WORD>       TSY, XGDY, ADDD #<WORD>, XGDY, TYS (de-allocate stack temp at Y)

    NOTES: The conditional jump equivalents to conditional branch
           instructions make it easier to replace an out-of-range branch with
           the corresponding jump.  For each use of these instructions, you
           also save a label definition that is implied within the
           instruction.  Finally, this macro is preferred to using the
           equivalent standard mnemonic sequence, because the assembler is 
           able to produce warnings for those jumps that are possible to be 
           converted to branches if during coding the jump ever gets close 
           enough to its target.  Using the standard 68HC11 code sequence 
           (shown in the parentheses next to the instructions) will not 
           produce those warnings (they will for the JMP but not the
           Branch/Jmp combination).

           The XGAB instruction is implemented as a B to A transfer (TBA),
           and not the other way around, because this sets/clears the N flag
           correctly.  Doing a "PSHB, TAB, PULA" sequence will give the same
           result in D, but because of the A to B transfer (TAB) the N flag
           is inverse from what is should be assuming the N flag at the end
           of the operation should indicate whether D's new value is negative
           or not.

           The PSHD and PULD instructions are implemented so as to read
           from/write to the stack the correct D value, so that PSHX and then
           PULD (or the inverse), for example, will work correctly.  (By the
           way, does anyone know if there was a reason for the interrupt
           stack frame to have the D value in reverse order which prevents a
           direct ldd 1,x type instruction to be used?)

           The OS and OSW instructions require special treatment in the SWI 
           handler to operate properly, or else the 8-bit or 16-bit opcode 
           that follows SWI will be treated as an instruction with 
           unpredictable results.  If you're not familiar with this 
           technique, see the example source code FRAME.ASM (and accompanying 
           OS11.MOD) to get an idea of how to write such handlers.  Keep in
           mind that normally, either one or the other can be used within the
           same program, rarely both, as it becomes very difficult for the
           SWI handler to decode whether one or two bytes follow the SWI.
           Although their names imply using those for Operating System calls,
           imaginative programmers could use them for other purposes.

           The CLRD instruction is implemented as CLRA followed by CLRB.
           This sequence is preferred to LDD #0 which although faster (3
           cycles instead of 4) it produces larger code (3 bytes instead of
           2).  If in your application you must save every cycle you can,
           replace CLRD with LDD #0.

           CLX, CLS, and SES save and restore the value of register A which
           is modified during execution.  This was done so you use the
           instructions without worrying about side-effects.  In some
           situations, however, you may not be interested in preserving
           register A's value so you may want to avoid using this macro and,
           instead, explicitly modify the flags yourself.

           In case you thought I forgot about complementing CLX with a SEX
           (Set X mask) instruction, I didn't.  A method for setting the X
           bit is not documented, although there are at least two known
           methods of setting the X bit once cleared.  Both are relatively
           complicated and not used frequently enough to justify making a
           built-in instruction for them.  (Besides, it keeps the assembler
           rated PG-13.)

           WAIT was added because WAI by itself will "hang" the CPU (until
           Reset or XIRQ) if the I bit is accidentally left set.  WAIT, just
           like its homonymous instruction in the 6805, will first enable
           interrupts and then enter the wait phase, which is what most
           circumstances require.

           Due to their relatively big size and slow speed, LBRA/LBSR are not 
           meant for casual use.  They could be useful when (1) you
           absolutely *must* use relocatable code, and (2) your code branches
           from one "side" of the program to the "other" where using a series
           of intermediate BRA "hooks" is too messy or more costly in terms
           of size and/or speed than the two macros offered by ASM11.  I'm so
           against using these without careful thinking that I had originally
           planned to leave these two extras undocumented, but then again
           what good is it to have them only for my own use?  However, let me
           stress this one more time, using these macros casually or in place
           of JMP/JSR is definetely wrong, but it's you writing the program,
           so what do I care?  (They do, however, make wonderful toys for
           confusing a bit someone trying to disassemble your code, it will
           take them a while to figure out what happens when they hit these
           instructions.)

           Both LBRA and LBSR preserve all CCR flags and all unrelated
           registers, so they are totally transparent (and behave just like
           the real thing, only much slower and with possible interruptions,
           real instructions are atomic -- non-interruptable).  They do use
           quite a few bytes on the stack to do all this, though.  I don't
           claim to have the best possible (in terms of size and speed)
           coding for these two, if you come up with a better one, let me
           know.

             I M P O R T A N T:  Since version 1.69, LBRA and LBSR produce a
             slight different sequence of opcodes.  This was due to an
             optimization which reduced size by 2 bytes and speed by 7 cycles
             for both instructions.  This difference will not affect you
             unless you have used these macros before *AND* you are trying to
             compare the new object to the old object.  Although source code
             may be the same, there will be a S19 file difference and the
             files won't match.

           In case you were wondering, there is no need for a "long" version
           of the remaining branch instructions, such as BEQ, etc.  Only the
           LBRA and LBSR are enough to accommodate every possible situation.
           For example, a LBEQ isn't required because to do the equivalent
           of:

           ...
                    LBEQ      FAR_AWAY
           ...

           one could do this:

           ...
                    BNE       Local.1
                    LBRA      FAR_AWAY
           Local.1  EQU       *
           ...

           Similarly for the rest (I'm sure you got the idea).  Look at the
           description of the Jxx extras for equivalent opposite branches for
           each conditional branch.


  ş Frequently used options may be "permanently" saved inside the ASM11.EXE
    file.  Use the -W option to save the state of all switches appearing
    before the -W switch while leaving the rest unchanged.  The word
    "permanently" is quoted because you may use the -W option as often as you
    like.

  ş You are given the option to change the S19 record length to any length
    from 12 (minimum possible for one byte per record) to 250 (maximum
    allowed by this program), use the -Rn option, replacing n with the actual
    number desired.  Note that the number must be even (exactly divisible by
    2) because odd sizes do not make correct S19 records.  You will not be
    allowed to enter an invalid record length, anyway.  The default S19
    record length is 74 which holds 32 bytes of code/data [ie., (74-10)/2].
    Incidentally, most assemblers use either 74 or 42.

  ş Another variation of the -R option allows you to specify a new default
    source filename extension.  The default for this option is .ASM but you
    can change it to any valid extension (ie., any except for blank, S19,
    LST, MAP, ERR, and SYM).  You should use the -W option somewhere *after*
    the -R.ext option to save the new default extension inside the ASM11.EXE.
    If you only need to specify a different extension temporarily, you should
    do so directly at the command line (eg. ASM11 .A11 to assemble files
    matching *.A11 in the current directory).  To make the .A11 permanent so
    you no longer have to type it, do ASM11 -R.A11 -W and from then on typing
    ASM11 . will match *.A11.

    By the way, please note that listfiles have only one requirement.  That
    the filename mask and/or path be the very first non-blank entity.  After
    that there may be comments or whatever else you like.  Incidentally, most
    of the little utilities I've written from time to time, produce output
    that can be directly used as a listfile (eg. WHERE, FD, etc.).

  ş Another option is -Tn, where n is the actual number of the tab size, for
    setting both the output listing tab size and, more importantly, the
    parsed input lines so that strings with embedded tabs will expand
    correctly.  The default for this option is 8 (which is the default tab
    size for most editors).  If you know a source file uses different tab
    size (or if you have set your own editor to different tab stops and
    enabled saving with tabs), use this switch to match it to the source
    file's tab size.  To make it permanent, just like with all other options,
    use the -W command.  Note, however, that if the file contains the
    $TABSIZE directive, this option will be overriden for lines following the
    embedded directive.  The embedded $TABSIZE will only have effect for the
    current main file and all its included files (until a new one is
    encountered).  When a new main file is started, the tab size will again
    default to the one set with the -Tn option, and so on.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ADDRESSING MODES
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş Addressing modes are invoked as follows:
    Mode       Prefix    Examples
    ÍÍÍÍ       ÍÍÍÍÍÍ    ÍÍÍÍÍÍÍÍ
    Immediate    #       LDX #TABLE
    Direct     @ or <    LDX @COUNTER   LDX <COUNTER
    Extended     >       LDX >COUNTER
    Auto Dir/Ext None    LDX COUNTER (if COUNTER < $100 use DIRECT, else EXT)
    X indexed            LDA ,X    LDA 0,X   LDA OFFSET,X
    Y indexed            LDA ,Y    LDA 0,Y   LDA OFFSET+3,Y

    If @, <, or > aren't used, the assembler automatically attempts to use 
    direct mode when possible (that is, when the resulting address has a most 
    significant byte of 0).  It will be successful if no forward references 
    are used, otherwise, it will use extended addressing (ie., worst case 
    scenario).  You should explicitly define direct mode addressing by using
    the @ or < prefix or extended addressing mode using the > prefix for
    situations where you want to override the assembler's automatic choice of
    mode.

    Forward references will force extended addressing in PASS1, but in case 
    that choice proves wrong, PASS2 will produce appropriate warning messages 
    to aid you so that you may add the < or @ prefix to explicitly use direct 
    mode.  Since PASS2 maintains the addressing mode selected in PASS1, there 
    is no possibility of phasing errors.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
BIT INSTRUCTIONS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

The 68HC11 CPU provides a set of very useful instructions for manipulating or
testing individual bits.

  ş BSET/BCLR and BRSET/BRCLR instructions require commas between all
    operands.  This is one common conversion you may have to do when porting
    from another assembler that uses spaces (such as Mot's AS11) or other
    characters.  You will be assisted by appropriate messages.

    If you get a warning about "extra operand ignored" check to make sure you
    either haven't left the R out of the BRCLR/BRSET and typed BCLR/BSET
    instead, or that you actually haven't supplied a branch address to
    BCLR/BSET instruction (perhaps due to cutting and pasting from another
    line).

    All of the following examples are valid Bit instructions:

               BSET      ,X,#$80
               BRCLR     1,Y,3,*
               BRSET     2,Y,#128,$
               BCLR      0,X,1
               BSET      Flags,mskDirection
               BRCLR     Flags,x,mskDirection,LeftRotate
               BRSET     Flags,x,mskDirection|mskRightAllowed,RightRotate

    Note that the use of # in the mask is optional (and in fact is accepted
    only to make it compatible to a wider range of assemblers).

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PSEUDO-INSTRUCTIONS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

Pseudo-instructions are not real 68HC11 instructions ("pseudo" is Greek for
fake).  They are used to make organization of code and data easier.

  ş Pseudo-instructions that are supported are:
    ORG        for specifying the ORiGinating address of a code/data section
    RMB        for Reserving *unitialized* Memory Bytes
    DS         for Defining Storage (the same as RMB)
    FCB        for Forming Constant Bytes (numeric values or strings)
    FCC        for Forming Constant Characters (actually same as FCB)
    FCS        for Forming Constant (ASCIIZ) Strings (like FCB followed by ,0)
    DB         for Data Byte definitions (yet another alias for FCB)
    FDB        for Forming Double Bytes
    DW         for Data Word definitions (the same as FDB)
    END        is supplied mainly for compatibility.  If used, however, with
               any label (or expression) next to it, the S9 record produced
               will have the address indicated by END's argument.  If
               multiple END statements are used, the last one's value will be
               used.  If the last one has no label next to it, or no END is
               ever used in the program, the S9 will point to zero address.

    FCB, FCC, FCS, DB, FDB, and DW accept multiple operands separated from
    one another by single commas.  All others, depending, expect either a
    single or no operand (eg., END).  Each may be preceded by a label, except
    for ORG and END in which case the label is ignored and you get a warning.

    EQUs, ORGs, DSs, and RMBs may not refer forward.  All others may do so,
    although in some instances where there is a phasing value difference (a
    different value for the same symbol between PASS1 and PASS2), you will
    get a warning.  Normally, you should ignore such warnings (if they don't
    show along with other warnings or errors), as the resulting code will be
    correct using the most current value.  You can always avoid such
    conditions by eliminating unnecessary forward references.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
NUMBERING SYSTEMS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş The default number base is 10.  As a default, it cannot be changed to
    anything else.

  ş Specify hex values by using the $ prefix

  ş Specify binary values with the % prefix

  ş Specify decimal values with the ! prefix. (Although decimal is the
    default, the ! is provided for compatibility with some other assemblers).

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
COMMENTS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş Any line beginning with any number of spaces or tabs followed by a * or ;
    is a comments line.  Anything other than a comment and a space on the
    very first character of a line (or an assembler directive starting with $
    or #) indicates a probable symbol definition (pending symbol syntax
    check).  Non-labeled instructions must have at least a tab or a space in
    the beginning of the line.  Comments that follow instructions may or may
    not start with the ; character.  Although this makes it a bit more
    flexible than requiring a ; for comments, it also poses a few threats.
    For example, the source line:

               CLRA      COUNT     ;comment line

    will not cause any errors, since CLRA is an inherent addressing mode
    instruction that does not need any operands and, thus, COUNT is
    considered the beginning of the comment.  Something like this actually
    appears in a file called AMOTOR.ASM from Mot's web site.  The reader may
    misread this as "CLR COUNT ;comment line" and since the assembler won't
    give any errors or warnings, s/he may have a hard time figuring out
    what's wrong.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ARITHMETIC AND LOGICAL OPERATORS USED IN EXPRESSIONS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş Operators allowed are:
    Operator   Function
    ÍÍÍÍÍÍÍÍ   ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
       +       Addition.
       -       Subtraction.
       *       Multiplication.  Note that * is also used to specify the
                                current address, eg. START EQU *
                                To avoid ambiguous expressions using the *
                                (current PC value) and * (multiplication
                                operator), change the * (current PC) to its
                                alias $, eg.  START EQU $*2 (a nonsense
                                statement that is only meant to illustrate
                                the point).
       /       Integer division, remainder is ignored.
       \       Modulus.         Division remainder.
       >       Shift right.     SPEED > 2 shifts the value of SPEED to the
                                right by 2, effectively dividing SPEED by 4.
       <       Shift left.      SPEED < MULT shifts the value of SPEED to the
                                left by as many places as indicated by the
                                value of MULT, effectively multiplying SPEED
                                by 2^MULT.
       &       Bitwise AND      $81 & $0F will produce $01
       |       Bitwise OR       $81 | $0F will produce $8F
       ^       Bitwise XOR      $81 ^ $0F will produce $8E
       ~       Swap Hi/Lo       ~$1234 will produce $3412  (PRECEDENCE)
       [       Lo 8-bits        [$1234 will produce $34    (PRECEDENCE)
       ]       Hi 8-bits        ]$1234 will produce $12    (PRECEDENCE)

    NOTE: Although some of the examples above are shown with spaces for
          clarity, actual code should not include spaces (except within
          strings or character constants), unless the -SP (or $SPACESON
          directive) has been used following by semi-colon beginning
          comments.

    Operations are carried out from left to right with NO special precedence,
    except for the ones marked so.  This means, that addition and
    multiplication have equal rights.  I know this is a little bit unorthodox
    (although AS11 and other assemblers do the same, so I'm not all alone
    here).  Also, there is no way to change precedence by parenthesizing,
    because parentheses are currently not allowed (and if you use them you
    will get an error).  The operators ~, [, and ] do not act on two operands
    but only on the one which follows them.  So, you could say 1+3*[$1234 to
    have 1+3*$34 evaluated.  Of course, you could use symbols rather than
    numbers.  Note that [ comes right before the number or symbol (eg.,
    [VALUE) but, in case of numbers, before the $ which is the symbol for hex
    and is part of the number.

    There are ways around the limitations imposed by lack of precedence.  Use
    intermediate symbols if necessary, or re-arrange (when possible) the
    order in which operations are to be performed.

    Also, remember to examine expressions carefully when porting from another
    assembler (or simply assembling someone else's code you don't know for
    which assembler it was written originally) to assure they evaluate the
    same with this one, and that all operators (especially the less common
    ones) perform the exact same functions.

    Example              Evaluates to
    ÍÍÍÍÍÍÍ              ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
    1. LDA #3+4*2        3 + 4 = 7 * 2 = 14

    2. TEMP EQU 4*2      8              ;One way to give precedence to *
       LDA #3+TEMP       3 + TEMP = 11

    3. LDA #4*2+3        11             ;Another way to give precedence to *


    A "neat" use for the [ is shown below:

    REGS       equ       $1000
    PORTB      equ       $1004
               ldx       #REGS
               lda       PORTB          One way to load PORTB
               lda       PORTB-REGS,x   A second way to load PORTB
               lda       [PORTB,x       A third way to load PORTB (preferred)

    You could also use the simpler (but warning producing):

               lda       PORTB,x        A fourth way to load PORTB

    and get the correct code produced, but you would also get a warning
    because of the attempted use of a 16-bit operand in place of the expected
    8-bit one.  The [ provides a more elegant (warning-free) solution.

    The above methods save you the need to define two symbols, PORTB and
    _PORTB (for example), the first with the 16-bit value and the second with
    the 8-bit $1000-based offset value.  Now, you only need to define the
    16-bit one and depending on what's required use either the lower ([) or
    higher (]) 8-bits.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
STRINGS and CHARACTER CONSTANTS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş Strings and character constants may be delimited by (placed within)
    single ('), double ("), or back (`) quotes.  However, what starts a
    string must also end it.  For example, the following are all valid
    strings:

    'Hello World!'
    "Hello again"
    `"That's enough" is an embedded string`

    This assembler will allow those writing code in "foreign" languages
    (what's foreign is different to each of us) to define strings in their
    language.  This was a serious shortcoming with some assemblers I had
    used, they only accept 7-bit ASCII strings.

    Please note that some other assemblers use the / character as a delimiter
    (or any other character).  This assembler has specific string/character
    constant delimiters, and it will attempt to do a division (or other funny
    things) when an / (or other character) is encountered.  This is likely to
    lead to "Division by zero" or other misleading errors.

    Also, please note that instructions such as LDX #'00' will do the "right"
    thing, ie., LDX #$3030, while LDX #'0' will act as LDX #$0030. Also, a
    LDA #'00' will act as LDA #'0' (ie., LDA #$30) but will produce a warning
    about using a 16-bit operand with an 8-bit instruction.

    What is a bit unusual is that you can also do LDX '00' (with the # sign
    missing for extended mode) which will be treated as LDX $3030.

    You can use any of the operators with string constants, eg. to convert
    Register A's value to uppercase, you could write:

    Uppercase       cmpa      #'a'
                    blo       Uppercase.Exit
                    cmpa      #'z'
                    bhi       Uppercase.Exit
                    suba      #'a'-'A'
    Uppercase.Exit  rts

    If you don't put the ending delimiter, your string will most likely be
    defined alright, unless there are operators, spaces, or comments
    following.  For example,

                    lda       #'a

    (a is followed by end-of-line, not spaces) will give you a warning about
    an unclosed string but will produce the correct code.  However,

                    lda       #'a            this is a comment

    will not produce the expected operand, it will most likely produce a
    space value ($20)!

    Some other things you can do with string constants:

                    lda       'A',x
                    rmb       'Z'-'A'+1

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LABELS or SYMBOLS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş Labels and symbols may begin with an alphabetic character (A through Z), 
    or a dot (.), or an underscore (_).  Local labels begin a question mark 
    (?).  After that they may have any combination of characters (special and
    alphanumeric), except for space or any of the operators (such as *, -, +,
    [, ~) or string delimiters.  If the last character is a colon (:) it will
    not become part of the symbol, for compatibility with other assemblers.
    Although there aren't any strict rules for labels at the moment, try not
    to get too wild about using special characters, as this will render your
    programs incompatible with most other assemblers, simulators, and
    emulators.

    You can use anything for a symbol, even if it's the same as a mnemonic or
    pseudo-instruction, eg., the following is perfectly legal code of
    perfectly bad programming style:

          bra       bra       jmp       jmp
          jmp       jmp       bra       bra
    Label  Ù         ³         ³         ³
    Instruction ÄÄÄÄÄÙ         ³         ³
    Branch/Jump target ÄÄÄÄÄÄÄÄÙ         ³
    Comment ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    The maximum length for a symbol/label is 19 characters.  Although you may
    define longer symbols for the sake of readability, only the first 19
    characters are significant, and if they collide with another symbol's
    first 19 characters, a "duplicate symbol" message will be displayed.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
INCLUDE FILES
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş INCLUDE files are also supported.  You may use the $INCLUDE (or #INCLUDE) 
    directive, followed by the (optional path and) filename to include (with
    as many spaces in between the INCLUDE and the filename as you like),
    followed by whatever comments you like.  The filename may be plain or
    embedded in any of the allowed string delimiters.  Any path you give will
    be relative to the directory of the *main* file processed even for nested
    includes that are located in some totally different directory and/or
    drive.  For example,

    FILE1.ASM (in directory C:\ASM\68HC11\LCD)
    ---------
          $INCLUDE ../LCD.INC
          ...

    LCD.INC (in directory C:\ASM\68HC11)
    -------
          $INCLUDE ../EQUATES.INC
          ...

    EQUATES.INC should be in the *same* directory as LCD.INC for this to work
    because the ../EQUATES.INC in LCD.INC is relative to FILE1.ASM's, not
    LCD.INC's location.

    Of course, to avoid problems with relative paths pointing the wrong 
    place, the path could be absolute, ie., contain the full path of the file 
    (eg., C:/ASM/LCD.INC or /ASM/LCD.INC).  Both forward and backward slashes
    may be used.

    I M P O R T A N T: You may also use the -Ix option (which you can save 
    with the -W command) where x is a directory name which acts as a default 
    include directory starting point for *relative* (not absolute) include 
    specifications that are not found relative to the main file.

    When specifying a path for the -Ix option, the path will be assumed 
    relative to your current path when you execute the command.  You should 
    specify the absolute path if what you get is not the desired location.
    You can check the path assumed by ASM11 by running ASM11 without any file
    arguments, eg.,

          ASM11 -Iasm/68hc11

    and checking the help screen for the effective absolute include path.
    ASM11 always converts any path you supply with -Ix option to an absolute
    path.  If when running the above command, you are in a directory named
    D:\TEMP the effective -I directory will be D:\TEMP\ASM\68HC11

    If you use the -Ix option (which you should normally save with -W
    option), then all your INCLUDE statements become a lot simpler.  For the
    example earlier you could instead specify (if your -Ix option is pointing
    to C:\ASM\68HC11):

    FILE1.ASM (in directory C:\ASM\68HC11\LCD)
    ---------
          $INCLUDE LCD.INC
          ...

    LCD.INC (in directory C:\ASM\68HC11)
    -------
          $INCLUDE EQUATES.INC
          ...

    If your INCLUDE path is relative (ie., does not contain either a drive
    letter or a beginning slash) it will again be tried twice, first with
    respect to the main file's directory, and if not found there, once more
    relative to the -Ix directory.  For example:

    FILE1.ASM (in directory C:\ASM\68HC11\PROJECT)
    ---------
          $INCLUDE  LIB/MATH.SUB

    MATH.SUB will first be searched as C:\ASM\68HC11\PROJECT\LIB\MATH.SUB and
    if not found, it will be searched again as C:\ASM\68HC11\LIB\MATH.SUB.

    Another example:

    FILE1.ASM (in directory C:\ASM\68HC11\PROJECT)
    ---------
          $INCLUDE  ../MATH.SUB

    MATH.SUB will first be searched as C:\ASM\68HC11\MATH.SUB and if not
    found, it will be searched again as C:\ASM\MATH.SUB.

    So, as you can see, the -Ix directory is used as a starting point for
    relative paths, not as a root directory.

    There is no default INCLUDE extension.  Also, INCLUDEd filename
    extensions are not restricted.  Although I don't see why you must do so,
    this will allow you to use any of the forbidden extensions by setting up
    a file that includes the one(s) with the illegal extension(s).  Be
    forewarned, you may be looking for trouble, and you will most likely lose
    your source code if for example you try to assemble an include with an
    illegal extension (such as .LST) that is located in the same directory as
    the main file!  INCLUDEs with illegal extensions should only be used for
    files outside the main file's (ANY main file's) directory.

  ş You may want to turn off certain portions of your code in the listing
    output (eg., INCLUDEd equates).  You can do this by using the $LISTOFF
    (to turn off) and $LISTON (to turn back on) directives within your code,
    where appropriate.  This directive is initially ON for every main file.
    An example follows:

    ...
    $LISTOFF                       ;Turn listing off
    $INCLUDE EQUATES.INC           ;General symbol definitions
    $LISTON                        ;Turn listing back on
    ...

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LOCAL SYMBOLS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

    Assembly language files may use local symbols.  Locality is per include
    or main file.  To define a local symbol, start its name with the
    character ?  (question mark).  This will make it visible only within the
    file it is found.

    Making certain symbols local to a file guarantees that they may not be 
    accidentally used by either parent, child files, or sibling files.
    Although locality is implemented on a per file basis only, it still
    provides a lot of flexibility in the maintenance of larger programs.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MAP FILES
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş Those of you who make use of the generated MAP (or -LSE SYM) files will 
    find the directives $MAPON and $MAPOFF handy.  Rather than generating 
    detailed line number information in the MAP file for all executable lines 
    of your code, you may want to turn off line number information for 
    certain portions you know work well, so that when you do SS (SIM11x and 
    AEVM) to step over them, they will be executed as a single instruction.
    (This in a way overcomes AEVM11's and SIM11x's inability to step over an
    instruction via a command, they will only step into it.) You can turn
    mapping off for whole files or single commonly used routines that you
    have traced a zillion times and don't need to, anymore.  This directive
    is initially ON for every main file.  For example:

    ...
                    LDA  ,X
                    BSR  UPPERCASE
                    STA  ,X
    ...
                    $MAPOFF                  Turn off source-level map info
    Uppercase       cmpa      #'a'
                    blo       Uppercase.Exit
                    cmpa      #'z'
                    bhi       Uppercase.Exit
                    suba      #'a'-'A'
    Uppercase.Exit  rts
                    $MAPON                   Turn on source-level map info
    ...
                    ORG       $F800
                    $MAPOFF
                    $INCLUDE OS11.MOD        Fully-tested Operating System
                    $MAPON
    ...

    Turning the detail source-level info off does not affect symbols defined 
    within those sections of code (so turning map info off for a section of 
    EQU or DB statements does not do any good, it is only good for executable 
    code sections).

    Since the symbol table is also used for keeping source-line info, this 
    also provides a means of reducing the symbol table size for larger 
    programs, so if you should ever get an error saying that there was not 
    enough heap memory (memory used for the symbol table), turn off "mapping" 
    for those portions of your code that aren't really necessary to trace one 
    line at a time.  It hasn't occurred to me so far to run out of heap 
    memory with actual programs, but your programs may be more symbol rich 
    than most.  With detail source-line map info turned on, the maximum 
    program size will be approximately 11000 instructions and/or symbols (not 
    counting blanks, comments, pseudo-instructions, etc).  With no 
    source-level info, there should be no practical limit (i.e,. you will 
    fill the 64KB memory space of the 68HC11 before running out of heap 
    space).  Nevertheless, if you do manage to bring the assembler to its
    knees, maybe you should consider breaking your program into separate
    independently assembled modules.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TABS IN THE SOURCE TEXT
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş The $TABSIZE is one method for the programmer to force the tab size of
    his/her source code to a specified number (any positive integer
    following, eg., $TABSIZE 10).  This makes it possible to distribute code
    to people who have different tab settings in their copy of ASM11, and
    still have them get the listing formatted correctly, and more
    importantly, actual string data.  $TABSIZE will always override whatever
    value the user has given to the -Tn switch.  It should normally be one of
    the first (if not the very first) lines in the program, to avoid the
    lines before it to be formatted with the default tab setting.  If you
    save your files with tabs, it should definetely be included before any
    string data is encountered, or you could get wrong data produced (with
    the wrong number of spaces).  Be careful with included files that may
    change tabsize to something else, since tabsize is reset to its -Tn
    default only at the beginning of a new main file.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MISCELLANEOUS DIRECTIVES
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş $CASEON and $CASEOFF control the -C switch from within the source.  The
    initial setting for each main file is taken from -C switch.  Normally,
    you should set this at the beginning of the source so that no matter what
    the current default is for -C, your code will assemble correctly every
    time.

  ş $EXTRAON and $EXTRAOFF control the -X switch from within the source.  The
    initial setting for each main file is taken from -X switch.  Normally,
    you should set this at the beginning of the source so that no matter what
    the current default is for -X, your code will assemble correctly every
    time.

  ş $S19FLUSH causes the S19 file to break to a new line regardless of
    whether the next address is in sequence or not.  Useful for comparison of
    S19 files with those of other assemblers that incorrectly break the S19
    when encountering an ORG statement, and for by-passing problems with some
    loaders that don't do a very good job.  Multiple consecutive $S19FLUSH
    directives are treated as one.

  ş $OPTRTSON and OPTRTSOFF stand for OPTimize RTS.  This directive's
    command-line equivalent is -RTS and is initially OFF for every main file.
    Its use controls the display of the warning regarding the possible
    optimization with JSR/BSR followed by unlabeled RTS, and is intended for
    the last phase in programming, where we might want to optimize "JSR/BSR
    followed by unlabeled RTS" sequences to their equivalent JMP/BRA.  The
    $OPTRTSON directive will give us warnings for each unlabeled RTS that
    *immediately* follows either a JSR or a BSR instruction.  A blank line or
    anything else between the RTS and the last JSR/BSR line will cause no
    warning.  A labeled RTS again will cause no warning because the label
    could be used to branch directly to the RTS from some other part of the
    program, so an optimization wouldn't be possible (unless the label is
    never actually utilized, but ASM11 will not check for that condition).

    Some programs use tricks based on the PC value saved on the stack during
    a JSR or BSR.  These programs should not be optimized because the called
    subroutine will not work correctly.  If you leave a blank line between
    the JSR/BSR and the RTS, the assembler will not produce a warning and
    save you from inadvertedly replacing the sequence with JMP/BRA.  You
    could also turn off this warning, around sections of code you shouldn't
    optimize, using the OPTRTSOFF directive.

  ş $OPTRELON and $OPTRELOFF control the display of the warning regarding the 
    use of a branch in place of a jump when possible.  The command-line 
    equivalent is -REL.  Initially (if you haven't saved your own defaults) 
    this option is ON.  Normally, you would want to leave this option on 
    except perhaps for cases where you have a list of JMPs that you use based 
    on indexing using some calculation.  This would not make it easy if some 
    of the entries maintain their JMPs while others get optimized to BRAs.
    Use the $OPTRELOFF to turn off this warning just before the table, and
    re-enable the warning right after it.  Example:

          #OPTRELOFF
          TABLE          JMP  FUNCTION_1     ;faraway
                         JMP  FUNCTION_2     ;faraway
                         JMP  FUNCTION_3     ;close enough for BRA
                         ...
          #OPTRELON


  ş $PUSH and $PULL save and restore the state of the directives MAPx LISTx 
    CASEx EXTRAx SPACESx OPTRTS OPTREL TABSIZE (where x is either ON or OFF).  
    This is useful in conjuction with included files that may want to change 
    any of these options for themselves and then return them to their 
    original (parent file or command-line) settings.  Using $PULL without
    having used $PUSH before is OK, no action will take place.  You can $PUSH
    as many times you like subject to available run-time stack space.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CONDITIONAL ASSEMBLY
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş Conditional assembly is supported as well.  Conditional directives cause
    portions of your code to assemble or not based on whether a symbol is (or
    symbols in an expression are) defined, undefined, zero, non-zero, or if
    two expressions give true or false comparison based on the comparator
    used.  If used properly, they can be very powerful.  Accepted conditional
    directives are listed below:

    Conditional     Becomes True when
    ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

    $IFDEF expr     All symbols in expr are defined
    $IFNDEF expr    Any one symbol in expr is not defined
    $IFZ expr       All symbols defined and expression evaluates to zero
    $IFNZ expr      All symbols defined and expression evaluates to non-zero
    $IF e1 COMP e2  All symbols defined and e1 COMP e2 is true based on
                    COMParator used.  (COMP may be any of =, <>, <, >, <=,
                    >=)
    $IFEXISTS path  path is found
    $IFNEXISTS path path is not found
    $IFMAIN         file that contains directive is the main file
    $IFINCLUDED     file that contains directive is being used as an INCLUDE
    $ELSE           Last unmatched IFx was False

    The $ENDIF closes the last unmatched IFx used

    Nested conditionals are allowed.  Each ELSE is always matched to the last
    unmatched IFx and similarly for ENDIF.  ELSE and ENDIF do not take
    arguments.  The remaining take as argument an expression (IF needs two
    expressions around a comparator), just like any other expression you use
    in your program.  No comparator operators are allowed, just an expression
    (except in the case of IF where a comparator is required between the two
    expressions).  IF, IFZ and IFNZ produce warnings if the symbols in the
    following expression(s) are not yet defined, and in that case always
    evaluate to False (so, in such cases if there is an ELSE following, the
    ELSE is always taken).  ELSE is optional.  ENDIF is required unless the
    end is also the end of the *main* file (in which case it can be left
    out).  IFDEF and IFNDEF do not produce warnings for undefined symbols
    (that's what they are supposed to check), the other IFxxx directives
    issue warnings for undefined symbols since they are meant to check values
    not presence (but you may wish to combine the two functions in one and
    ignore the warning).

    Note that expressions are made of symbols used in the program itself (or 
    simply defined but not used).  There is no way to define a symbol only 
    for the purposes of conditional assembly, as you can do with some other
    assemblers (eg., some that use directives like $SET or $DEFINE).  Even
    symbols defined via the command-line -Dxxx option are accessible just
    like any other symbol.  (Actually, the -Dxxx option defines the symbol
    specified during the processing of the first line of your source, so an
    error in the -Dxxx symbol will appear as if it were found in line 1 of
    your source code.) You may, however, have the same effect by defining
    your symbols using regular assembler syntax (eg., DEBUG EQU 1).

    A symbol on a line by itself will also define it (since IFDEF and IFNDEF
    do not care about the value of a symbol, no EQU is necessary, and the
    symbol will assume a "random" value, the current address).  For example:

    DEBUG ;Define the symbol DEBUG (note the needed ; for the comments)
    ...
    $IFDEF DEBUG
    ...
    $ENDIF

    You may pass up to ten symbols from the command-line using the switch -D.  
    So, the above example would not require to explicitly define DEBUG within 
    your code, instead the user would assemble with -DDEBUG option.  All 
    symbols defined with the -D option assume the value 0 (unless you 
    explicitly supply a different value) and, though not restricted from
    being used in any other way, they are only meant to be used with the
    $IFDEF and $IFNDEF directives.  Finally, symbols defined with the -D 
    option are always passed to the program as ALL UPPERCASE regardless of 
    the -C switch setting or any $CASEON directives.  So, to make certain 
    they will work correctly under any circumstances, the user should check 
    for those symbols with uppercase only.  For example, this is correct:

    $ifdef DEBUG
    ...
    $endif

    but this is wrong:

    $ifdef Debug
    ...
    $endif

    because even though it will work with $CASEOFF, it will stop working as
    soon as the program is assembled with -C+ ($CASEON).  In that case, the
    possible #ELSE will be taken instead, but you will not be given any
    warning about this.

    The above uppercase-only limitation applies only to symbols defined via
    the -D switch, not those defined in any other way within your code.

    If you want to test for a specific value, you may try something like
    this:

    $IFZ  ROM-$F800
    or
    $IF   ROM = $F800

    These will be true if ROM is equal to $F800, false otherwise.

    NOTE the required spaces in the IF which separates expression1 (ROM) from
    comparator (=) from expression2 ($F800).  In the IFZ there is no space
    around minus (-) because the whole thing is a single expression.

    Another example (both symbols must be defined, or else the ELSE is
    taken):

    $IFDEF DEBUG+MCU711E9
    ...
    $ELSE
    ...
    $ENDIF

    Symbols are defined by the program itself, so even START LDS #$1FF will
    define START with the value of whatever address it happens to fall on.
    Then you can say:

    #ifdef START
    ...
    #else
    ...
    #endif

    Expressions used in conditional assembly are of exactly the same format
    as those used in normal assembly language.  For example, you could say:

    #IF ROM+$1000 > RAM_TOP-VECTORS
    ...
      #IF * > ROM        ;if current address is greater than ROM
      ...
      #ELSE
      ...
      #ENDIF
    ...
    #ENDIF

    In the produced .LST, sections of code between conditional directives
    that evaluate to False, will not be shown (as if the LISTOFF directive
    had been used) regardless of the current LISTON/LISTOFF setting.  The
    listing file will show only code and directives recognized as a result of
    conditionals evaluating to true.

    Since the listing follows the interpretation of the source code, false 
    #IFxx directives will not be shown at all.  Their matching $ELSE and 
    $ENDIF will be shown.  Likewise, true #IFxxx directives will have their 
    #ELSE part not shown at all.

    IMPORTANT: The above paragraph does not apply when the -LC option is
    turned on (the default for v1.81 or later).  It only applies to version
    prior to v1.81 or if the -LC option is turned off.

    One easy way to mark a whole section of a program as comments is to use
    the $IFDEF directive with no operand.  This will always evaluate to False
    (because a null symbol name can never be defined), and the enclosed (to
    the matching $ENDIF) section will be ignored.

    If the end-of-file is reached before you close a conditional directive
    with #ENDIF you will not get any error or warning messages.  It will
    work, however, as expected.  The End-Of-File will automatically close any
    open IFxxx directives (End-Of-File applies only to main files, not
    INCLUDEd ones).

    Finally, all comparisons are based on 16-bit unsigned words.  This may
    give some unexpected (but correct) results in certain cases.

  ş The directives $WARNING and $ERROR allow the programmer to induce
    warnings and/or errors wherever s/he pleases.  The message to be
    displayed follows the directive by as many spaces apart as desired (all
    duplicate spaces are trimmed).  These are often useful with conditional
    assembly to alert to actions taken (normally with a WARNING) or serious
    problems resulting from a condition taking a different path than
    originally planned (normally an ERROR).  Example usage:

    ...
    #if ROM < $D000
      #warning This program will not fit a 711E9 internal eprom
    #else
      #if ROM >= $F800
        #error The area from $F800 to $FFBF is reserved for OS11
      #endif
    #endif
    ...

    or something like the following IF at the end of a "talker" program that
    must load in RAM:

               org       $0
    Start      equ       *
    ... more code here ...

    #ifdef MCU811E2
      #if *-Start > 256
        #fatal The code will not fit internal RAM
      #endif
    #else
      #if *-Start > 512
        #fatal The code will not fit internal RAM
      #endif
    #endif

    Yet another directive is FATAL (see above example).  This is similar to
    ERROR but also causes a complete halt of the assembler.  This directive
    is useful for conditionals that have to decide whether further
    compilation is possible or not.  For example:

    #ifdef MCU711E9
      #ifdef MCU811E2
        #Warning MCU711E9 and MCU811E2 are both defined (defaulting to 711E9)
      #endif
      #Include 711E9.INC
    #else
      #ifdef MCU811E2
        #Include 811E2.INC
      #else
        #FATAL You must define either MCU711E9 or MCU811E2
      #endif
    #endif

    In the above example, if the programmer has forgotten to define either
    one of those symbols, the program will not be assembled further.  If you
    use an ERROR directive instead, the assembler will continue assembling
    but since neither INCLUDE has been processed, very likely there will be
    too many errors/warnings produced.  To avoid unnecessary errors/warnings,
    the programmer may choose to use FATAL instead of ERROR.  Note, however,
    that $FATAL will halt the assembler completely, not only for the current
    file.  So, if you were assembling a batch of files, the remaining files
    will not be assembled at all.

    NOTE: Keep in mind that case sensitivity affects all symbols, even those 
          used with conditional directives (except that symbols defined with
          the -Dxxx command-line option are always passed in the program as
          uppercase).

    Another directive is MESSAGE.  It works similar to WARNING but does not
    increment the warnings counter nor does it show in any error files.  It's
    meant for simply informing the user about something, eg, whether
    assembling with a given option or another, etc.

  ş Use the #PAGE directive to embed a Form Feed character (followed by a
    Carriage Return but no Line Feed) in the listing file, just prior to the
    line containing the $PAGE directive.  Although the Form Feed is enough
    for printing devices, the Carriage Return is added to make the listing
    file appear correctly when viewing it with a DOS program (while not
    changing the printer's behavior).

  ş MACROs are not supported.  However, some frequently used macros, such as
    PSHD and PULD are built-in and are activated when the X option is in the
    ON state (default).

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CONVERTING SOURCE FROM OTHER ASSEMBLERS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  Although ASM11 is a bit more forgiving with syntax than other assemblers,
  you should note the following when porting your source code to it.

  To convert source code to this assembler's likes, you should normally do 
  the following; this, however, is based heavily on the assembler for which 
  the source was originally written.  I have based my suggestions on AS11 (by 
  Mot), IASM11 (by P&E), and ASM(11) by Verschueren and Taphoorn (I think
  this is also called VACS, not sure).  This is not necessarily a complete
  listing of what you must do to convert your source, just what I could think
  off the top of my head.  Some other assemblers I have tried seem to follow
  the same general guidelines.

  ş For any of them (and others):

    ú Not a requirement, but you could combine all related consecutive FCB,
      FCC, and DB pseudo-instructions (even when they are mixed), since they
      are treated the same by ASM11.  This will often make your source code
      more readable and compact.

    ú Not a requirement, but you could recognize instruction sequences that 
      match one of the extra instructions provided by ASM11 and replace them 
      accordingly.  This might make your code more readable.

    ú Remove (or comment out) all assembler directives, listing formatters,
      etc. not recognized in the same way (or at all) by ASM11 or, where
      possible, replace them with ASM11's equivalents.  Of course, you should
      make sure the code will behave as it should.

    ú Symbol/Label length is 19 characters in ASM11.  Adjust your code
      accordingly if symbols used were longer than 19 or than what the
      original assembler allowed.  For example, IASM11 allows up to 16
      characters.  If two labels were defined of 19 characters with the first
      16 being the same but the remaining 3 being different, IASM11 would
      treat them the same, so a branch to either one would end up the same
      place.  However in ASM11, the two will be different labels, possibly
      one or both of them will give an error as being undefined.

    ú Make sure some of the not-so-common operators accepted by ASM11 (such
      as [ or ^) aren't used in a different context in the original source
      since the assembler for which that source was written could have
      different meanings for those very same non-standard operators.

    ú Assemble with -RTS- and -REL- to avoid warnings that are only meant for
      optimization.  Otherwise, you might get the misleading impression there
      is too much work converting the file to ASM11 syntax.

    ú If the original assembler allows spaces within/between expressions (and 
      also uses the ; character to denote the beginning of end-of-line 
      comments) you should assemble with the -SP+ option (or add the 
      #SPACESON directive at the top of the program).  This will not work
      correctly for code that uses both spaces and "free" comments.

  ş For IASM11:

    ú Make sure all assembler directives begin with either # or $ but not a 
      dot (if you intend to leave them in the source).  Dots are valid symbol 
      beginning characters in ASM11 but not in IASM11, so a directive 
      .INCLUDE (in column 1) will attempt to define a symbol by the name
      .INCLUDE and give you errors (since it most likely will be followed by
      a filename).

    ú If there are any $MACROs defined, comment them out by putting ; or *
      infront of each of the lines that define them.  Next, find each
      occurrence of the macro being used in the source file and replace with
      the corresponding instructions.  Note that some frequently used macros
      are PSHD and PULD which are recognized by ASM11 with the -X+ option.
      You would not have to replace those with the corresponding
      instructions, however, you should make sure they do exactly the same,
      since the author could have defined PSHD and PULD in reverse order
      which could produce different results in some cases.  The proper order
      is that used by ASM11 but people do write whichever way they like, so
      be careful in the conversion.

    ú I M P O R T A N T: If the $BASE 10T directive has been used at the top
      of the source (and nowhere else), skip this one.  Otherwise, you should
      add to all values that are plain numbers (ie., without radix
      indicator), the $ symbol infront of them to make them hex (because
      IASM11's default number base is 16).  This is important because the
      assembler cannot generate errors for numbers that are meant to be hex
      but are also valid decimal.  So, LDA #30 in IASM11 using the default
      base is equivalent to LDA #48 in ASM11, but since both are valid
      instructions, you won't get errors for that.  Your code will be
      functionally different, however.

    ú Make sure numbers don't end with Q, T, or H for binary, decimal, or hex
      but have the equivalent leading sign (ie., %, !, or $, although ! is
      optional).  If they are formatted with leading %, !, or $ instead,
      you're in luck; no change is needed.

    ú Expressions within { } may have to be rewritten.  Often, just removing
      the { } and any spaces between operands (or leave spaces and use the
      -SP+ option) will fix the problem unless precedence rules give
      different results, in which case a rearrangement is needed.  The same
      goes for parenthesized expressions.

    ú You may either leave the ; for end of line comments, or remove them.
      However, do not get carried away and remove them from lines that
      contain nothing but the comment because in those cases the ; is
      required.

  ş For AS11:

    ú Put commas between all operands of Bit instructions, ie., BSET, BCLR,
      BRSET and BRCLR.  Even if you forget, you will get an error message
      "Incomplete argument ..." with a hint to add commas.

    ú Check string or character constant definitions so that they are
      delimited with any of ' (single) " (double) or ` (back) quote but not /
      or any other character.

    ú Change all FCB #12 type statements to not include the # sign.  This
      assembler does not and will not support this syntax (it will produce a
      Syntax Error).  The # in the beginning of the operand is an indication
      of immediate addressing mode which for pseudo-instructions (such as
      FCB) does not make sense.

    ú Character constants should be treated as strings, ie., have both
      quotes.  So, change instructions like LDAA #'A to LDAA #'A'

    ú If I'm not mistaken AS11 understands LDA, LDB, CMPD, and some of those
      aliases, so if they have been used, rather than change them, just make
      sure you assemble with -X+ or $EXTRAON defined.

  ş For ASM(11):

    ú I haven't played with this one much, but from the little I did, I found
      out there isn't much you should change from a working program.  Only
      thing to be careful is that ASM(11) labels do not have to start on
      column 1 as in ASM11, so you should move them there if they are
      indented.  Then again, there may be significant differences that I'm
      not aware of.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
WHITE SPACE
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

ASM11's whitespace is any space (ASCII 32) or tab (ASCII 9) character.
White-space is ASM11's only delimiter between the various instruction
elements.

  ş Remember that spaces are used to separate labels from instructions,
    instructions from operands, and operands from comments.  Don't leave any
    spaces inside expressions or data lists (such as FDB 1,2,3,4), or else,
    the ones after the first space will not be recognized and you will not
    receive a warning or error because they are viewed as comments.

    If you *must* have spaces inside expressions, use the -SP+ option or the
    #SPACESON directive.  If you use this, any comments following *must*
    begin with a ; if the combination of the first comment "word" (non-blank
    entity) and the previous "word" could be viewed as part of the same
    expression or data list.  For example:

          FCB       1, 2, 3, 4     COMMENT WITHOUT SEMICOLON
          FDB       1, 2, 3, 4 +   ;COMMENT WITH SEMICOLON

    The first one does not need semicolon for the comment because 4 isn't 
    related to COMMENT in any way (by comma or an operator).  The second 
    needs the semicolon for the comment (in order to catch the error) because 
    the + expects another operand, so without the semicolon the immediately
    following word COMMENT is viewed as a symbol (possibly non-existing).  If
    COMMENT happens to be a defined symbol, this will be equivalent to 4 +
    the value of the symbol (and you will never notice the error).

    It's recommended to start end-of-line comments with a semicolon in every
    case *if* you plan to use the -SP option (or #SPACESON directive).

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DOS ERRORLEVEL CODES
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş The assembler returns a DOS errorlevel of zero when no errors have
    occurred (regardless of warnings).  The errorlevel returned to the parent
    program that called ASM11 (if not used from the command line, this would
    normally be a batch file or an IDE) based on a 5-code system where:

    0 means no errors/warnings
    1 means system error (such as disk failure)
    2 means Assembler Error
    3 means Assembler Warning, and
    4 means Usage Screen/No Assembly.

    Most programmer IDEs will catch this return code and report the existance
    of errors (based solely on the fact it is non-zero), but of course they
    won't know where or what kind the errors were.

    If your IDE has such capability, assemble with -E+ always, and make the 
    IDE display the *.ERR file on failure (or leave -E- and, instead, use 
    redirection to send errors to whatever file your IDE expects to contain
    them).  Some IDEs will automatically redirect standard output to whatever
    file they like (so you won't have to do anything special to make them see
    the error file).

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MISCELLANEOUS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

  ş ASM11's official web page is at http://www.aspisys.com/asm11.htm

  ş At the time of this writing (Oct. 1999), ASM11 is over a year old.  
    Besides heavy use by myself, hundreds of others have also been using this 
    program and from the zero number of problem reports in the last months, 
    it appears that it has no serious problems (ones that someone would 
    bother to report).  Since most programs of this kind are rarely ever 100%
    bug-free, you may happen to find a bug yourself before I do.  If you do,
    no matter how important or not you think it is, please report it.  The 
    fix will help us all.

  ş Anything that ASM11 displays on screen it does so through a new file
    handle it creates at startup that it associates to the screen.  This
    means that redirecting the screen display to a file isn't possible.
    Besides, because of the extra CRs used for keeping the progress line
    counter from scrolling, the resulting file would be a mess!  Only error
    messages may be redirected (in addition to creating *.ERR files, if the
    -E option is active).

  ş The # and $ symbols as the very first non-blank characters of a line
    indicate an assembler directive.   Unrecognized directives will produce
    warnings and will be viewed as comments.

  ş About the extra mnemonics: Some of them I just couldn't live without.
    Having worked with 6809 for many years, LDAA or STAB didn't "feel" right
    to me (it's a personal thing).

    If you feel you have thought of some useful extra that I haven't 
    included, let me know.

  ş If, for some reasons, you must make your code more compatible to other 
    assemblers, make sure, as a first step, you use the -X option in the OFF 
    state (-X-) when assembling to flag out all "accidental" uses of extra 
    instructions, then replace them with their standard equivalents.  If you 
    have embedded an #EXTRAON directive anywhere in your source (even in an
    included file), you should remove them also before checking with the -X-
    option because embedded switches always override their command-line
    counterparts.

  ş You may find that trying to assemble code that assembles OK with ASM11
    (with the -X- option) will *appear* to assemble OK with other assemblers.
    However, if you intend to make your code compatible to as many assemblers
    as possible (something I do for certain subroutines I wish to share with
    others), I urge you to check each assembler's listing carefully because
    it has been my experience that some assemblers out there don't produce
    errors for what they can't understand, but simply assume what they like
    (if you find I'm guilty of this also, please let me know, and I'll try to
    fix it).  I could give numerous specific examples, but I do not wish to
    be thought of as offending other people's work.  (By the way, don't
    expect to make all programs compatible to all assemblers at the same
    time, it's not possible but for the most trivial programs).

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
VERSION HISTORY (INCLUDES SOME INFORMATION NOT FOUND ELSEWHERE IN THIS DOC)
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

When reading the history, keep in mind that what's said for any given version
was written at the time that version was prepared and, therefore, ASM11 may
have been altered in a following version and, thus, operate in a vastly
different manner for a specific issue.  So, read the whole history (starting
perhaps from the end) if you're unclear about what the current behavior is.

  1.00Alpha ş Original.

  1.01Beta  ş Added CMPD extra for CPD equivalence.

            ş Added CLX to clear the X flag.

  1.02Beta  ş Allowed strings to be delimited by any of " ' or ` rather than
              just '. Note, however, that what starts a string must also end
              it.  No mixing of delimiters is allowed, or else there would be
              no point in having more than one.

  1.03Beta  ş Added listing creation capability (*.LST)

  1.04Beta  ş Made "Division by zero" errors appear only on PASS2.

            ş Changed RMBs to show both address and number of bytes in the
              listing.

            ş Changed all pseudo's values to display indented on column after
              address.

            ş Removed erratic value display from END pseudo-op.

            ş Added warning for not using DIRECT mode addressing where
              possible.  Please note that this particular warning will only
              appear in the *.ERR file.  This is because the assembler does
              not automatically use direct mode addressing but requires the
              use of the @ or < direct mode designators.  This will result in
              excessive amount of warning for this one reason when assembling
              certain files.  So, if you want to see where you may use direct
              mode, turn on the *.ERR file with the -E+ option, assemble the
              file(s), and have a look at the corresponding *.ERR file(s).
              To make the warning(s) disappear, edit the source file and add
              @ or < signs infront of the direct mode address symbols or
              values.

            ş Moved Warning about 16-bit operand with 8-bit instruction to
              *.ERR file.  If you must see these warnings, turn on *.ERR
              production with the -E+ switch.  This move was done because
              this warning is highly unlikely to lead to undesirable results
              and it comes up quite often for certain programs.  (NOTE: This
              change was reversed in a later version.)

  1.05Beta  ş Added even length S19 records.  Before this version, S19
              records held one instruction's worth of code each making the
              resulting file look jugged edged.

            ş Added cycle counts in *.LST files.

  1.06Beta  ş Added XGAB pseudo-instruction for swapping the A and B register
              contents.  Quite a useful instruction, I'm surprised it wasn't
              part of the 68HC11 instruction set.

  1.07Beta  ş Added error on numbers greater than 16-bit, such as 65537.

            ş Added warning for having used JMP or JSR where a BRA or BSR
              would also work.  This helps you optimize your code by
              replacing JMP with BRA and JSR with BSR where appropriate.
              Note that you will not get a warning for direct mode JSRs since
              direct mode JSRs actually have better performance than BSRs,
              having the same instruction length (2 bytes) but being 1 cycle
              faster (5 instead of 6).

              Note that you should worry about this optimization near
              completion of your program to avoid unnecessary changes back
              and forth, as even a single command changing from direct to
              extended mode or the reverse could influence the use of jumps
              versus branches.

  1.08Beta  ş Changed phasing error values to display in hex (not decimal).
              The decimal display was not intentional, I had just forgotten
              to convert to hex.

            ş Added CMPX and CMPY extras (there already was a CMPD).

            ş Added symbol checking for operators inside symbols.

            ş Fixed deleting upon error or ESC of enabled files only as per
              documentation.

            ş Added warning for expressions that result in greater than
              16-bit numbers.

            ş Added warning for missing first operand in expression, except
              when the operator is either a + or - (unary operators).

            ş Moved warning about 8-bit and 16-bit instruction/operand
              mismatch to always display on the screen (not just the *.ERR
              file as was done in version 1.04Beta), and corrected for
              negative numbers.  Since this warning will not show up quite as
              much anymore, it was moved to display on the screen as well
              (reversing 1.04Beta change).  It used to display even for small
              negative values, such as -1 causing too many warnings when long
              tables with negative values were used, to mention one example.

            ş Shortened symbol length from 30 to 19 characters to preserve
              memory in favor of larger overall symbol tables and better P&E
              map file compatibility.

            ş Added recognition of < and > for DIRECT and EXTENDED addressing
              mode overrides.  This was done for compatibility with other
              assemblers, and because it's been a Mot standard for a long
              time.  You no longer have to remove these from existing code.

  1.09Beta  ş Based on Mark Schultz's suggestion, I changed the command
              filename parser to accept any extension for source file names,
              with one restriction: extensions that are the same as those
              used for output files by ASM11 (ie., S19, LST, MAP, and ERR) as
              well as blank (no extension) will be ignored and the
              corresponding matched files will be skipped.

            ş Because of the above change, I also extended switch -R's
              functions to accept an extension to be used as default.  This
              option will make sense only if followed by -W to be made the
              new default, otherwise, you could simply give the new extension
              on the command line as part of the file specification.  The
              extension *must* start with a dot and be up to three characters
              long (standard DOS extensions).  Longer ones will be downsized
              to three characters.

            ş Added listing file header with file name, assembler version,
              date, and footer with end-of-listing marker.

            ş Removed warning for not using direct mode when extended was
              explicitly declared (by prefixing with the > sign).

  1.10Beta  ş Optimized symbol table functions a bit to make overall
              performance faster (the difference will only show on
              multi-thousand line code).  Still needs a lot more optimization
              (or better yet, a complete rewrite but I don't have the time
              now, maybe after the summer).  This change unfortunately
              introduced a nasty bug (but highly unlikely to show up), which
              was corrected in version 1.12B.

            ş Added symbol/label check for embedded string delimiters.

            ş Added CTRL-BREAK handler to exit more gracefully.  Pressing Esc
              now prints ** Cancelled ** message.

            ş Added option -EH (Errors Hidden) to send errors only to *.ERR
              file when -E+ is activated.  This option has not effect when
              -E- as errors will be displayed on the screen.

            ş Added code/data/image size counters at the end of the listing.
              Useful for knowing how much space you program needs, these
              counters display in decimal, hex, and KBs.

            ş Allowed multiple separate filename specs, eg. ASM11 file1 file2
              file3 ... where each file? is a mask with one or more elements
              as before, eg., ASM11 ,.A11 TEST OS11,OSTEST

            ş Fixed a little glitch with filename parsing that caused
              needless mismatch messages to show up.

  1.11Beta  ş Fixed operand label comparison for longer than 19-character
              labels to not produce an error unless there is really a
              collision on the first 19 characters only, as per
              documentation.

            ş Fixed MAJOR bug with LSRD instruction producing wrong opcode
              (05) instead of 04.  My sincere thanks to Mark Schultz for
              reporting this.

  1.12Beta  ş Fixed a nasty bug introduced with the optimization of version
              1.10B which, fortunately, would only show in small (mostly
              test-type) programs that had not even one symbol definition
              (highly unlikely for most programs).

            ş Added closing of files on ESC or error exit before erasing
              files to avoid lost clusters of incomplete files.  Although you
              could get lost clusters when doing a chkdsk afterwards, this
              bug was actually harmless (it's as if power was lost while
              writing to a file that was to be thrown away, anyway).

            ş When MAP creation is off, symbol table can now hold many more
              real symbols (rather than source line information), thus, for
              extremely symbol rich programs you won't run out of heap memory
              (at the cost of not getting a MAP file which in any case for so
              many symbols I have found that the programs that are supposed
              to use them can't handle such large MAP files; actually they
              can't handle many large MAP files long before ASM11 runs out of
              heap memory.)  I haven't managed to run out of heap memory
              while assembling actual programs, only with specifically
              enlarged test programs with several thousands of lines.

            ş Changed line number incrementing from every 50 to every 100
              lines (to reduce number of screen writes).

            ş Added & operator for bitwise AND operation.

            ş Added | operator for bitwise OR operation.

  1.13Beta  ş Added $INCLUDE file processing.  Upto 49 files may be included
              (+1 the main file) for a total of  99 files.  Nesting level
              isn't relevant (ie., all 49 include statements could be one
              inside the other), but if INCLUDEs are nested, the FILES
              statement in CONFIG.SYS should hold an appropriate value so
              that DOS (not ASM11) can handle that many open files at the
              same time.  If they are not nested, the FILES statement can be
              as little as 10 or so (whatever value works for a single file
              assembly), since each INCLUDEd file will be closed before
              another one is opened.

            ş Added $MAPON and $MAPOFF directives.  These are used for
              turning source line number information on and off,
              respectively.  Turning map info off for certain sections of
              code you know to work well, allows you to step over them when
              doing the SS command.

            ş Added $LISTON and $LISTOFF directives.  These turn listing on
              and off, respectively.

  1.14Beta  ş Corrected use of quotes in INCLUDE files.  Some combinations
              didn't work right.  It worked OK if used without any quotes.

  1.15Beta  ş Corrected a small error reporting glitch that would show
              irrelevant error messages on exit (not related to assembly, but
              to system problems, such as Disk drive not ready) if there were
              errors during assembly.  You see, I was returning the line
              number if there were errors, but unfortunately, I did this
              before checking for actual system errors, not after.  Fixed by
              setting the line number exit code after DOS-type errors were
              checked.  Anyway, for those who worried about something being
              wrong with their system, most likely, there wasn't; the
              messages were just playing jokes with you!

            ş Added ^ operator for bitwise XOR

            ş Changed message 'Operand ... could not be evaluated' to
              'Undefined symbol "..." or bad number' in an attempt to make it
              more meaningful.

            ş In listings, separated address word from first code/data word
              columns with a colon (:) to aid in quickly identifying the two.

            ş Changed ERR! to ERR* in the beginning of error messages.  The *
              character is more visible than the ! and makes it easier to
              stand out from a series of surrounding WRN messages.

            ş Added optional creation of *.SYM file.  This file is not sorted
              in any way, it is simply a dump of the internal symbol table
              with no header or other extra information.  This was done as a
              temporary solution to those who wish to have this information
              for use by tools that don't understand P&E map files, or
              utilities that can create other types of MAP files by using
              this info.  Symbols begin in column 1 and corresponding hex
              values in column 21.  You can sort the table with DOS sort (or
              my BSORT utility, using the command BSORT .SYM to sort by
              symbol name or BSORT .SYM -22 to sort by value, assuming the
              format is -LSS, not -LSE, see v1.47 changes).

            ş Added ~ operator to swap the high and low bytes of the
              immediately following value or symbol.  Note that is a unary
              operator that has precedence over standard operators, such as
              +, -, *, etc.  Example: LDX #~$1234 will do LDX #$3412

            ş Added [ operator to get the low byte of the immediately
              following value or symbol.  Note that this is a unary operator
              that has precedence over standard operators, such as +, -, *,
              etc.  Example: LDA #[$1234 will do LDA #$34

            ş Added ] operator to get the high byte of the immediately
              following value or symbol.  Note that this is a unary operator
              that has precedence over standard operators, such as +, -, *,
              etc.  Example: LDA #]$1234 will do LDA #$12

            NOTE: For obvious reasons (to me at least), ~, [, and ] may not
                  be used at the same time.  Only one of the three may be
                  used for any given value.  Using more than one doesn't make
                  sense, anyway, and having used one, the assembler will not
                  recognize the others, it will just look at them as
                  characters in a probable symbol or number, producing
                  appropriate errors.  [ and ] produce 8-bit values so they
                  definitely don't go along with ~ which swaps the high and
                  low bytes of a 16-bit value.  Furthermore, you either want
                  the low or the high, not both, so [ and ] together are not
                  allowed.

  1.16Beta  ş Fixed the missing name problem from long include filenames or
              paths.

            ş Added the -Tn switch for setting listing tab size to n.

            ş Because of the above switch, also added $TABSIZE directive to
              force a certain tab size from within the source, overriding
              whatever -Tn says.

            ş Added stdout redirection.  This will be used to send warning
              and error messages, regardless of the -E switch setting (or any
              other settings), to a file of your choosing by using standard
              DOS redirection.  The warnings and errors in this file will be
              for all files processed and each message will show the full
              path of the corresponding file that has the problem.  This was
              added to facilitate some smart IDEs to capture full filename,
              error message, and line number from any file they require.
              Note that redirection does not in any way affect the normal
              behavior of ASM11, in other words, it's completely transparent.

  1.17Beta  ş Added Tab expansion for source code before parsing to avoid
              problems with tabs inside strings that were put there by the
              editor.  This change means that if you actually want a tab in a
              string, you must break the string and add the value 9 (TAB).
              In other words, the TAB must be treated as you would a CR or LF
              character.  If, because of how tabs were handled until now, you
              had put tabs inside strings with the purpose of using them as
              tabs, you will have to modify your strings to explicitly
              declare tabs.  For comparison, AS11 will read tabs inside
              strings as actual tabs without expanding them first, like ASM11
              did until now.  However, this is not desirable, especially for
              tab sizes other than 8.

  1.18Beta  ş Removed possible comments on INCLUDE line (following the
              filename).  This used to disrupt the display of the filename a
              bit and would not recognize a filename if there was a dot in
              the comment (otherwise, it was not a problem).

            ş Added warning for using unlabeled EQUs.  Until now, an EQU
              without a label would be silently ignored.

            ş Fixed $TABSIZE to reset to its default value at the start of
              each new main file processed.

            ş Re-enabled end-of-listing report and closing message even if
              the $LISTOFF directive was used last.

            ş Fixed problem with End-of-file include not being processed.

  1.19Beta  ş Added display of filename on first line in addition to every
              100 lines, so that even the smallest files will have their
              names displayed (albeit in a flash).

            ş Added $CASEON and $CASEOFF directives to control from within
              the source the setting of switch -C.  Normally you could give a
              $CASEOFF (or $CASEON) at the beginning of your source to make
              sure others assemble it correctly.  You may even turn on/off
              this setting within the same source, if you happen to borrow
              code from others, or simply need to use case-sensitive assembly
              only in a portion of your code.

            ş Added $EXTRAON and $EXTRAOFF directives to control from within
              the source the setting of switch -X.  Normally you could give a
              $EXTRAOFF (or $EXTRAON) at the beginning of your source to make
              sure others assemble it correctly.  You may even turn on/off
              this setting within the same source, if you happen to borrow
              code from others, or simply need to use the extra instructions
              only in a portion of your code.

            ş Made the Direct Mode warning (the one that only goes to the
              *.ERR) to also go the stdout redirected file.  This change was
              done to make previous documentation look correct :)

  1.20Beta  ş Corrected lack of error reporting on empty strings.

  1.21Beta  ş Added error for forward definitions on RMBs.

  1.22Beta  ş Of course, I had to forget to include the DS in doing v1.21B
              change, just to have to come up with a new version to fix that!

  1.23Beta  ş Fixed bug with Y indexed Bit instructions giving errors when
              they shouldn't.

  1.24Beta  ş Changed ERROR of version 1.21B/1.22B to a WARNING.  However,
              this warning should be taken seriously as in some cases it
              indicates that wrong code has been produced.  The change to a
              warning was done because in many situations, the code produced
              will be correct.

            ş Added SB2ASM11 utility for making SBasic output compatible to
              ASM11.

            ş Added source example MULTBOOT.ASM for re-burning OTPs.

  1.25Beta  ş Added LBRA and LBSR extra mnemonics (built-in macros).  These
              will not show on the help screen because they are too big to
              fit.  Please note that LBRA and LBSR translate to a relatively
              long series of bytes that does not justify casual use.  They
              are only meant to provide a means for making your code
              relocatable (even if you have a widely spread loop that normal
              branch instructions won't cover, etc.).  They should not be
              used whenever you get the ERROR message that advises you to use
              a jump instead of a branch.  If you still must use relative
              addressing, trying adding "jumper points" to your program.

  1.26Beta  ş Optimized the code produced by the newly introduced macros,
              LBRA and LBSR.

  1.27Beta  ş Several internal changes that relate to symbol table handling.

            ş Automatic determination of Direct Addressing Mode use.

            ş Allowed message "Direct mode wasn't used" to show on screen
              (because of the change regarding the auto use of direct-mode it
              now will not be as frequent a warning as before).

            ş Added quotes around labels in Forward/Backward branch messages.

            ş Changed message displayed by forward definition on RMB to
              something more alarming (because this warning is actually an
              error in many cases and the code produced might be wrong, eg.
              JMP going the wrong place, etc.).  PLEASE (for your own peace
              of mind) take this warning *very* seriously and make sure you
              understand where it originates and how surrounding code may be
              affected.  Better yet, avoid forward references on RMB/DS
              pseudo-instructions, altogether.

  1.28Beta  ş Added recognition of END label address (if used).

  1.29Beta  ş Fixed Auto Direct Mode error for some situations.

  1.30Beta  ş Fixed map line for non-code lines.  It used to work, and
              sometime I inadvertedly messed it up, so it's back to normal.

  1.31Beta  ş Added directive $S19FLUSH to control when to break S19 files.
              Useful because some other assemblers wrongfully break the S19
              file when encountering an ORG even if the addresses are
              sequential.  The $S19FLUSH lets you control where to break the
              S19 so that you may better check the resulting S19 for equality
              to one produced by another assembler.  (BUF34.S19 from Mot is
              an example of this).

            ş Updated the help screen to correspond to current version.

  1.32Beta  ş Minor fixes here and there.

            ş TERM.EXE program updated with a couple of minor fixes.  It now
              allows uploading even in non-EVBU mode (without the LOAD T).

  1.33Beta  ş Added support for (nested) conditionals assembly.  New
              directives are: $IFDEF, $IFNDEF, $IFZ, $IFNZ, $ELSE $ENDIF

            ş Added directives for user induced warnings and errors
              (often useful in conditional assembly).  New directives are:
              $WARNING and $ERROR

            ş Re-arranged help screen to acommodate information about these
              and other directives.

  1.34Beta  ş Fixed nested conditional handling and also fixed so that other
              directives following the conditionals.

  1.35Beta  ş More fixes for nested conditional handling.

  1.36Beta  ş Added IF, a two-expression conditional for comparing
              expression1 and expression2 with any of these:
                              =, <>, <, >, <=, >=

  1.37Beta  ş Added FATAL directive, same as ERROR only halts assembler.

            ş Moved error about "Symbol does not begin with ..." to PASS1

            ş Fixed problem with $ERROR recognized even inside false
              directive.

  1.38Beta  ş For consistency, disabled .labels from being allowed to be
              indented.  This was not a bug (code would assemble correctly),
              just a deviant behavior that allowed one to indent label
              definitions starting with a dot (which one could not do with
              other non-dot-starting labels).

            ş Added updated versions of the example programs in a ZIP file.
              Also, added some new examples.

  1.39Beta  ş Added S0 record creation option (-SH).  Some people were having
              problems with their systems not accepting S19 files with
              missing S0 records.  The default is OFF for backward
              compatibility.

  1.40      ş First Non-Beta Version.

            ş Added option -MTx for defining one of two source-level Map
              Types.  x can be either P for P&E compatible map file, or A for
              my own ASCII version of the map file whose format is
              self-evident, and can be used by third parties willing to
              support this freeware assembler.

            ş Added OSW extra mnemonic.  Similar to the OS extra but with a
              word immediate value (instead of OS's byte value).

            ş Added $OPTRTS directive for producing warnings on JSR/BSR
              followed by an unlabeled RTS which could be optimized to JMP or
              BRA, respectively.  This will only work after the $OPTRTS is
              encountered.  The command-line equivalent option for this
              directive is -RTS (not shown on the help screen).  Please note
              that the JSR/BSR must be immediately followed by an RTS to
              produce a warning.  Even a blank line in between the two will
              not produce the warning.

            ş Added "Branch too far forward/back" message offsets to know
              exactly how many bytes away the target address is.  The offset
              is displayed in decimal.

            ş Optimized memory usage when no $MAPOFF or -M- are in effect.

            ş Added PDF Quick Reference Guide (thanks to Mark Schultz for
              coming up with the idea and preparing it).

  1.41      ş Added "RESUMING FILE ..." message when closing an include in
              the LST file.

            ş Added pseudo-op FCS (Form Constant String) which is equivalent
              to FCB with an added zero last value (eg. FCB 'Hello World',0
              may be written as FCS 'Hello World').

            ş Added "Reserved ..." warning message for $MAP directive.  This
              will be used in final versions to provide support for
              high-level language source-level debugging.

            ş Added warning message for unrecognized directives.

  1.42      ş Added a few extra lines of statistics at the end of the LST
              file.

  1.43      ş Corrected v1.42 addition for certain special cases.

            ş On request, I removed the $ infront of the hex value in the SYM
              files.  This was causing some incompatibility with third party
              software.  The column positions are still the same, for
              compatibility with previous versions.

  1.44      ş On request, I added the OPTRTSON/OPTRTSOFF for controlling the
              -RTS option (for enabling/disabling JSR/BSR followed by
              unlabeled RTS optimization warnings) from within the source.
              The OPTRTS has been removed.  Its function is now performed by
              OPTRTSON.

            ş On request, I added the OPTRELON/OPTRELOFF for controlling the
              -REL option (for enabling/disabling JMP/JSR to BRA/BSR
              optimization warnings) from within the source.

  1.45      ş Added display of actual branch address in the LST file in
              parentheses.

            ş Changed : address/code separator to + for RMB lines to
              differentiate between code and RMBs.

            ş Changed : address/data separator to . for all data producing
              pseudo opcodes, such as FCB, FCS, DB, etc., to differentiate
              between code and data.

  1.46      ş Changed return code from line number (which could not be
              grabbed correctly by many programs) to 0=No Error, 1=System
              Error, 2=Error, 3=Warning, 4=Usage/No Assembly.

            ş Added $IFEXISTS and $IFNEXISTS directives for checking if a
              file (normally an include file) exists before using the
              $include directive (or for other creative purposes).

            ş Changed the fatal type of error that would halt the assembler
              when an INCLUDE could not be opened to a regular error.  The
              previous function can be emulated with a combination of the
              newly introduced $IFEXISTS/$IFNEXISTS directives along with the
              $FATAL directive.  The change was done so that an INCLUDE not
              found does not automatically stop the assembler when there are
              more files to process.

            ş Added report of Number of Lines in Listing file.

            ş Added report of Number of Include files in Listing file.

            ş Added $MESSAGE directive.  Similar to $WARNING but does not
              count warnings, nor does it show in error files.

  1.47      ş On request, I added the -LSx option for setting one of two
              types of SYM files.  -LSS is the default (used in previous
              versions) and -LSE is for the EM11 emulator.

            ş Changed Error for not being able to open include file to
              display only on Pass 1.

  1.48      ş On request, I added the -SP option for controlling whether
              spaces are allowed within expression operators and comma lists
              (such as in FCB).  The equivalent directives for controlling
              this from within the source are $SPACESON and $SPACESOFF.  The
              default is OFF for compatibility with previous versions.

              Be forewarned, however, that using the -SP option (or $SPACEON 
              directive) in existing code that assembles OK without it, will 
              most likely produce a lot of errors/warnings.  For example, all 
              EQU * type statements that are followed by comments (that do 
              not begin with semicolon) will give errors, etc.

            ş Added the $PAGE directive for telling the assembler to skip to
              a new page in the listing file (only).  It simply embeds a Form
              Feed character (followed by a Carriage Return but no Line
              Feed).

            ş Moved "Incomplete arguments..." error to PASS1 where it
              belongs.

  1.49      ş Fixed lack of error/warning reporting for comma lists with
              missing in between values.

  1.50      ş Fixed.  In DB/FCC/FCB/FCS pseudo-instructions, any string
              constant *expressions* would produce wrong data with the
              warning "missing string delimiter".  The following two DBs show
              what the correct (first) and wrong (second) expressions were.
              DWs were not affected by this.  Now both expressions work as
              expected.  A string (longer than 2 characters or 16 bits)
              cannot be part of an expression and you will get appropriate
              warning about mismatched sizes.

               D000.D2                       db        $80+'R'
               D001.5227 2B24 3830           db        'R'+$80 ;WRONG (FIXED!)

            ş Disallowed the colon (:) to be part of a label (except at the
              end, where it is ignored).

  1.51      ş Adds :n repeater (1 <= n <= 32767).  For example, NOP:3 will
              produce three consecutive NOPs.

  1.52      ş Added switch to produce Turbo Pascal (-T[ñ]) style errors for
              redirected errors only.

            ş Added switch (-Q) for Quiet mode (suppress screen output) on
              redirected messages only.  Has no effect when not using
              redirection.

  1.53      ş Added $ROM, $RAM and $DATA directives for using segments.
              Their use is optional.

  1.54      ş Corrected $RAM and $DATA to actually default to $0000

  1.55      ş Fixed erroneous error-reporting with END ;COMMENT statements
              (when there is no expression).

            ş Added -Dxxx option for defining upto 10 symbols for use with
              $IFDEF directives.  All symbols assume the value ZERO.  Sample
              usage: ASM11 -DDEBUG MYPROG will run MYPROG with the symbol
              DEBUG defined.  All symbols are defined as uppercase regardless
              of how they are supplied or the -C switch setting.

  1.56      ş Added local (per main/include file) symbols.  Local symbols
              begin with a ? and otherwise follow the same rules as any other
              symbol.  So, ?LOOP is local to whatever file it is found.

  1.57      ş Fixed bug introduced in v1.56 with local symbols not working
              properly in $MAPOFF mode.

  1.58      ş Optimized certain search routines resulting in a 130-180%
              (depending on source style) increase in assembly speed.  No
              functional changes.

  1.59      ş Added RORD and ROLD extra mnemonics for Rotating D right and
              left.

            ş Increased the number of include files from 49 to 99 (for a
              total of 100 files).

            ş Improved included utility TERM.EXE by adding user-definable
              delay for uploading.

  1.60      ş Added -Ix option for defining a default INCLUDE root directory.
              Any relative include file specification (one that does not
              include a drive letter or beginning \ or /) is first tried in
              relation to the main file (as was the case until now) and if
              not found there, it is tried again on the default include
              directory root (if one is defined).  Relative paths will still
              work if used, only under the predefined INCLUDE root.

            ş Added "Total RAM Size" report at end of listing.  This will
              display the total number of bytes defined using either the RMB
              or DS pseudo-opcodes.  It will not account for RAM used
              directly in instructions or via EQU statements.  Only memory
              defined with either RMB or DS will be counted in this total.

  1.61      ş Fixed lack of error in label definitions that contained commas.
              You couldn't possibly use such a label, but you could define
              it.

            ş Added one space after ERR*/WRN/MSG in screen and .ERR files.
              If you have setup your IDE to grab the message from fixed
              locations, you'll need to re-adjust that.

            ş Added recognition of comments after $IFxxx directives.  They
              used to cause a FALSE action (without warning).  This was
              documented but undesirable.

            ş IF(N)EXISTS now also checks the -Ix set directory (if any)
              before deciding TRUE or FALSE.

            ş Added directive $IFINCLUDED which is true when the file in
              which it is located is used in an INCLUDE statement (regardless
              of the nesting level).  Makes it possible to write a module
              that will compile both independently and/or included in a
              larger program.  This is the opposite of the $IFMAIN directive.

            ş Added directive $IFMAIN which is true when the file in which it
              is located is the primary (main) file assembled.  This is the
              opposite of the $IFINCLUDED directive.

            ş Changed $DATA segment's default value from $0000 to $B600
              (711E9's EEPROM).

            ş Added directives $PUSH and $PULL for saving and restoring
              (respectively) the state of the following options: $MAPx $LISTx
              $CASEx $EXTRAx $SPACESx $OPTRTS $OPTREL $TABSIZE

              This is useful for included files that want to change any of
              these options and then restore the original options used by the
              higher level file.

            ş Added option -WRN[ñ] for controlling whether warnings should
              display or not.  This option overrides all local warning
              options, such as -REL and -RTS.  If -WRN is off, none of the
              warnings will be displayed.

            ş Changed back to ERRORs the use of forward references in RMB/DS
              pseudo-ops.  It used to be a WARNING but because of its
              seriousness and of the new -WRN option to ignore warnings, this
              has to display even when Warnings are off.

            ş Added check for -Ix directory name to not be longer than DOS's
              allowed length.

            ş Updated some of the included example code.

  1.62      ş Fixed bug with INCLUDE statements without the required filename
              trying to read from standard input instead of giving error.

            ş Added "Number of instructions" in listing file's report
              section.

  1.63      ş Minor change.  Changed an error message for consistency with
              other related messages.

  1.64      ş Removed duplicate error message from EQU and ORG using
              undefined symbols.

            ş Added option -P[ñ] for stopping assembly of a file at the end
              of Pass 1 *if* there were errors (not affected by warnings).
              This speeds up the write/assemble/correct cycle in the initial
              stage when we get the syntax errors out because Pass 2 is
              skipped completely.

            ş Several errors were moved to Pass 1 where they belong.

  1.65      ş Added Warning about S19 overlap.

            ş Added option -O[ñ] for controlling the above warning.  The
              default is off for backward compatibility but you would most
              likely want to turn this on with -O+ and save it with the -W
              command.

            ş Updated included utility TERM.EXE by adding option -H for hex 
              mode display of received characters.  Useful in debugging 
              devices.

  1.66      ş Added directive $MEMORY for defining memory ranges of code/data 
              space.  Useful for being given a warning when assembling code 
              in non-existing memory.  Specially useful for devices with 
              non-contiguous blocks of memory.  Its use is optional.  Example 
              usage:

                    EEPROM   EQU  $B600

                    $MEMORY   EEPROM EEPROM+$1FF  ;11E9 EEPROM range
                    $MEMORY   $D000 $FFFF         ;11E9 (E)PROM range
                    $MEMORY   $103F               ;11E9 CONFIG (single value)

              You may use the MEMORY directive as many times as you like.  
              Ranges specified may overlap in different MEMORY directives.  
              High and low values may be specified in any order.  You may use 
              normal assembler expressions for range values.  Any symbols 
              used in expressions must be defined before reaching this 
              directive but this is not a problem because (read next 
              paragraph).

              You may place the MEMORY directive anywhere in the code.  It 
              doesn't have to appear before code starts.  MEMORY sets up the 
              ranges in Pass 1 but will check the whole code (even that which 
              appears before it) for violations during Pass 2.  So, you could 
              place #MEMORY at the very end of your program or the very 
              beginning, it won't make a difference.

            ş Added Warning about violating the MEMORY directive's range(s).
              This warning is controlled by the -O switch that also controls
              the S19 overlap warning.  If no MEMORY directive is ever used,
              no warning will be issued (as if $MEMORY $0000 $FFFF had been
              used).  This keeps it compatible with existing source code.

            ş Options -P and -O now default to ON

            ş Added directives SEGn (where n is 0 through 9) for defining
              segments.  This is in addition to existing RAM, ROM, and DATA
              segments for a total of 13 segments.  All SEGn segments default
              to $0000 address.

  1.67      ş Fixed a small bug with S19 overlap detection that didn't detect
              overlaps when wrapping around from $FFFF to $0000 in all cases.

  1.68      ş Added $VECTORS segment directive with a default value of $FFD6.

            ş Re-arranged help screen so that options line up for easier
              viewing.

            ş Fixed a minor and hard-to-reproduce bug with $IFDEF without
              arguments running differently based on current random memory
              contents.

  1.69      ş Optimized LBSR and LBRA code for a 2 byte/7 cycle reduction in
              each.  I was using a redundant PSHA and PULA in each sequence.

            ş Changed line counter from every 100 to every 256. Minor
              speedup (due to compiler's shift optimization).

            ş Removed "Syntax Error" from "Bad xxx instruction/operand"
              errors.  This would cause two errors for each bad instruction.

  1.70      ş Fixed: Missing error with binary null numbers %

            ş Changed: Same message for BRset/clr as for Branch

            ş Changed: no "trailing comma.." message when no operand

            ş Changed: "empty string..." situation in FCB, FCS, etc.

            ş Changed: binary number not counting leading zeros for 16 digit
              limit.

            ş Changed: Phasing errors will only show in Pass 2

            ş Updated ASM11.DOC with error and warning message descriptions.

  1.71      ş Added: Quick report of total bytes produced on screen

            ş Changed: Moved "No ending string delimiter.." to Pass 1

  1.72      ş Fixed: *100 pattern was misinterpreted as a hex value when * is
              the first character of the operand.

  1.73      ş Fixed: What I thought I had fixed in v1.68 with #ifdef without
              any arguments giving misleading warnings on occassion,
              hopefully, this time it's really fixed!

  1.74      ş Added: Extra mnemonics. Jump equivalents for all conditional
              branches.  Specifically, JCC, JCS, JEQ, JGE, JGT, JHI, JHS,
              JLE, JLO, JLS, JLT, JMI, JNE, JPL, JVC, JVS

            ş Changed: Warning message "JMP/JSR .." made more general to
              reflect the added mnemonics.

  1.75      ş Added: Summary for segment usage in the .LST (listing) file.

            ş Changed: "Missing Branch Offset" to "Missing Branch Address"

  1.76      ş Fixed: Jxx extra mnemonics not giving warning about using
              branch in backward branches that were within three bytes of the
              branch limit.

  1.77      ş Fixed: ORG fix of v1.64 introduced a new problem which is fixed
              now.

  1.78      ş No functional changes.  A change in the symbol table handling
              that cuts assembly time in half or less for large programs
              (like BUFFALO).

            ş Date/time stamp in .LST header corrected for noon (now shows
              PM) and midnight (now shows 12, not 0).

  1.79      ş Added warning for Branches and Jumps (except, of course, for
              BSR/JSR) that refer to the immediately following instruction.
              Such branches and jumps are redundant and can be removed.  This
              warning is enabled with -REL (OPTRELON/OPTRELOFF) along with
              the warning about the use of jumps instead of branches.  For
              example:

                              BRA       HALT      ;this line produces warning
               HALT           BRA       *

  1.80      ş Fixed: JMP not giving warning about using branch in backward
              branches that were within one byte of the branch limit.

  1.81      ş Added: Option -LC[ñ] (List Conditionals) for turning on/off the
              display of false conditionals directives in the .LST file.
              This minor option is not shown on the help screen.  The default
              is ON.  If you wish to revert to the previous behavior (such as
              it was up to v1.80) do:

                              ASM11 -LC- -W

              With this option turned on (my default), all #IFxxx
              conditionals will display in full (the #IFxxx, #ELSE, and
              #ENDIF parts) even when they are false.  In other words, when
              the conditional directives are false they will be treated as
              comments.

            ş #LISTON will not display in the .LST file if the listing was
              turned off just before this directive.  This allows to use the
              #LISTON directive even within the INCLUDE file and not have it
              show at all.  Since #LISTOFF won't display either, any include
              file that you never want to display in the .LST should start
              with a #LISTOFF and end with a #LISTON directive.  Then, simply 
              use:

                              #INCLUDE  FILE

              rather than:

                              #LISTOFF
                              #INCLUDE  FILE
                              #LISTON

              My thanks to Patrick Bouffel for bringing these up.

  1.82      ş Added: Extra mnemonics GETX, GETY, GIVEX, and GIVEY.  These are
              immediate mode instructions with a word operand.  Their purpose
              is to allocate (GETX/GETY) and deallocate (GIVEX/GIVEY) a fixed
              number of bytes (the immediate operand) from/to the stack.
              They are equivalent to the following series:

                        GETX sequence                  GIVEX sequence
                        -------------                  --------------

                              TSX                           TSX
                              XGDX                          XGDX
                              SUBD      #????               ADDD      #????
                              XGDX                          XGDX
                              TXS                           TXS

              GETY and GIVEY are exactly the same sequences but with the use
              of the Y register in place of the X register.

              Sample usage:

                              GETX      #10       ;allocate 10 bytes on stack
                                                  ;(for temporary use)
                              ...
                              CLR       ,X        ;clear the first byte
                              ....
                              CLR       9,X       ;clear the last byte
                              ...

                              GIVEX     #10       ;return 10 bytes to stack

              X (or Y) will point to beginning of the temporary stack area
              after GETX (or GETY) and immediately after the temporary stack
              area after GIVEX (or GIVEY).  Except for certain CCR flags (the
              result of the SUBD or ADDD instructions) and the register
              specified in the instruction (X or Y), no other registers are
              affected.

  1.83      ş Added: Symbols defined via the -Dx option may now be set to
              non-zero values.  The format for specifying a non-zero value is
              -Dsymbol:value_or_expression

              The value (or expression) following the colon is evaluated and
              assigned to symbol.  If no value is specified, zero is assumed.
              The maximum string length for both symbol and expression is 19
              characters.  The expression is any valid ASM11 expression,
              except that the length is limited to 19 characters.

              Since you can use the -Dx option up to ten times, each time you
              use it you can give an expression that uses symbols defined
              with the any of the previous -Dx instances.  For example:

               ASM11 MYPROG -DROM:$F800 -DRAM -DDATA:ROM+$300

              Symbol ROM will be assigned the value $F800
              Symbol RAM will be assigned the value $0000
              Symbol DATA will be assigned the value $FB00

              You can use the #IFNDEF directive to assign values either
              implicitly in the code or explicitly via the -Dx option.  For
              example:

               #ifndef ROM ;prevents Duplicate Symbol error if using -DROM
               ROM            EQU       $F800          ;default ROM location
               #endif

               ;ROM may also be set from the command-line with -DROM:$xxxx

                              ORG       ROM

            ş Updated: FRAME.ASM and OS11/*.MOD files.  A new method for
              making these routines modular and expandable.

  1.84      ş Added: Extra mnemonic XGXY (Exchange X with Y).  This is
              equivalent to XGDX, XGDY, XGDX.

  1.84b     ş Adds recognition of EXP in source but treats it exactly like EQU

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CREDITS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

I must credit Mark Schultz <mschultz@bigfoot.com> for his numerous
suggestions, some of which I followed to the letter while others I followed
with modifications.  Also, for test-driving ASM11 so much he discovered the
LSRD bug in an early version, and for providing his FLASH.A11 example for
programming Flash memories, and, finally, for preparing an excellent (I
think) Quick Reference Guide in PDF format ready to print.  [I have replaced
the PDF with a Word Document which is easier for me to update without
bothering Mark, and also for you to modify should you feel it's necessary.]

Frans Gunawan <fransg.geo@yahoo.com> requested and helped with details for
the -LSE format (EM11) of the SYM file used in his Shadow11 simulator.

Thanks to all others who have reported problems or suggestions (regardless if
I ended up implementing them or not).

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
KNOWN PROBLEMS
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

1. Lines longer than about 180 chars will be truncated and may not produce
   errors/warnings if the truncation point is such that completes a
   [pseudo]-instruction, as for example in a very long DB pseudo with many
   operands on the same line.  I decided not to fix this because a fix isn't
   possible, based on how the current parser works.  No matter what I do,
   there will always be a maximum string length which will exhibit the same
   problem, so it might as well be this length.  Simply, avoid lines that
   long.

  Please report problems you find to the address below or via email at
  <tonyp@acm.org>.

  I hope you'll enjoy using ASM11 but, most importantly, 68HC11 programming.

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
CONTACT INFO
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

          ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
          º Comments to the author may be directed to the address: º
          º                                                        º
          º                Tony G. Papadimitriou                   º
          º                   P.O. Box 14386                       º
          º                    Athens 115 10                       º
          º                       GREECE                           º
          ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
LEGAL NOTICE
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

This software is FREEWARE which means it is NOT public domain but fully
copyrighted material that is distributed freely without money.  Its
electronic distribution through BBSs, the Internet, or other such means is
encouraged provided no money is requested in return.

Also, it is forbidden to distribute this software should this file, or any of
the remaining files, change in any way or be omitted from the archive.

ş Please note that although I have done my best to ensure there is no
  potentially dangerous code (or accidental virus infections), the nature of
  programming is such that forces me to provide absolutely no warranty,
  express or implied, with this version of the software, and I bear no
  responsibility for whatever damages, direct or consequential, you may
  suffer from its use.  I definitely do not warrant this software for
  suitability for any particular purpose, either.  It is also possible that
  the instructions, the extra utilities, or the examples that come with the
  software contain errors, none of which were intentional.

                                          Tony G. Papadimitriou, M.S.
                                          e-mail: tonyp@acm.org
