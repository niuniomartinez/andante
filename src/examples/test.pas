program test;
(* Test program. *)
uses
  andante, anBitmap, anVga;

  type
    TPoint = record x, y: Real end;
    TSprite = record
      Color, cInc: Integer;
      Position, Increment: TPoint
    end;

  var
    Atractors: array [1..8] of TPoint;
    Ball: TSprite;



(* Helper to show error messages. *)
  procedure ShowError (aMessage: String);
  begin
    WriteLn ('Error [', anError, ']: ', aMessage);
    WriteLn
  end;



(* Initializes. *)
  function InitializeAndante: Boolean;
  begin
    if not anInstall then
    begin
      ShowError ('Can''t initialize Andante!');
      Exit (False)
    end;
    if not anInstallKeyboard then
    begin
      ShowError ('Keyboard out.');
      Exit (False)
    end;
    if not anSetGraphicsMode (anGfx13) then
    begin
      ShowError ('Can''t initialize VGA.');
      Exit (False)
    end;
    Randomize;
    InitializeAndante := True
  end;



(* Create a new field. *)
  procedure CreateField;
  var
    Cnt: Integer;
  begin
    for Cnt := Low (Atractors) to High (Atractors) do
    begin
      anDrawPixel (anScreen, Trunc (Atractors[Cnt].x), Trunc (Atractors[Cnt].y), 0);
      Atractors[Cnt].x := Random (300) + 10;
      Atractors[Cnt].y := Random (180) + 10;
      anDrawPixel (anScreen, Trunc (Atractors[Cnt].x), Trunc (Atractors[Cnt].y), 12)
    end;
    Ball.Position.x := Random (300) + 10;
    Ball.Position.y := Random (180) + 10;
    Ball.Increment.x := 0;
    Ball.Increment.y := 0
  end;



(* Some vector math. *)
  function Add (const vA, vB: TPoint): TPoint; inline;
  begin
    Add.x := vA.x + vB.x;
    Add.y := vA.y + vB.y
  end;



  function Subs (const vA, vB: TPoint): TPoint; inline;
  begin
    Subs.x := vA.x - vB.x;
    Subs.y := vA.y - vB.y
  end;



  function Normalize (const aVector: TPoint): TPoint;
  var
    lLength: Real;
  begin
    lLength := sqrt (aVector.x * aVector.x + aVector.y * aVector.y);
    if lLength <> 0 then
    begin
      Normalize.x := aVector.x / lLength;
      Normalize.y := aVector.y / lLength
    end
    else
      Normalize := aVector
  end;

var
  Cnt: Integer;
  OldCount: LongWord;
begin
  WriteLn ('Andante ', anVersionString);
  WriteLn;
  if not InitializeAndante then Halt;
{ Animation. }
  CreateField;
  Ball.Color := 31; Ball.cInc := -1;
  repeat
    OldCount := anTimerCounter;
  { Press space to create a new field. }
    if anKeyState[anKeySpace] then
    begin
      CreateField;
      anKeyState[anKeySpace] := False
    end;
  { Atraction. }
    for Cnt := Low (Atractors) to High (Atractors) do
      Ball.Increment := Add (
        Ball.Increment,
        Normalize (Subs (Atractors[Cnt], Ball.Position))
      );
  { Animate. }
    Ball.Position := Add (Ball.Position, Ball.Increment);
    Inc (Ball.Color, Ball.cInc); if (Ball.Color = 16) or (Ball.Color = 31) then
      Ball.cInc := -1 * Ball.cInc;
  { Draw. }
    anDrawPixel (
      anScreen,
      Trunc (Ball.Position.x), Trunc (Ball.Position.y),
      Ball.Color
    );
  { Whait... }
    //repeat until anTimerCounter <> OldCount
  until anKeyState[anKeyEscape]
end.
