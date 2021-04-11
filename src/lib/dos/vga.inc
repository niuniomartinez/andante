(* Implements the VGA driver. *)

  const
  (* VGA VRAM position. *)
    DOS_Mode13hVRAM = $A000;

(* Sets Mode 13h. *)
  function InitMode13h: andanteBitmapPtr;
  var
    lVRAM: andanteBitmapPtr;
  begin
  { Get VRAM bitmap. }
    lVRAM := GetMem (SizeOf (andanteBitmap)); { anCreate8bitBitmap (320, 200); }
    if not Assigned (lVRAM) then Exit (Nil);
    lVRAM^._VT._Destructor := @_anFixedBitmapDestructor;
    lVRAM^._Protected._Data := @(Mem[DOS_Mode13hVRAM: 0]);
    anBmp8._anFillVirtualTable (lVRAM);
    lVRAM^.Width := 320; lVRAM^.Height := 200; lVRAM^.Depth := 8;
  { Init Mode 13h. }
    asm
      movw $0x0013, %ax
      int $0x10
    end;
  { All is ok. }
    InitMode13h := lVRAM
  end;

