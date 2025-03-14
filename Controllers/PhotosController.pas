unit PhotosController;

interface

uses
  System.SysUtils, System.Classes, MVCFramework, ServerAPI.Interfaces, ServerAPI.Models, ServerAPI.ViewModels;

type
  TPhotosController = class(TMVCController)
  private
    const SessionRandomPhotoID = 'RandomPhotoID';
    FPhotosService: IPhotosService;
    FPhotoDetailsService: IPhotoDetailsService;
  public
    constructor Create(const APhotosService: IPhotosService; const APhotoDetailsService: IPhotoDetailsService); reintroduce;

    [HttpGet]
    [Route('api/photos/album/{id}')]
    procedure GetPhotosByAlbumId(const Id: Integer);

    [HttpPost]
    [Route('api/photos/add')]
    [Authorize]
    procedure AddPhoto;

    [HttpPut]
    [Route('api/photos/update/{id}')]
    [Authorize]
    procedure UpdatePhoto(const Id: Integer);

    [HttpDelete]
    [Route('api/photos/delete/{id}')]
    [Authorize]
    procedure DeletePhoto(const Id: Integer);
  end;

  TFormData = class
  public
    AlbumId: Integer;
    Caption: string;
    Image: TFileStream;
  end;

implementation

{ TPhotosController }

constructor TPhotosController.Create(const APhotosService: IPhotosService; const APhotoDetailsService: IPhotoDetailsService);
begin
  inherited Create;
  FPhotosService := APhotosService;
  FPhotoDetailsService := APhotoDetailsService;
end;

procedure TPhotosController.GetPhotosByAlbumId(const Id: Integer);
var
  PhotoList: TArray<PhotoViewModel>;
  RandomPhotoID: string;
  RandomPhotoId: Integer;
  TmpPhoto: TPhotoViewModel;
begin
  if Id = 0 then
  begin
    RandomPhotoID := Session[SessionRandomPhotoID];
    if (RandomPhotoID <> '') and TryStrToInt(RandomPhotoID, RandomPhotoId) then
    begin
      TmpPhoto := FPhotoDetailsService.GetPhotoViewModelById(RandomPhotoId);
      PhotoList := FPhotosService.GetPhotosViewModelByAlbumId(TmpPhoto.AlbumID);
      Render(200, PhotoList); // Return all photos in album
    end
    else
    begin
      Render(200, nil); // No photos found
    end;
  end
  else
  begin
    PhotoList := FPhotosService.GetPhotosViewModelByAlbumId(Id);
    Render(200, PhotoList); // Return all photos in album
  end;
end;

procedure TPhotosController.AddPhoto;
var
  FormData: TFormData;
  FileBytes: TBytes;
begin
  FormData := TFormData.Create;
  try
    FormData.AlbumId := GetFormDataAsInteger('AlbumId');
    FormData.Caption := GetFormDataAsString('Caption');
    FormData.Image := GetFormDataAsFileStream('Image');

    SetLength(FileBytes, FormData.Image.Size);
    FormData.Image.ReadBuffer(FileBytes[0], FormData.Image.Size);

    FPhotosService.AddPhoto(FormData.AlbumId, FormData.Caption, FileBytes);
    Render(200, { 'message': 'Photo added successfully.' });
  finally
    FormData.Free;
  end;
end;

procedure TPhotosController.UpdatePhoto(const Id: Integer);
var
  Caption: string;
begin
  Caption := GetBodyAsString; // Body contains the caption
  FPhotosService.UpdatePhoto(Caption, Id);
  Render(200, { 'message': 'Photo updated successfully.' });
end;

procedure TPhotosController.DeletePhoto(const Id: Integer);
begin
  FPhotosService.DeletePhoto(Id);
  Render(200, { 'message': 'Photo deleted successfully.' });
end;

end.

