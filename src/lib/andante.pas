unit andante;
(***< Implements the Andante core system.  This include:@unorderedlist(
    @item(Configuration.)
    @item(Initialization.)
    @item(Error handling.)
  )

  @bold(See also:) @link(getst Getting started) *)
(* See LICENSE.txt for copyright information. *)

interface

  uses
    anBitmap;

(*
 * Identification.
 ************************************************************************)
  const
  (*** Andante version string. *)
    anVersionString: String = '1.a.0';

(*** Creates an identifier from a string. *)
  function anId (const aName: String): LongWord; inline;



(*
 * Error handling.
 ************************************************************************)
  const
  (* Core error codes. *)
    anNoError = 0;
    anNoMemoryError = -1;
    anCantInitialize = -2;
    anDuplicatedDriver = -3;
    anGfxModeNotFound = -4;
    anNotImplemented = -9999;

  var
  (*** Last error state. *)
    anError: Integer = anNoError;



(*
 * Core initialization/finalization.
 ************************************************************************)
  type
    andanteExitProc = procedure;

  function anAddExitProc (aProc: andanteExitProc): Boolean;
  procedure anRemoveExitProc (aProc: andanteExitProc);

  function anInstall: Boolean;
  procedure anUninstall;



(*
 * Graphics mode.
 ************************************************************************)

  const
  (* Graphics modes. *)
    anGfxText = $54455854; { anId ('TEXT') }

  var
  (*** Reference to the screen bitmap. *)
    anScreen: andanteBitmapPtr = Nil;

(*** Initializes graphics mode. *)
  function anSetGraphicsMode (const aName: LongWord): Boolean;



(*
 * Timer.
 ************************************************************************)

  const
  (*** Default timer frequency, in ticks per second. *)
    anDefaultFreq = 50;
  var
  (*** Timer counter. *)
    anTimerCounter: LongWord;



(*
 * Keyboard
 ************************************************************************)

{$INCLUDE ankeys.inc}

  var
    anKeyState: array [anKeyEscape..anKeyF12] of ByteBool;

  function anInstallKeyboard: Boolean;
  procedure anUninstallKeyboard;
  procedure anClearKeyboard;



(*
 * Internal stuff.
 ************************************************************************)

{ Everything below this is for internal use only.  You don't need it for
  your games.  Do not use it unless you really know what are you doing
  OR BAD THINGS MAY HAPPEN!!!
}

  type
  (*** @exclude *)
    _ANDANTE_GFX_INIT_FUNCTION_ = function: andanteBitmapPtr;

(*** @exclude
  Registers a new graphics mode.

  Parameters:
    - aName: An unique identifier.  Use one of the anGfx* constants or create
             your own.
    - aInitializationFn: Pointer to a function that should:
             + Initialize the graphics mode.
             + Create a bitmap that allows to access to the graphics output.
  Returns:
    A pointer to the bitmap that represents the graphics context or Nil if
    something was wrong (use anError to tell what).
 *)
  function _anRegisterGfxDriver (
    const aName: LongWord;
    aInitializationFn: _ANDANTE_GFX_INIT_FUNCTION_
  ): Boolean;

implementation

(* Includes the "platform specific" uses list. *)
  {$INCLUDE sysunits.inc}

(*
 * Internal stuff.
 ************************************************************************)

  type
    TGfxDriverPtr = ^TGfxDriver;
    TGfxDriver = record
      Name: LongWord;
      Initialize: _ANDANTE_GFX_INIT_FUNCTION_;
      Next: TGfxDriverPtr
    end;

  var
    GfxDriverList: TGfxDriverPtr = Nil;



(* Finds a graphics driver. *)
  function FindGfxDriver (const aName: LongWord): TGfxDriverPtr;
  begin
    FindGfxDriver := GfxDriverList;
    while FindGfxDriver <> Nil do
      if FindGfxDriver^.Name = aName then
	Exit
      else
	FindGfxDriver := FindGfxDriver^.Next
  end;



