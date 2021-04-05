(* Implements the timer. *)

  CONST
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
(*
    Inc (DOS_PIT_Ticks, DOS_Counter);
    if DOS_PIT_Ticks >= $10000 then
    begin
      Dec (DOS_PIT_Ticks, $10000);
      asm
        ljmp %cs:DOS_OldTimerHandlerInfo
      end
    end
    else
 *)
    { Acknowledge the interruption. }
      Port[$20] := $20
  end;



(* Timer inicialization. *)
  function _InitTimer: Boolean;
  begin
  { Lock data and code. }
    lock_data (anTimerCounter, SizeOf (anKeyState));
    lock_data (DOS_Counter, SizeOf (DOS_Counter));
    lock_data (DOS_PIT_Ticks, SizeOf (DOS_PIT_Ticks));
    lock_code (
      @DOS_TimerHandler,
      LongInt (@_InitTimer) - LongInt (@DOS_TimerHandler)
    );
  { Get default timer handler. }
    get_pm_interrupt (DOS_PIT_Interruption, DOS_OldTimerHandlerInfo);
  { Set new timer handler. }
    DOS_NewTimerHandlerInfo.offset := @DOS_TimerHandler;
    DOS_NewTimerHandlerInfo.segment := get_cs;
    if not set_pm_interrupt (DOS_PIT_Interruption, DOS_NewTimerHandlerInfo) then
    begin
      _UninstallTimer;
      anError := anCantInitialize;
      Exit (False)
    end;
  { Set timer frequency. }
    DOS_Counter := DOS_PIT_Freq div _TimerFreq;
    Port[$43] := $34;
    Port[$40] := DOS_Counter mod 256;
    Port[$40] := DOS_Counter div 256;
  { Init counters. }
    DOS_PIT_Ticks := 0;
    anTimerCounter := 0;
  { Done. }
    _InitTimer := True
  end;



(* Timer finalization. *)
  procedure _UninstallTimer;
  begin
  { Set old frequency. }
    Port[$43] := $34;
    Port[$40] := 0;
    Port[$40] := 0;
  { Reset old handler. }
    if not set_pm_interrupt (DOS_PIT_Interruption, DOS_OldTimerHandlerInfo) then
    { Shouldn't happend but... }
      Halt (-1);
  { Unlock memory and code. }
    unlock_data (anTimerCounter, SizeOf (anTimerCounter));
    unlock_data (DOS_Counter, SizeOf (DOS_Counter));
    unlock_data (DOS_PIT_Ticks, SizeOf (DOS_PIT_Ticks));
    unlock_code (
      @DOS_TimerHandler,
      LongInt (@_InitTimer) - LongInt (@DOS_TimerHandler)
    )
  end;

