unit SystemAn;
(* Implements DOS core. *)

interface

(* Initializes target specific stuff.

   Should return False and set anError if there were a problem. *)
  function Init: Boolean;
(* Closes the system. *)
  procedure Uninstall;

implementation

(* Initializes the system. *)
  function Init: Boolean;
  begin
    Init := True
  end;



(* Closes the system. *)
  procedure Uninstall;
  begin
  end;

end.
