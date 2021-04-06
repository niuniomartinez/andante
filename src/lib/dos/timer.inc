(* Implements the timer. *)

  const
    DOS_PIT_Interruption = $8;
    DOS_PIT_Freq = $1234DD;

  var
  { Old PIT Handler}
    DOS_OldTimerHandlerInfo,
  { New PIT handler }
    DOS_NewTimerHandlerInfo: TSegInfo;
  { Channel 0 counter value. PIT ticks. }
    DOS_Counter, DOS_PIT_Ticks: LongInt;



(* The new timer handler. *)
  procedure DOS_TimerHandler; interrupt;
  begin
  { Update. }
    Inc (anTimerCounter);
  { Check if should update the BIOS handler. }
{ For some reason it doesn't work (should I re-learn assembler for 32bit?).

  Note: Remember to lock/unlock the variables.
    Inc (DOS_PIT_Ticks, DOS_Counter);
    if DOS_PIT_Ticks >= $10000 then
    begin
      Dec (DOS_PIT_Ticks, $10000);
      asm
        ljmp %cs:DOS_OldTimerHandlerInfo.offset
      end
    end
    else
}
    { Acknowledge the interruption. }
      Port[$20] := $20
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
    lock_data (DOS_Counter, SizeOf (DOS_Counter));
    lock_data (DOS_PIT_Ticks, SizeOf (DOS_PIT_Ticks));
    lock_data (DOS_OldTimerHandlerInfo, SizeOf (DOS_OldTimerHandlerInfo));
  }
    lock_code (
      @DOS_TimerHandler,
      LongInt (@_InstallTimer) - LongInt (@DOS_TimerHandler)
    );
  { Get default timer handler. }
    get_pm_interrupt (DOS_PIT_Interruption, DOS_OldTimerHandlerInfo);
  { Disable interruptions. }
    Disable;
  { Set new timer frequency. }
    DOS_Counter := DOS_PIT_Freq div _TimerFreq;
    Port[$43] := $34;
    Port[$40] := DOS_Counter mod 256;
    Port[$40] := DOS_Counter div 256;
  { Set new timer handler. }
    DOS_NewTimerHandlerInfo.offset := @DOS_TimerHandler;
    DOS_NewTimerHandlerInfo.segment := get_cs;
    lIsOk := set_pm_interrupt (DOS_PIT_Interruption, DOS_NewTimerHandlerInfo);
  { Restore interruptions. }
    Enable;
  { Check result. }
    if lIsOk then
    begin
    { Init counters. }
      DOS_PIT_Ticks := 0;
      anTimerCounter := 0;
    { Done. }
      Exit (True)
    end
    else begin
    { There were an arror. }
      anError := anCantInitialize;
      Exit (False)
    end;
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
    lIgnore := set_pm_interrupt (DOS_PIT_Interruption, DOS_OldTimerHandlerInfo);
  { Restore interruptions. }
    Enable;
  { Unlock memory and code. }
    unlock_data (anTimerCounter, SizeOf (anTimerCounter));
  { The code that use this is disabled.
    unlock_data (DOS_Counter, SizeOf (DOS_Counter));
    unlock_data (DOS_PIT_Ticks, SizeOf (DOS_PIT_Ticks));
    unlock_data (DOS_OldTimerHandlerInfo, SizeOf (DOS_OldTimerHandlerInfo));
  }
    unlock_code (
      @DOS_TimerHandler,
      LongInt (@_InstallTimer) - LongInt (@DOS_TimerHandler)
    )
  end;

{$POP}
