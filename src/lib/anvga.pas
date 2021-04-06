unit anVGA;
(***< Implements the VGA graphics modes. *)
(* See LICENSE.txt for copyright information. *)

interface

  const
  (*** Identifies the @italic(VGA graphics mode 13h). *)
    anGfx13   = $4D313368; { anId ('M13h') }

(*** Registers the VGA graphics mode. *)
  function anRegisterVGAModes: Boolean;

implementation

  uses
    andante, anBitmap, anBmp8
{$INCLUDE vgaunits.inc}
    ;

{$INCLUDE vga.inc}



(* Registers modes. *)
  function anRegisterVGAModes: Boolean;
  begin
    anRegisterVGAModes := _anRegisterGfxDriver (anGfx13, @InitMode13h)
  end;

end.
