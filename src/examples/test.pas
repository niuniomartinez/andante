program test;
(* Test program. *)

  uses
    crt,
    andante;

  var
    Buf, LastBuf: String;

begin
  WriteLn ('Andante ', anVersionString);
  WriteLn;
  if not anInstall then
  begin
    WriteLn ('Can''t initialize Andante!');
    Halt
  end;
  if not anInstallKeyboard then
  begin
    WriteLn ('Keyboard out: ', anError);
    Halt
  end;
{ Test keyboard. }
  LastBuf := '';
  repeat
    if anKeyState[anKey1] then Buf := 'o' else Buf := '-';
    if anKeyState[anKey2] then Buf := Buf + 'o' else Buf := '-';
    if anKeyState[anKey3] then Buf := Buf + 'o' else Buf := '-';
    if anKeyState[anKey4] then Buf := Buf + 'o' else Buf := '-';
    if anKeyState[anKey5] then Buf := Buf + 'o' else Buf := '-';
    if Buf <> LastBuf then
    begin
      WriteLn (Buf);
      LastBuf := Buf
    end
  until anKeyState[anKeyEscape];
  WriteLn;
  WriteLn ('We''re done!')
end.
