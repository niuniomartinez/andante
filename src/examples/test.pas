program test;
(* Test program. *)

  uses
    andante;

  procedure FakeShutdown;
  begin
    WriteLn ('Shutting down...');
  end;

begin
  if not anAddExitProc (@FakeShutdown) then
    WriteLn ('Ok');
  if not anInstall then
  begin
    WriteLn ('Can''t initialize Andante!');
    Halt
  end;
  if not anAddExitProc (@FakeShutdown) then
    WriteLn ('Can''t use FakeShutdown.');
  WriteLn ('We''re done!')
end.
