unit SystemAn;
(* Implements system initialization specific for the platform. *)

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
  { FOO is a placeholder, so let's say there's no system available. }
    anError := anNoImplementation;
    Init := False
  end;



(* Closes the system. *)
  procedure Uninstall;
  begin
  end;

end.
