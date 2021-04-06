(* Implements the VGA driver. *)

  const
  (* VGA VRAM position. *)
    DOS_Mode13hVRAM = $A000;

(* Sets Mode 13h. *)
  function InitMode13h: andanteBitmapPtr;
  var
    lBmp: andanteBitmapPtr;
  begin
  { Create bitmap. }
    GetMem (lBmp, SizeOf (andanteBitmap));
    if not Assigned (lBmp) then
    begin
      anError := anNoMemoryError;
      Exit (Nil)
    end;
  { Init Mode 13h. }
    asm
      movw $0x0013, %ax
      int $0x10
    end;
  (* Assembler equivalent to
    var
      lRegisters: Registers;
    begin
      lRegisters.ax := $0013;
      intr ($10, lRegisters)
    end;
   *)
  { Initialize bitmap. }
    lBmp^._Protected._Data := Pointer (DOS_Mode13hVRAM);
    anBmp8._anFillVirtualTable  (lBmp);
    lBmp^._VT._Destructor := @anBitmap._anFixedBitmapDestructor;
  { Ok. }
    InitMode13h := lBmp
  end;

