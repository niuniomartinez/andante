(* Implements the timer for DOS 32bits. *)

  const
  (* BIOS clock configuration. *)
    BIOS_PITFreq = $1234DD;
    BIOS_ClockUpdateAt = $10000;
    BIOS_Counter = BIOS_PITFreq div anTimerFrequency;

  var
  (* Interrupt handlers information. *)
    DOS_OldTimerHandlerInfo, DOS_NewTimerHandlerInfo: TSegInfo;
  (* How many ticks since last interrupt. *)
    DOS_ClockTicks: LongInt;



(* The new timer handler. *)
  procedure DOS_TimerHandler; interrupt;
  begin
  { Update. }
    Inc (anTimerCounter);
  { Adjust the count of clock ticks. }
{ For some reason it doesn't work (should I re-learn assembler for 32bit?).

  Note: Remember to lock/unlock the variables.
    Inc (DOS_ClockTicks, BIOS_Counter);
    if DOS_ClockTicks >= $10000 then
    begin
      Dec (DOS_ClockTicks, $10000);
      asm
        ljmp %cs:DOS_OldTimerHandlerInfo.offset
      end
    end
    else
}
    { Acknowledge the interrupt. }
      Port[anAcknowledgePort] := anAcknowledgeOk
  end;



{$PUSH} { Ignore next warnings. }
{$WARN 4055 OFF : Conversion between ordinals and pointer is not portable }
{$WARN 4082 OFF : Converting pointers to signed integers may result in wrong
                  comparison results and range errors, use an unsigned type
                  instead }

(* Timer inicialization. *)
  function _InstallTimer: Boolean;
  var
    lIsOk: Boolean;
  begin
  { Lock data and code. }
    lock_data (anTimerCounter, SizeOf (anKeyState));
  { The code that use this is disabled.
    lock_data (DOS_ClockTicks, SizeOf (DOS_ClockTicks));
    lock_data (DOS_OldTimerHandlerInfo, SizeOf (DOS_OldTimerHandlerInfo));
  }
    lock_code (
      @DOS_TimerHandler,
      LongInt (@_InstallTimer) - LongInt (@DOS_TimerHandler)
    );
  { Get default timer handler. }
    get_pm_interrupt (anTimerInt, DOS_OldTimerHandlerInfo);
  { Disable interruptions. }
    Disable;
  { Set the PIT channel 0 frequency. }
    Port[anPITControlPort] := $34;
    Port[anPITChannel0Port] := BIOS_counter mod 256;
    Port[anPITChannel0Port] := BIOS_counter div 256;
  { Set new timer handler. }
    DOS_NewTimerHandlerInfo.offset := @DOS_TimerHandler;
    DOS_NewTimerHandlerInfo.segment := get_cs;
    lIsOk := set_pm_interrupt (anTimerInt, DOS_NewTimerHandlerInfo);
  { Restore interruptions. }
    Enable;
  { Check result. }
    if lIsOk then
    begin
    { Init counters. }
      DOS_ClockTicks := 0;
      anTimerCounter := 0;
    { Done. }
      Exit (True)
    end
    else begin
    { There were an arror. }
      anError := anCantInitialize;
      Exit (False)
    end
  end;



(* Timer finalization. *)
  procedure _UninstallTimer;
  var
    lIgnore: Boolean;
  begin
  { Disable interruptions. }
    Disable;
  { Set old frequency. }
    Port[$43] := $34;
    Port[$40] := 0;
    Port[$40] := 0;
  { Reset old handler. }
    lIgnore := set_pm_interrupt (anTimerInt, DOS_OldTimerHandlerInfo);
  { Restore interruptions. }
    Enable;
  { Unlock memory and code. }
    unlock_data (anTimerCounter, SizeOf (anTimerCounter));
  { The code that use this is disabled.
    unlock_data (DOS_ClockTicks, SizeOf (DOS_ClockTicks));
    unlock_data (DOS_OldTimerHandlerInfo, SizeOf (DOS_OldTimerHandlerInfo));
  }
    unlock_code (
      @DOS_TimerHandler,
      LongInt (@_InstallTimer) - LongInt (@DOS_TimerHandler)
    )
  end;

{$POP}
