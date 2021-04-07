program vga;

uses
  crt, dos, go32;

  const
    VGA_RAM = $A000;
  var
    VGASeg: Word;

  procedure IniciaVGA;
  begin
    asm
      movw $0x0013, %ax
      int  $0x10
    end
  end;

  procedure VuelveATexto;
  begin
    asm
      movw $0x0003, %ax
      int  $0x10
    end
  end;

  procedure DibujaPixel (x, y, c: integer);
  var
    PunteroPixel: Word;
  begin
  {
    PByte (VGA_RAM + (y * 320) + x)^ := byte (c)
  }
    seg_fillchar (VGASeg, (y * 320) + x, 1, Char (c))
  { Calcula la posición del píxel. }
  (*
    PunteroPixel := VGA_RAM + (y * 320) + x;
    asm
    { Simplificación de putpixel de Allegro 1. }
      pushl %ebp
      movl %esp, %ebp
      pushl %ebx
      xor %eax, %eax

      movw c, %bx                      // bx = color
      movw VGASeg, %dx                 // dx = segmento VGA

      pushw %es
      movw PunteroPixel, %eax          // eax= puntero al pixel.
      movb %bl, %es:(%eax)
      popw %es
    end
 *)
  end;

begin
  VGASeg := segment_to_descriptor (VGA_RAM);
  IniciaVGA;
  Randomize;
  repeat
    DibujaPixel (Random (320), Random (200), Random (256))
  until KeyPressed;
  VuelveATexto;
  WriteLn (ReadKey)
end.