(* Registers a new graphics mode. *)
  function _anRegisterGfxDriver (
    const aName: LongWord;
    aInitializationFn: _ANDANTE_GFX_INIT_FUNCTION_
  ): Boolean;
  var
    lNewDriver: TGfxDriverPtr;
  begin
  { Check if it is in the list. }
    if FindGfxDriver (aName) <> Nil then
    begin
      anError := anDuplicatedDriver;
      Exit (False)
    end;
  { Adds to the list. }
    GetMem (lNewDriver, SizeOf (TGfxDriver));
    if lNewDriver = Nil then
    begin
      anError := anNoMemoryError;
      Exit (False)
    end;
    lNewDriver^.Name := aName;
    lNewDriver^.Initialize := aInitializationFn;
    lNewDriver^.Next := GfxDriverList;
    GfxDriverList := lNewDriver;
  { Everything is Ok. }
    _anRegisterGfxDriver := True
  end;



(* Removes all drivers. *)
  procedure _anDestroyGfxDrivers;
  var
    lDriver: TGfxDriverPtr;
  begin
    while Assigned (GfxDriverList) do
    begin
      lDriver := GfxDriverList^.Next;
      FreeMem (GfxDriverList, SizeOf (TGfxDriver));
      GfxDriverList := lDriver
    end
  end;



(*
 * Platform dependent stuff.
 ************************************************************************)

{ This section includes all the "platform dependent" stuff.

  Each sub-system first declares the stuff that should be implemented, then
  includes the "inc" file that implements it.
}

(* System initialization. *)
  function _InitSystem: Boolean; forward;
(* System finalization. *)
  procedure _CloseSystem; forward;
(* Closes any text mode and sets a text mode (if available). *)
  procedure _CloseGfxMode; forward;

{$INCLUDE system.inc}



(* Installs timer handler. *)
  function _InstallTimer: Boolean; forward;
(* Uninstalls timer handler, restoring the default one if needed. *)
  procedure _UninstallTimer; forward;

  var
  (* Current timer frequency. *)
    _TimerFreq: LongInt = anDefaultFreq;

{$INCLUDE timer.inc}



(* Installs the keyboard handler. *)
  function _InstallKbd: Boolean; forward;
(* Uninstalls the keyboard handler, restoring the default one if needed. *)
  procedure _UninstallKbd; forward;

{$INCLUDE keybrd.inc}



(*
 * Identification.
 ************************************************************************)

(* Builds an id. *)
  function anId (const aName:  String): LongWord;
  begin
    anId := (Ord (aName[1]) shl 24) or (Ord (aName[2]) shl 16)
         or (Ord (aName[3]) shl  8) or  Ord (aName[4])
  end;



(*
 * Core initialization/finalization.
 ************************************************************************)

  type
    TExitProcPtr = ^TExitProc;
    TExitProc = record
      Proc: andanteExitProc;
      Next: TExitProcPtr
    end;

  var
  (* Tells if system was initialized. *)
    Initialized: Boolean = False;
  (* List of exit procedures. *)
    ExitProcList: TExitProcPtr = Nil;



(* Adds new exit procedure. *)
  function anAddExitProc (aProc: andanteExitProc): Boolean;
  var
    lNewExitProc: TExitProcPtr;
  begin
  { Check if it is in the list. }
    lNewExitProc := ExitProcList;
    while Assigned (lNewExitProc) do
    begin
      if lNewExitProc^.Proc = aProc then Exit (true);
      lNewExitProc := lNewExitProc^.Next
    end;
  { Adds to the list. }
    GetMem (lNewExitProc, SizeOf (TExitProc));
    if lNewExitProc = Nil then
    begin
      anError := anNoMemoryError;
      Exit (False)
    end;
    lNewExitProc^.Proc := aProc;
    lNewExitProc^.Next := ExitProcList;
    ExitProcList := lNewExitProc;
  { Everything is Ok. }
    anAddExitProc := True
  end;



