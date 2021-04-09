(* Implements DOS core system.

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



(* Closes any graphics mode and sets a text mode (if available). *)
  procedure _CloseGfxMode;
    assembler;
  asm
    movw $0x0003, %ax
    int $0x10
  end;
(* Assembler equivalent to
  var
    lRegisters: Registers;
  begin
    lRegisters.ax := $0003;
    intr ($10, lRegisters)
  end;
 *)
