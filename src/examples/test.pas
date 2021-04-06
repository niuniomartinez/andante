program test;
(* Test program. *)

uses
  andante, anBitmap, anBmp8;

var
  Bitmap: andanteBitmapPtr;
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
  Bitmap := anCreate8bitBitmap (320, 200);
  if Assigned (Bitmap) then
  begin
    anDrawPixel (Bitmap, 100, 100, 2);
    anDestroyBitmap (Bitmap)
  end
  else
    WriteLn ('Can''t create bitmap.');
  WriteLn;
  WriteLn ('We''re done!')
end.
