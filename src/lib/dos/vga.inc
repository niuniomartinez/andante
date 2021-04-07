(* Implements the VGA driver. *)

  const
  (* VGA VRAM position. *)
    DOS_Mode13hVRAM = $A000;

  type
  (* Extends andanteBitmap to support segments. *)
    DOS_VGAScreenBitmapPtr = ^DOS_VGAScreenBitmap;
    DOS_VGAScreenBitmap = record
      Bitmap: andanteBitmap;
      Segment: Word;
    end;



(* Draws a pixel in the screen. *)
  procedure DOS_Mode13hDrawPixel (aBmp: andanteBitmapPtr; const x, y, c: LongInt);
  var
    VRAM: DOS_VGAScreenBitmapPtr absolute aBmp;
  begin
    if (0 <= x) and (x <= 320) and (0 <= y) and (y <= 200) then
      seg_fillchar (VRAM^.Segment, (y * 320) + x, 1, Char (c))
  end;



(* Gets a pixel from screen. *)
  function DOS_Mode13hGetPixel (aBmp: andanteBitmapPtr; const x, y: LongInt): LongInt;
  var
    VRAM: DOS_VGAScreenBitmapPtr absolute aBmp;
    lColor: byte;
  begin
    if (0 <= x) and (x <= 320) and (0 <= y) and (y <= 200) then
    begin
      seg_move (VRAM^.Segment, (y * 320) + x, 0, LongInt (@lColor), 1);
      DOS_Mode13hGetPixel := lColor
    end
    else
      DOS_Mode13hGetPixel := -1
  end;



(* Sets Mode 13h. *)
  function InitMode13h: andanteBitmapPtr;
  var
    lVRAM: DOS_VGAScreenBitmapPtr;
  begin
  { Reserve space for the VRAM descriptor. }
    GetMem (lVRAM, SizeOf (DOS_VGAScreenBitmap));
    if not Assigned (lVRAM) then
    begin
      anError := anNoMemoryError;
      Exit (Nil)
    end;
  { Initialize VRAM data. }
    lVRAM^.Segment := segment_to_descriptor (DOS_Mode13hVRAM);
    lVRAM^.Bitmap._Protected._Data := Pointer (DOS_Mode13hVRAM);
    lVRAM^.Bitmap._VT._Destructor := @_anFixedBitmapDestructor;
    lVRAM^.Bitmap._VT._DrawPixel := @DOS_Mode13hDrawPixel;
    lVRAM^.Bitmap._VT._GetPixel := @DOS_Mode13hGetPixel;
  { Init Mode 13h. }
    asm
      movw $0x0013, %ax
      int $0x10
    end;
  { All is ok. }
    InitMode13h := Pointer (lVRAM)
  end;

