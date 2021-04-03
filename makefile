# ------------------------------------------------------------------------
# Makefile
# ------------------------------------------------------------------------
# Based in the Almake project as used in KOF91 V1.49.
# Visit http://almake.sf.net/ for almake information.
# Visit http://kof91.sf.net/  for KOF91 information.

# This file defines the tarjet platform, and is modified by fix.bat or
# fix.sh script. See it's sources.
include target.os

# Suggested by "GNU Coding Stardards"
SHELL = /bin/sh

# ===============================================
# Project name
PROJECT = Andante

# ===============================================

# --------------------------------------
# -- Platform dependent configuration --
# --------------------------------------
#
# ------------------
# DOS
# ------------------
ifeq ($(TARGET),DOS)
	# Platform name.
	PLATFORM=DOS
	# Binary sufix.
	BINSUF = .exe
	LIBSUF = 
	# Extra flags.
	EFLAGS = 

	# File management.
	DELETE = del
	COPY   = copy
endif

# ------------------
# Win32
# ------------------
ifeq ($(TARGET),WIN)
	# Platform name.
	PLATFORM=Windows
	# Binary sufix.
	BINSUF = .exe
	# Extra flags.
	EFLAGS = -WG

	# File management.
	# TODO: Detect MSys, Cywing and such...
	DELETE = del
	COPY   = copy
endif

# ------------------
# Linux
# ------------------
ifeq ($(TARGET),LINUX)
	# Platform name.
	PLATFORM=GNU/Linux
	# Binary sufix.
	BINSUF = .bin
	# Extra flags.
	EFLAGS = 

	# File management.
	DELETE = rm
	COPY   = cp
endif



# ----------------------------
# -- Optimization specifics --
# ----------------------------

# Optimization options, including "smart linking".
OPTOPT = -O3 -CX -Xs -XX

# Next can be used to optimize for almost any current 32bit PC with Linux or
# Windows, doing it pretty well.  Of course, it will prevent your executable to
# run in anything older than PentiumIII.
# OPTOPT += -CpPENTIUM3

# Next one can be used to optimize for 64bit PC with Linux or Windows.
# OPTOPT += -CpATHLON64



# ---------------------
# -- Debug specifics --
# ---------------------

# Debugging options.
# Adds GDB information to the executable, and shows warnings and hints.
DBGOPT = -O1 -g -gl -vh -vw
# Adds some code to check ranges and overflows.
DBGOPT += -Ct -Cr -CR -Co
# Adds code for valgrind
# DBGOPT += -gv



# --------------------------
# -- No platform specific --
# --------------------------

# Sufix for main unit.  See "makefile.list" and "makefile.all".
MAINSUF = .pas
LIBSUF  = .pas

# Directories.
SRCDIR = src/
LIBDIR = lib/
EXMDIR = examples/
OBJDIR = obj/
BINDIR = bin/

LIBSRC = $(SRCDIR)$(LIBDIR)
EXMSRC = $(SRCDIR)$(EXMDIR)

EXMBIN = $(BINDIR)$(EXMDIR)


# Pascal flags.
PFLAGS = 

# Optimized compilation.
#FLAGS = $(OPTOPT) $(PFLAGS) $(EFLAGS)
# Use next line instead to activate debug.
FLAGS = $(DBGOPT) $(PFLAGS) $(EFLAGS)



# -------------------
# -- Documentation --
# -------------------

DOCSRC = $(SRCDIR)docs/
DOCDIR = docs/lib/

DOCFMT = -O html -L en
DOCOPTS = --staronly --auto-abstract --include-creation-time --use-tipue-search



# -- Source files list --
include makefile.list

# -- Build rules  --
include makefile.all

