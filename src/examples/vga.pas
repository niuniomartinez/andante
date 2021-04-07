program vga;
(* Test program. *)
uses
  andante, anBitmap, anVga;



(* Helper to show error messages. *)
  procedure ShowError (aMessage: String);
  begin
    WriteLn ('Error [', anError, ']: ', aMessage);
    WriteLn
  end;

begin
  WriteLn ('Andante ', anVersionString);
  WriteLn;
  if not anInstall then
  begin
    ShowError ('Can''t initialize Andante!');
    Halt
  end;
  if not anInstallKeyboard then
  begin
    ShowError ('Keyboard out.');
    Halt
  end;
  if not anSetGraphicsMode (anGfx13) then
  begin
    ShowError ('Can''t initialize VGA.');
    Halt
  end;
  Randomize;

  repeat
    anDrawPixel (anScreen, Random (320), Random (200), Random (256))
  until anKeyState[anKeyEscape]
end.
