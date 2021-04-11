(* Implements the timer for DOS 16bits. *)

  const
  (* BIOS clock configuration. *)
    BIOS_PITFreq = $1234DD;
    BIOS_ClockUpdateAt = $10000;
    BIOS_Counter = BIOS_PITFreq div anTimerFrequency;

  var
  (* Original interruption handler. *)
    DOS_OldTimerHandler: Pointer = Nil;
  (* To access to the old PIT handler as a procedure. *)
    DOS_OldTimerHandlerProc: procedure absolute DOS_OldTimerHandler;
  (* How many ticks since last interrupt. *)
    DOS_ClockTicks: LongInt;



(* The new timer handler. *)
  procedure DOS_TimerHandler; interrupt; far;
  begin
  { Update. }
    Inc (anTimerCounter);
  { Adjust the count of clock ticks. }
    Inc (DOS_ClockTicks, BIOS_counter);
  { Is it time for the BIOS handler to do it's thang? }
    if DOS_ClockTicks >= BIOS_ClockUpdateAt then
    begin
    { Yep! So adjust the count and call the BIOS handler. }
      DOS_ClockTicks := DOS_ClockTicks - BIOS_ClockUpdateAt;
      asm pushf end;
      DOS_OldTimerHandlerProc
    end
    else
    { If not then just acknowledge the interrupt. }
      Port[anAcknowledgePort] := anAcknowledgeOk
  end;



(* Timer inicialization. *)
  function _InstallTimer: Boolean;
  begin
  { Do some initialization. }
    DOS_ClockTicks := 0;
    anTimerCounter := 0;
  { Store the current BIOS handler and set up our own. }
    GetIntVec (anTimerInt, DOS_OldTimerHandler);
    SetIntVec (anTimerInt, @TimerHandler);
  { Set the PIT channel 0 frequency. }
    Port[anPITControlPort] := $34;
    Port[anPITChannel0Port] := BIOS_counter mod 256;
    Port[anPITChannel0Port] := BIOS_counter div 256;
  { All ok. }
    _InstallTimer := True
  end;



(* Timer finalization. *)
  procedure _UninstallTimer;
  begin
  { Restore the normal clock frequency. }
    Port[anPITControlPort] := $34;
    Port[anPITChannel0Port] := 0;
    Port[anPITChannel0Port] := 0;
  { Restore the normal ticker handler }
    SetIntVec (anTimerInt, DOS_OldTimerHandler)
  end;

