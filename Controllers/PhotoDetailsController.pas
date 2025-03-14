unit PhotoDetailsController;

interface

uses
  System.SysUtils, System.Classes, MVCFramework, ServerAPI.Interfaces, ServerAPI.Models;

type
  TPhotoDetailsController = class(TMVCController)
  private
    const SessionRandomPhotoID = 'RandomPhotoID';
    FPhotoDetailsService: IPhotoDetailsService;
  public
    constructor Create(const APhotoDetailsService: IPhotoDetailsService); reintroduce;

    [HttpGet]
    [Route('api/photodetails/{id}')]
    procedure GetPhotoById(const Id: Integer);

    [HttpGet]
    [Route('api/photodetails/savedphotoid')]
    procedure GetSavedRandomPhotoID;
  end;

implementation

{ TPhotoDetailsController }

constructor TPhotoDetailsController.Create(const APhotoDetailsService: IPhotoDetailsService);
begin
  inherited Create;
  FPhotoDetailsService := APhotoDetailsService;
end;

procedure TPhotoDetailsController.GetPhotoById(const Id: Integer);
var
  Photo: TPhotoViewModel;
begin
  // Hämtar fotoinformation via tjänsten
  Photo := FPhotoDetailsService.GetPhotoViewModelById(Id);
  Render(200, Photo);  // Returnerar fotoinformation som JSON
end;

procedure TPhotoDetailsController.GetSavedRandomPhotoID;
var
  RandomPhotoID: string;
  IDd: Integer;
begin
  RandomPhotoID := Session[SessionRandomPhotoID];

  if (RandomPhotoID <> '') and TryStrToInt(RandomPhotoID, IDd) then
  begin
    Render(200, IDd);  // Returnerar det sparade fotot-ID
  end
  else
  begin
    Render(200, 0);  // Returnerar 0 om inget ID hittades
  end;
end;

end.

