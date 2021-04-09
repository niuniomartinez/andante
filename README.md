# What's Andante?

**Andante** is a library for developing old-style games.

Huge pixels and chiptunes are not enough to create _a true retro game_.  Old
games are the way they are due to the limitations of the machines and
programming techniques of the time, which affected not only how the graphics
and sounds are but also the gameplay itself.

Andante is designed to make games for IBM PCs with MS-DOS operating systems
(and therefore also DrDOS, DOSbox, FreeDOS ...).  Note that it is not a game
engine:  you can design and structure your program however you like.

I'll try to make it work in 3 targets: DOS, Linux and Windows.  I'll start with
DOS 16bits, then port it to the others (including DOS 32bits).

I plan to implement the following features:

* Support for VGA graphics modes, including ModeX.
* Digital sound and MIDI music.
* An extensive graphic library both 2D and 3D.
* Input by keyboard, joystick and mouse.
* Tools to deal with those details that modern editors are not able to handle
  (color palettes, 8/16-bit sound, text fonts, ASCII text ...).
* An interface that facilitates portability to other platforms (classic and
  modern) or the addition of new devices (such as SuperVGA cards or gamepads).



## Requirements

Just have the compiler [Free pascal](https://www.freepascal.org/)
installed.



## Documentation

There are plenty of documentation in he `docs` directory.

Start reading the `readme.txt` file.
