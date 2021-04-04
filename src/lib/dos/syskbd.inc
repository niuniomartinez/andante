(* Implements keyboard driver. *)

  const
    _KbrdInterruption = $9;
    _KbrdPort = $60;
    _KbrdAckP = $20;

  var
  (* To store the new interruption handler. *)
    _KbrdNewHandler,
  (* To store the old interruption handler. *)
    _KbrdOldHandler: TSegInfo;

(* Keyboard handler for DOS. *)
  procedure _DOS_KbrdHandler;
  (* Impementation note:

     This is trying to use code at Free Pascal's go32 documentation section
     "Hardware interrupts". *)
  begin
    asm
      cli
    { Save all registers, because we don't know which the compiler
      uses for the called procedure. }
      pushl %ds
      pushl %es
      pushl %fs
      pushl %gs
      pushal
    end;
  { Do what we want to do. }
    _test := 1;
    anKeyState[anKeyEscape] := True;
    asm
    { Restore all registers }
      popal
      popl %gs
      popl %fs
      popl %es
      popl %ds
    { Note: In go32v2 mode %cs=%ds=%es !!!}
      ljmp %cs:_KbrdOldHandler { call old handler }
    { We don't need to do anything more, because the old interrupt
      handler does this for us (send EOI command, iret, sti...) }
    end;
  end;
{ Dummy to know procedure size. }
  procedure _DOS_KbrdHandler_END; begin end;



(* Install keyboard driver. *)
  function _InstallKbd: Boolean;
  begin
  (* Impementation note:

     This is trying to use code at Free Pascal's go32 documentation section
     "Hardware interrupts". *)

  { Lock used code and data. }
    lock_data (_test, SizeOf (_test));
    lock_data (anKeyState, SizeOf (anKeyState));
    lock_code (
      @_DOS_KbrdHandler,
      LongInt (@_DOS_KbrdHandler_END) - LongInt (@_DOS_KbrdHandler)
    );
  { Get old handler. }
    get_pm_interrupt (_KbrdInterruption, _KbrdOldHandler);
  { Install new handler. }
    _KbrdNewHandler.offset := @_DOS_KbrdHandler;
    _KbrdNewHandler.segment := get_cs;
    set_pm_interrupt (_KbrdInterruption, _KbrdNewHandler);
  { That's ok. }
    _InstallKbd := True
  end;



(* Uninstalls keyboard driver. *)
  procedure _UninstallKbd;
  begin
  { restore old handler. }
    set_pm_interrupt (_KbrdInterruption, _KbrdOldHandler);
  { Unlock memory. }
    unlock_data (_test, SizeOf (_test));
    unlock_data (anKeyState, SizeOf (anKeyState));
    unlock_code (
      @_DOS_KbrdHandler,
      LongInt (@_DOS_KbrdHandler_END) - LongInt (@_DOS_KbrdHandler)
    )
  end;
