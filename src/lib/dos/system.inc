(* Template to implement the core system for DOS 16bits.

   This file is included by unit andante.pas. *)

(* Initializes the system. *)
  function _InitSystem: Boolean;
  begin
    _InitSystem := True
  end;



(* Closes the system. *)
  procedure _CloseSystem;
  begin
  end;



(* Closes any graphics mode and sets a text mode (if available).

   DON'T DESTROY anScreen!!! *)
  procedure _CloseGfxMode;
  begin
  end;
