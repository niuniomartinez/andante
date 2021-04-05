program testint;
{ This example demonstrates how to chain to a hardware interrupt. }

{$ASMMODE ATT}
{$MODE FPC}

  uses
    go32;

  const
  { Keyboard interruption. }
    KbdInterruption = $9;

  var
    KeyScanCode: Byte;
  { holds old PM interrupt handler address }
    OldKbdHandlerInfo: tseginfo;
  { new PM interrupt handler }
    NewKbdHandlerInfo: tseginfo;

  { The data segment selector.  Used to call Pascal procedures from inside the
    interruption.
    DataSegmentSelector : Word; external name '___v2prt0_ds_alias';
  }

{ interrupt handler }
  procedure int9_handler;
  interrupt;
  begin
  { Add next code to save the registers (if needed)
    asm
      pushl %ds
      pushl %es
      pushl %fs
      pushl %gs
      pushal
    end;
  }
    KeyScanCode := Port[$60]; { Get input.  KeyScanCode Should be locked. }
    Port[$20] := $20;         { Acknowledge input. }
  { Use next code to call a procedure.

    Note that code should be locked.
    asm
    // This set's up the call (Pascal way).
      movw %cs:DataSegmentSelector, %ax
      movw %ax, %ds
      movw %ax, %es
      movw dosmemselector, %ax
      movw %ax, %fs
    // Call the procedure.
      call *ProcedureName
    asm;
  }
  { Use next code to restore the registers saved at the beginning.
    asm
      popal
      popl %gs
      popl %fs
      popl %es
      popl %ds
    end;
  }
  end;
{ dummy procedure to retrieve exact length of handler, for locking
  and unlocking functions  }
  procedure int9_dummy; begin end;

{ installs our new handler }
  procedure install_click;
  begin
  { lock used code and data }
    lock_data (KeyScanCode, SizeOf (KeyScanCode));
  { Next needed only to call Pascal procedures from inside the interruption.
    lock_data (dosmemselector, sizeof (dosmemselector));
  }
    lock_code (
      @int9_handler,
      longint (@int9_dummy) - longint (@int9_handler)
    );
  { get old PM interrupt handler }
    get_pm_interrupt (KbdInterruption, OldKbdHandlerInfo);
  { set the new interrupt handler }
    NewKbdHandlerInfo.offset := @int9_handler;
    NewKbdHandlerInfo.segment := get_cs;
    set_pm_interrupt (KbdInterruption, NewKbdHandlerInfo)
  end;



{ deinstalls our interrupt handler }
  procedure remove_click;
  begin
  { set old handler }
    set_pm_interrupt (KbdInterruption, OldKbdHandlerInfo);
  { unlock used code & data }
  { Next needed only to call Pascal procedures from inside the interruption.
    unlock_data (dosmemselector, sizeof (dosmemselector));
  }

    unlock_code (
      @int9_handler,
      longint (@int9_dummy) - longint (@int9_handler)
    )
  end;

begin
  Writeln ('Hello, World!');
  Writeln ('Enter any message.', ' Press return when finished');
  install_click;
  repeat
    if 0 < KeyScanCode then
    begin
    { Write only when pressing. }
      if KeyScanCode < 89 then Writeln (KeyScanCode);
    { Reset KeyScanCode (but only if it is NOT the Escape key, so we can use
      it as exit key). }
      if KeyScanCode <> 1 then KeyScanCode := 0
    end
  until KeyScanCode = 1;
  remove_click
end.
