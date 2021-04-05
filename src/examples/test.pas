program test;
(* Test program. *)

  uses
    andante;

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
{ Test timer. }
  repeat
  until anKeyState[anKeyEscape];
  WriteLn;
  WriteLn ('We''re done!')
end.
