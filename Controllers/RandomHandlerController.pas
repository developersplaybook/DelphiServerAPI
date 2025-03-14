unit RandomHandlerController;

interface

uses
  System.SysUtils, System.Classes, MVCFramework, ServerAPI.Interfaces, ServerAPI.Models,
  System.IOUtils, System.Threading;

type
  TPhotoSize = (Small, Medium, Large, Original);

  TRandomHandlerController = class(TMVCController)
  private
    const SessionRandomPhotoID = 'RandomPhotoID';
    FRandomHandler: IRandomHandlerService;
  public
    constructor Create(const ARandomHandler: IRandomHandlerService); reintroduce;

    [HttpGet]
    [Route('api/images')]
    procedure Index(const Arg1, Arg2: string);

    [HttpGet]
    [Route('api/images/download')]
    procedure Download(const Arg1, Arg2: string);
  private
    procedure ProcessPhotoIdRequest(const Arg1: string; Size: TPhotoSize; Stream: TMemoryStream);
    procedure ProcessAlbumIdRequest(const Arg1: string; Size: TPhotoSize; Stream: TMemoryStream);
  end;

implementation

{ TRandomHandlerController }

constructor TRandomHandlerController.Create(const ARandomHandler: IRandomHandlerService);
begin
  inherited Create;
  FRandomHandler := ARandomHandler;
end;

procedure TRandomHandlerController.Index(const Arg1, Arg2: string);
var
  Size: TPhotoSize;
  Stream: TMemoryStream;
begin
  if Arg2 = 'Size=S' then
    Size := Small
  else if Arg2 = 'Size=M' then
    Size := Medium
  else if Arg2 = 'Size=L' then
    Size := Large
  else
    Size := Original;

  Stream := TMemoryStream.Create;
  try
    if Arg1.StartsWith('PhotoID') then
      ProcessPhotoIdRequest(Arg1, Size, Stream)
    else if Arg1.StartsWith('AlbumID') then
      ProcessAlbumIdRequest(Arg1, Size, Stream);

    Render(200, Stream.Memory, 'image/png');
  finally
    Stream.Free;
  end;
end;

procedure TRandomHandlerController.ProcessPhotoIdRequest(const Arg1: string; Size: TPhotoSize; Stream: TMemoryStream);
var
  PhotoId: Integer;
  RandomAlbumId: Integer;
  ResultStream: TMemoryStream;
begin
  if Arg1 = 'PhotoID=0' then
  begin
    RandomAlbumId := FRandomHandler.GetRandomAlbumIdAsync;
    PhotoId := FRandomHandler.GetRandomPhotoIdAsync(RandomAlbumId);
    Session[SessionRandomPhotoID] := IntToStr(PhotoId);
  end
  else
    PhotoId := StrToInt(Arg1.Replace('PhotoID=', ''));

  ResultStream := FRandomHandler.GetPhotoAsync(PhotoId, Size);
  ResultStream.CopyTo(Stream);
end;

procedure TRandomHandlerController.ProcessAlbumIdRequest(const Arg1: string; Size: TPhotoSize; Stream: TMemoryStream);
var
  AlbumId: Integer;
  ResultStream: TMemoryStream;
begin
  AlbumId := StrToInt(Arg1.Replace('AlbumID=', ''));
  ResultStream := FRandomHandler.GetFirstPhotoAsync(AlbumId, Size);
  ResultStream.CopyTo(Stream);
end;

procedure TRandomHandlerController.Download(const Arg1, Arg2: string);
var
  PhotoId: string;
begin
  if Arg1 = '0' then
    PhotoId := Session[SessionRandomPhotoID]
  else
    PhotoId := Arg1;

  ViewData['PhotoID'] := PhotoId;
  ViewData['Size'] := 'L';

  RenderView('Download');
end;

end.

