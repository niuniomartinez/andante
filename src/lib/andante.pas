unit andante;
(***< Implements the Andante core system.  This include:@unorderedlist(
    @item(Configuration.)
    @item(Initialization.)
    @item(Error handling.)
  )
 *)
(* See LICENSE.txt for copyright information. *)

interface

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
    anNotImplemented = -9999;

  var
  (*** Last error state. *)
    anError: Integer = anNoError;



(*
 * Core initialization/finalization.
 ************************************************************************)
  type
    anExitProc = procedure;

  function anInstall: Boolean;
  procedure anUninstall;
  function anAddExitProc (aProc: anExitProc): Boolean;
  procedure anRemoveExitProc (aProc: anExitProc);



(*
 * Keyboard
 ************************************************************************)

{$INCLUDE ankeys.inc}

  var
    anKeyState: array [anKeyEscape..anKeyF12] of ByteBool;

  function anInstallKeyboard: Boolean;
  procedure anUninstallKeyboard;
  procedure anClearKeyboard;


implementation

(* Includes the "uses" list. *)
  {$INCLUDE sysunits.inc}

(* Forward declarations for the procedures and functions that MUST be
   defined by system.inc. *)

(* System initialization. *)
  function _InitSystem: Boolean; forward;
(* System finalization. *)
  procedure _CloseSystem; forward;



(* Includes platform core system. *)
  {$INCLUDE system.inc}



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
      Proc: anExitProc;
      Next: TExitProcPtr
    end;

  var
  (* Tells if system was initialized. *)
    Initialized: Boolean = False;
  (* List of exit procedures. *)
    ExitProcList: TExitProcPtr = Nil;



  function anInstall: Boolean;
  begin
    if Initialized then Exit (True);
  { Reset globals. }
    anError := anNoError;
  { Initialize target specific stuff. }
    if not _InitSystem then Exit (False);
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
    { Closes target specific stuff. }
      _CloseSystem;
    { Andante finalized. }
      anError := anNoError;
      Initialized := False
    end
  end;



(* Adds new exit procedure. *)
  function anAddExitProc (aProc: anExitProc): Boolean;
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
    anAddExitProc := True
  end;



(* Removes the exit procedure. *)
  procedure anRemoveExitProc (aProc: anExitProc);
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



(*
 * Core initialization/finalization.
 ************************************************************************)

(* Forward declarations for the procedures and functions that MUST be
   defined by syskbd.inc. *)

  function _InstallKbd: Boolean; forward;
  procedure _UninstallKbd; forward;

{$INCLUDE syskbd.inc}

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
