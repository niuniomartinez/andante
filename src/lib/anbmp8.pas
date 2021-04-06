unit anBmp8;
(***<Implements 8 bit per pixel bitmaps. *)
(* See LICENSE.txt for copyright information. *)

interface

  uses
    anBitmap;

(*** Creates an 8 bit per pixel bitmap. *)
  function anCreate8bitBitmap (const w, h: Integer): andanteBitmapPtr;

implementation

(* Destroys an 8bit bitmap. *)
  procedure _Destroy8bitBitmap (aBmp: andanteBitmapPtr);
  begin
    FreeMem (aBmp^._Protected._Data);
    FreeMem (aBmp)
  end;



(* Drawing primitives. *)
  procedure _Draw8bitPixel (aBmp: andanteBitmapPtr; const x, y, c: LongInt);
  begin
    IF (0 <= x) AND (x < aBmp^.Width) AND (0 <= y) AND (y < aBmp^.Height) THEN
      PByte (aBmp^._Protected._Data)[(y * aBmp^.Width) + x] := c
  end;



  function _Get8bitPixel (aBmp: andanteBitmapPtr; const x, y: LongInt): LongInt;
  begin
    IF (0 <= x) AND (x < aBmp^.Width) AND (0 <= y) AND (y < aBmp^.Height) THEN
      _Get8bitPixel := PByte (aBmp^._Protected._Data)[(y * aBmp^.Width) + x]
    else
      _Get8bitPixel := -1
  end;



(* Creates an 8 bit per pixel bitmap. *)
  function anCreate8bitBitmap (const w, h: Integer): andanteBitmapPtr;
  begin
    GetMem (anCreate8bitBitmap, SizeOf (andanteBitmap));
    if Assigned (anCreate8bitBitmap) then
    begin
      GetMem (anCreate8bitBitmap^._Protected._Data, w * h);
      if not Assigned (anCreate8bitBitmap^._Protected._Data) then
      begin
        FreeMem (anCreate8bitBitmap, SizeOf (andanteBitmap));
        Exit (Nil)
      end;
      anCreate8bitBitmap^._VT._Destructor := @_Destroy8bitBitmap;
      anCreate8bitBitmap^._VT._DrawPixel := @_Draw8bitPixel;
      anCreate8bitBitmap^._VT._GetPixel := @_Get8bitPixel
    end
  end;

end.
