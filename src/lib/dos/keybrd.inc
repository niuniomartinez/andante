(* Implements keyboard driver for DOS 16bits. *)

  var
  (* Original interrupt handler. *)
    DOS_OldKbdHandler: Pointer = Nil;
  (* Stores the value returned by the port. *)
    DOS_KeyScanCode: Byte;

(* Keyboard interruption handler. *)
  procedure DOS_KbdHandler; interrupt; far;
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



(* Install keyboard driver. *)
  function _InstallKbd: Boolean;
  begin
  { Get default keyboard handler. }
    GetIntVec (anKeyboardInt, DOS_OldKbdHandler);
  { Set new keyboard handler. }
    SetIntVec (anKeyboardInt, @DOS_KbdHandler);
  { All is Ok. }
    _InstallKbd := True
  end;



(* Uninstalls keyboard driver. *)
  procedure _UninstallKbd;
  begin
  { Restore the old handler. }
    if Assigned (DOS_OldKbdHandler) then
      SetIntVec (anKeyboardInt, DOS_OldKbdHandler)
  end;
