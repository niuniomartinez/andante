(* Implements keyboard driver. *)

  const
    DOS_KbrdInterruption = $9;
    DOS_KbrdPort = $60;
    DOS_KbrdAckP = $20;
  var
  (* Interruption handlers information. *)
    DOS_OldKbdHandlerInfo, DOS_NewKbdHanderlInfo: TSegInfo;
  (* Stores the value returned by the port. *)
    DOS_KeyScanCode: Byte;



(* Keyboard interruption handler. *)
  procedure DOS_KeyboardHandler; interrupt;
  begin
  { Get port value. }
    DOS_KeyScanCode := Port[DOS_KbrdPort];
  { Aknowlege input. }
    Port[DOS_KbrdAckP] := DOS_KbrdAckP;
  { Process. }
    if DOS_KeyScanCode > $80 then
    { Key was released. }
      anKeyState[DOS_KeyScanCode and $7F] := False
    else begin
    { Key was pressed. }
      anKeyState[DOS_KeyScanCode and $7F] := True
    end
  end;



(* Install keyboard driver. *)
  function _InstallKbd: Boolean;
  begin
  { Lock data and code. }
    lock_data (DOS_KeyScanCode, SizeOf (DOS_KeyScanCode));
    lock_data (anKeyState, SizeOf (anKeyState));
    lock_code (
      @DOS_KeyboardHandler,
      LongInt (@_InstallKbd) - LongInt (@DOS_KeyboardHandler)
    );
  
    get_pm_interrupt (DOS_KbrdInterruption, DOS_OldKbdHandlerInfo);
  { Set new interruption handler. }
    DOS_NewKbdHanderlInfo.offset := @DOS_KeyboardHandler;
    DOS_NewKbdHanderlInfo.segment := get_cs;
    if not set_pm_interrupt (DOS_KbrdInterruption, DOS_NewKbdHanderlInfo) then
    begin
      _UninstallKbd;
      anError := anCantInitialize;
      Exit (False)
    end;
  { Done. }
    _InstallKbd := True
  end;



(* Uninstalls keyboard driver. *)
  procedure _UninstallKbd;
  begin
  { Reset old handler. }
    if not set_pm_interrupt (DOS_KbrdInterruption, DOS_OldKbdHandlerInfo) then
    { Shouldn't happend but... }
      Halt (-1);
  { Unlock memory and code. }
    unlock_data (DOS_KeyScanCode, SizeOf (DOS_KeyScanCode));
    unlock_data (anKeyState, SizeOf (anKeyState));
    unlock_code (
      @DOS_KeyboardHandler,
      LongInt (@_InstallKbd) - LongInt (@DOS_KeyboardHandler)
    )
  end;
