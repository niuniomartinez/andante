unit anBitmap;
(***< Defines and implements bitmaps and drawing routines.

  @include(../docs/anbitmap.pds) *)
(* See LICENSE.txt for copyright information. *)

interface

  type
  (*** Pointer to a @link(anBitmap) *)
    andanteBitmapPtr = ^andanteBitmap;
  (*** @exclude Bitmap method definitions. *)
    _andanteBitmapMethod = procedure (b: andanteBitmapPtr);
    _andantePixelMethod =
      procedure (b: andanteBitmapPtr; const x, y, c: LongInt); {**<@exclude }
    _andanteGetPixelMethod =
      function (b: andanteBitmapPtr; const x, y: LongInt): LongInt; {**<@exclude }

  (*** @exclude Define the virtual methods for the bitmap. *)
    _andanteBmpVirtualMethods = record
    (* Destroys the bitmap releasing all resources. *)
      _Destructor: _andanteBitmapMethod;
    (* Drawing primitives. *)
      _DrawPixel: _andantePixelMethod;
      _GetPixel: _andanteGetPixelMethod;
    end;

  (*** @exclude Protected properties. *)
    _andanteBmpProtectedProperties = record
    (* Pointer to the bitmap data. *)
      _Data: pointer;
    end;



  (*** Stores the content of a bitmap. *)
    andanteBitmap = record
      Width, Height, Depth: Integer;
    (*** @exclude Private properties. *)
      _Protected: _andanteBmpProtectedProperties;
    (*** @exclude Virtual methods. *)
      _VT: _andanteBmpVirtualMethods;
    end;

(*** Destroys the given bitmap. *)
  procedure anDestroyBitmap (aBmp: andanteBitmapPtr); inline;

(* Drawing primitives. *)
  procedure anDrawPixel (aBmp: andanteBitmapPtr; const x, y, c: LongInt);
    inline;
  function anGetPixel (aBmp: andanteBitmapPtr; const x, y: LongInt): LongInt;
    inline;

implementation

  procedure anDestroyBitmap (aBmp: andanteBitmapPtr);
  begin
    if Assigned (aBmp) then aBmp^._VT._Destructor (aBmp)
  end;



(* Drawing primitives. *)

  procedure anDrawPixel (aBmp: andanteBitmapPtr; const x, y, c: LongInt);
  begin
    aBmp^._VT._DrawPixel (aBmp, x, y, c)
  end;



  function anGetPixel (aBmp: andanteBitmapPtr; const x, y: LongInt): LongInt;
  begin
    anGetPixel := aBmp^._VT._GetPixel (aBmp, x, y)
  end;

end.
