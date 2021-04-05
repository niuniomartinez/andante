program timer;
(* Shows a way to use timers. *)

uses
  andante;

var
  Cnt: Integer;

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
  WriteLn ('Press [Esc] to exit.');
  Cnt := 0;
  repeat
    if anTimerCounter mod anDefaultFreq = 1 then
    begin
      Inc (Cnt); WriteLn (Cnt);
      repeat until anTimerCounter mod anDefaultFreq <> 1;
    end
  until anKeyState[anKeyEscape];
  WriteLn;
  WriteLn ('We''re done!')
end.
