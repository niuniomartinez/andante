unit anBitmap;
(***< Defines and implements bitmaps and drawing routines. *)
(* See LICENSE.txt for copyright information. *)

interface

  type
  (*** Pointer to a @link(anBitmap) *)
    andanteBitmapPtr = ^andanteBitmap;
  (*** @exclude Bitmap method definitions. *)
    _andanteBitmapMethod = procedure (b: andanteBitmapPtr);
    _andantePixelMethod =
      procedure (b: andanteBitmapPtr; const x, y, c: LongInt); {**<@exclude }

  (*** @exclude Define the virtual methods for the bitmap. *)
    _andanteBmpVirtualMethods = record
    (* Destroys the bitmap releasing all resources. *)
      _Destructor: _andanteBitmapMethod;
    (* Drawing primitives. *)
      _DrawPixel: _andantePixelMethod;
    end;

  (*** @exclude Protected properties. *)
    _andanteBmpProtectedProperties = record
    (* Pointer to the bitmap data. *)
      _Data: pointer;
    end;



  (*** Stores or represents a bitmap. *)
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

implementation

  procedure anDestroyBitmap (aBmp: andanteBitmapPtr);
  begin
    aBmp^._VT._Destructor (aBmp)
  end;



(* Drawing primitives. *)

  procedure anDrawPixel (aBmp: andanteBitmapPtr; const x, y, c: LongInt);
  begin
    aBmp^._VT._DrawPixel (aBmp, x, y, c)
  end;

end.