(* Removes the exit procedure. *)
  procedure anRemoveExitProc (aProc: andanteExitProc);
  var
    lCurrent, lPrevious: TExitProcPtr;
  begin
  { This is a copy of Allegro's _al_remove_exit_func. }
    lPrevious := Nil;
    lCurrent := ExitProcList;
    while Assigned (lCurrent) do
    begin
      if lCurrent^.Proc = aProc then
      begin
	if Assigned (lPrevious) Then
	  lPrevious^.Next := lCurrent^.Next
	else
	  ExitProcList := lCurrent^.Next;
	FreeMem (lCurrent, SizeOf (TExitProc));
	Exit
      end;
      lPrevious := lCurrent;
      lCurrent := lCurrent^.Next
    end
  end;



  function anInstall: Boolean;
  begin
    if Initialized then Exit (True);
  { Reset globals. }
    anError := anNoError;
  { Initialize target specific stuff. }
    if not _InitSystem then Exit (False);
    if not _InstallTimer then Exit (False);
  { Everything is Ok. }
    Initialized := True;
    anInstall := True
  end;



  procedure anUninstall;

    procedure CallExitProcedures;
    var
      lExitProc, lNextProc: TExitProcPtr;
    begin
      lExitProc := ExitProcList;
      repeat
	lNextProc := lExitProc^.Next;
	lExitProc^.Proc ();
	anRemoveExitProc (lExitProc^.Proc);
	lExitProc := lNextProc
      until lExitProc = Nil;
      ExitProcList := Nil
    end;

  begin
    if Initialized then
    begin
      if Assigned (ExitProcList) then CallExitProcedures;
    { Shut down graphics subsystem. }
      if Assigned (anScreen) then
      begin
	anDestroyBitmap (anScreen);
	anScreen := Nil;
	_CloseGfxMode
      end;
      _anDestroyGfxDrivers;
    { Closes target specific stuff. }
      _UninstallTimer;
      _CloseSystem;
    { Andante finalized. }
      anError := anNoError;
      Initialized := False
    end
  end;



(*
 * Graphics mode.
 ************************************************************************)

(* Inits graphics mode. *)
  function anSetGraphicsMode (const aName: LongWord): Boolean;
  var
    lGfxDriver: TGfxDriverPtr;
  begin
  { Text mode is a bit special. }
    if aName = anGfxText then
    begin
      if Assigned (anScreen) then
      begin
	anDestroyBitmap (anScreen);
	anScreen := Nil;
	_CloseGfxMode
      end
    end
    else begin
    { Find requested graphics mode. }
      lGfxDriver := FindGfxDriver (aName);
      if not Assigned (lGfxDriver) then
      begin
	anError := anGfxModeNotFound;
	Exit (False)
      end;
    { Destroy old screen bitmap (this may close current graphics mode). }
      anDestroyBitmap (anScreen); anScreen := Nil;
    { Open new graphics mode and get new screen bitmap. }
      anScreen := lGfxDriver^.Initialize ();
      if not Assigned (anScreen) then Exit (False)
    end;
  { Everything is Ok. }
    anSetGraphicsMode := True
  end;



(*
 * Keyboard
 ************************************************************************)

(* Install keyboard. *)
  function anInstallKeyboard: Boolean;
  begin
    if not _InstallKbd then Exit (False);
    if not anAddExitProc (@anUninstallKeyboard) then
    begin
      anError := anNoMemoryError;
      _UninstallKbd;
      Exit (False)
    end;
    anClearKeyboard;
    anInstallKeyboard := True
  end;



(* Removes keyboard. *)
  procedure anUninstallKeyboard;
  begin
    _UninstallKbd;
    anRemoveExitProc (@anUninstallKeyboard)
  end;



(* Clears keyboard state. *)
  procedure anClearKeyboard;
  var
    lKey: Integer;
  begin
    for lKey := Low (anKeyState) to High (anKeyState) do
      anKeyState[lKey] := False
  end;


initialization
  ; { Do none, but some compilers need it. }
finalization
  anUninstall
end.
