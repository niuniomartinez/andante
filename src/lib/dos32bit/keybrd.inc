(* Implements keyboard driver for DOS 32bits. *)

  var
  (* Interrupt handlers information. *)
    DOS_OldKbdHandlerInfo, DOS_NewKbdHanderlInfo: TSegInfo;
  (* Stores the value returned by the port. *)
    DOS_KeyScanCode: Byte;

(* Keyboard interruption handler. *)
  procedure DOS_KbdHandler; interrupt;
  begin
  { Get port value. }
    DOS_KeyScanCode := Port[anKeyboardPort];
  { Acknowledge input. }
    Port[anAcknowledgePort] := anAcknowledgeOk;
  { Process. }
    if DOS_KeyScanCode > $80 then
    { Key was released. }
      anKeyState[DOS_KeyScanCode and $7F] := False
    else begin
    { Key was pressed. }
      anKeyState[DOS_KeyScanCode and $7F] := True
    end
  end;



{$PUSH} { Ignore next warnings. }
{$WARN 4055 OFF : Conversion between ordinals and pointer is not portable }
{$WARN 4082 OFF : Converting pointers to signed integers may result in wrong
                  comparison results and range errors, use an unsigned type
                  instead }
(* Install keyboard driver. *)
  function _InstallKbd: Boolean;
  begin
  { Lock data and code. }
    lock_data (DOS_KeyScanCode, SizeOf (DOS_KeyScanCode));
    lock_data (anKeyState, SizeOf (anKeyState));
    lock_code (
      @DOS_KbdHandler,
      LongInt (@_InstallKbd) - LongInt (@DOS_KbdHandler)
    );
  { Get default keyboard handler. }
    get_pm_interrupt (anKeyboardInt, DOS_OldKbdHandlerInfo);
  { Set new keyboard handler. }
    DOS_NewKbdHanderlInfo.offset := @DOS_KbdHandler;
    DOS_NewKbdHanderlInfo.segment := get_cs;
    if not set_pm_interrupt (anKeyboardInt, DOS_NewKbdHanderlInfo) then
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
  { Restore the old handler. }
    if not set_pm_interrupt (anKeyboardInt, DOS_OldKbdHandlerInfo) then
    { Shouldn't happend but... }
      Halt (-1);
  { Unlock memory and code. }
    unlock_data (DOS_KeyScanCode, SizeOf (DOS_KeyScanCode));
    unlock_data (anKeyState, SizeOf (anKeyState));
    unlock_code (
      @DOS_KbdHandler,
      LongInt (@_InstallKbd) - LongInt (@DOS_KbdHandler)
    )
  end;
{$POP}
