unit KeyService;

interface

type
  IKeyService = interface
    ['{B9D55F39-56B7-4C3A-83A9-EDDF5737B54D}']
    function GetKey: string;
  end;

  TKeyService = class(TInterfacedObject, IKeyService)
  private
    FKey: string;
  public
    constructor Create(const AKey: string);
    function GetKey: string;
  end;

implementation

constructor TKeyService.Create(const AKey: string);
begin
  inherited Create;
  FKey := AKey;
end;

function TKeyService.GetKey: string;
begin
  Result := FKey;
end;

end.

