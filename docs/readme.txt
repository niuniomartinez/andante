Welcome to the Andante Documentation Directory
==============================================

  This directory contains all documentation of the Andante library.  Read it
  carefully before to use the library or move to other documents.

  Note tha the library is in a early development, so a lot may change before
  the first stable version (1.0).



How to compile the examples
---------------------------

  To compile the examples you need Free Pascal installed, including the 'make'
  utility.  [https://www.freepascal.org/]  Remember that Lazarus includes
  Free Pascal.

  Note:  If you have problems running or installing Free Pascal on MS-DOS or
  FreeDOS, try to install it on any DOS based Windows (Windows Millenium Edition
  (me) or older should work, but I recommend Windows XP or Windows 95).  You can
  use a cross-compiling version of Free Pascal too.

  On Linux and Windows you need Allegro.pas too.
  [https://github.com/niuniomartinez/allegro-pas]

  Once you have everything installed, go to the directory where you unzipped
  Andante, then execute the "fix" script and launch the makefile.  Let's say
  you unzipped Andante in the C: unit.  Then you should do that:

  Z:\>C:
  C:\>CD ANDANTE
  C:\ANDANTE>FIX.BAT DOS
  Configuring for DOS/FPC...
  Done!
  C:\ANDANTE>MAKE
  Andante
  "(c) Guillermo Martínez J. 2021"
  https://github.com/niuniomartinez/andante
  -
  fpc -O1 ...
  ...
  Finished all examples.
  Finished Andante.
  To create the documentation, run make docs.
  C:\ANDANTE>CD BIN\EXAMPLES
  C:\ANDANTE\BIN\EXAMPLES>DIR



Documentation
-------------

  Right now, documentation should be created.

  First, install the pasdoc utility [https://github.com/pasdoc/pasdoc].

  Then move the the Andante directory and execurte "MAKE DOCS".  Documentation
  will be stored in the 'docs/lib' directory in HTML5 format.



Using Andante
-------------

  To use Andante in your game you only need 'src/lib' directory, and pass to the
  compiler (i.e. the -Fu and -Fi options) that directory and the platform
  directory.  For example, to compile for DOS:

  fpc mygame.pas -Fuandante -Fuandante\dos -Fiandante\dos

  And for Windows or Linux:

  fpc mygame.pas -Fuandante -Fuandante\allegro -Fiandante\allegro

  Do not use '*' or the compiler may not find the appropriate system units!



Contact
-------

  If you need more help you can drop your question in one of the next forums:

  - Pascal Game Development [pascalgamedevelopment.com/]
  - Lazarus game subforum
    [https://forum.lazarus.freepascal.org/index.php/board,74.0.html]

  If you like Discord, then there are too:

  - Unofficial Free Pascal [https://discord.gg/XKanA3Ef]

  And of course the Andante project site at
  [https://github.com/niuniomartinez/andante/].
