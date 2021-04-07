unit anVGA;
(***< Implements the VGA graphics modes. *)
(* See LICENSE.txt for copyright information. *)

interface

  const
  (*** Identifies the @italic(VGA graphics mode 13h). *)
    anGfx13   = $4D313368; { anId ('M13h') }

implementation

  uses
    andante, anBitmap
{$INCLUDE vgaunits.inc}
    ;

{$INCLUDE vga.inc}

initialization
{ Register VGA modes. }
  if not _anRegisterGfxDriver (anGfx13, @InitMode13h) then
    WriteLn ('[Error] Unable to register VGA graphics driver.')
finalization
  ;
end.
