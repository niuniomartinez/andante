unit anDOSint;
(* Common definitions for DOS target. *)
(* See LICENSE.txt for copyright information. *)
interface

  const
  (* Interrupt vectors. *)
    anTimerInt    = $8;
    anKeyboardInt = $9;
  (* Ports. *)
    anAcknowledgePort = $20;
    anPITChannel0Port = $40;
    anPITControlPort  = $43;
    anKeyboardPort    = $60;
  (* Acknowledge value. *)
    anAcknowledgeOk = $20;

implementation

end.
