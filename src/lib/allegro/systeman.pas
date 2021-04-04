unit SystemAn;
(* Implements Allegro target. *)

interface

(* Initializes target specific stuff.

   Should return False and set anError if there were a problem. *)
  function Init: Boolean;
(* Closes the system. *)
  procedure Uninstall;

implementation

  uses
    andante;

(* Initializes the system. *)
  function Init: Boolean;
  begin
    anError := anNotImplemented;
    Init := False
  end;



(* Closes the system. *)
  procedure Uninstall;
  begin
  end;

end.
