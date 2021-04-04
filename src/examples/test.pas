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
  WriteLn ('We''re done!')
end.
