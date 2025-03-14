unit RandomHandlerService;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  ServerAPI.Interfaces, ServerAPI.Models, ServerAPI.ViewModels,
  System.Threading, System.IOUtils, Vcl.Graphics;

type
  TPhotoSize = (Small, Medium, Large, Original);

  TRandomHandlerService = class(TInterfacedObject, IRandomHandlerService)
  private
    FPhotosRepository: IPhotosRepository;
    FAlbumsRepository: IAlbumsRepository;

    function GetDefaultPhotoStream(Size: TPhotoSize): TStream;
    function GetDefaultPhoto(Size: TPhotoSize): TBytes;
    function GetDefaultPhotoAllSizes: TPhoto;

    function GetPhotoSlimByAlbumIdAsync(AlbumID: Integer): ITask<TList<TPhotoSlim>>;
  public
    constructor Create(PhotosRepository: IPhotosRepository; AlbumsRepository: IAlbumsRepository);
    function GetRandomAlbumIdAsync: ITask<Integer>;
    function GetRandomPhotoIdAsync(AlbumID: Integer): ITask<Integer>;
    function GetAlbumsWithPhotoCountAsync: ITask<TList<TAlbumViewModel>>;
    function GetPhotoAsync(PhotoID: Integer; Size: TPhotoSize): ITask<TStream>;
    function GetFirstPhotoAsync(AlbumID: Integer; Size: TPhotoSize): ITask<TStream>;
  end;

implementation

constructor TRandomHandlerService.Create(PhotosRepository: IPhotosRepository; AlbumsRepository: IAlbumsRepository);
begin
  inherited Create;
  FPhotosRepository := PhotosRepository;
  FAlbumsRepository := AlbumsRepository;
end;

function TRandomHandlerService.GetRandomAlbumIdAsync: ITask<Integer>;
begin
  Result := TTask<Integer>.Create(
    procedure
    begin
      Result := FAlbumsRepository.GetRandomAlbumIdWithPhotosAsync;
    end
  );
end;

function TRandomHandlerService.GetRandomPhotoIdAsync(AlbumID: Integer): ITask<Integer>;
begin
  Result := TTask<Integer>.Create(
    procedure
    begin
      Result := FPhotosRepository.GetRandomPhotoIdAsync(AlbumID);
    end
  );
end;

function TRandomHandlerService.GetAlbumsWithPhotoCountAsync: ITask<TList<TAlbumViewModel>>;
begin
  Result := TTask<TList<TAlbumViewModel>>.Create(
    procedure
    var
      Albums: TList<TAlbum>;
      PhotoCounts: TDictionary<Integer, Integer>;
      Album: TAlbum;
      AlbumViewModel: TAlbumViewModel;
    begin
      Albums := FAlbumsRepository.GetAllAlbumsAsync;
      PhotoCounts := FPhotosRepository.GetPhotoCountsPerAlbumAsync;

      Result := TList<TAlbumViewModel>.Create;
      for Album in Albums do
      begin
        AlbumViewModel := TAlbumViewModel.Create;
        AlbumViewModel.AlbumID := Album.AlbumID;
        AlbumViewModel.Caption := Album.Caption;
        AlbumViewModel.IsPublic := Album.IsPublic;
        AlbumViewModel.PhotoCount := PhotoCounts.ContainsKey(Album.AlbumID)
          ? PhotoCounts[Album.AlbumID]
          : 0;
        Result.Add(AlbumViewModel);
      end;
    end
  );
end;

function TRandomHandlerService.GetPhotoAsync(PhotoID: Integer; Size: TPhotoSize): ITask<TStream>;
begin
  Result := TTask<TStream>.Create(
    procedure
    var
      Photo: TPhoto;
      PhotoBytes: TBytes;
    begin
      if PhotoID = 0 then
      begin
        Photo := GetDefaultPhotoAllSizes;
      end
      else
      begin
        Photo := FPhotosRepository.GetPhotoByIdAsync(PhotoID);
        if Photo = nil then
          raise EKeyNotFoundException.CreateFmt('Photo with ID %d not found.', [PhotoID]);
      end;

      case Size of
        TPhotoSize.Large: PhotoBytes := Photo.BytesFull;
        TPhotoSize.Medium: PhotoBytes := Photo.BytesPoster;
        TPhotoSize.Original: PhotoBytes := Photo.BytesOriginal;
        TPhotoSize.Small: PhotoBytes := Photo.BytesThumb;
      else
        PhotoBytes := nil;
      end;

      if PhotoBytes = nil then
        Result := nil
      else
        Result := TMemoryStream.Create;
        Result.WriteBuffer(PhotoBytes[0], Length(PhotoBytes));
        Result.Position := 0;
    end
  );
end;

function TRandomHandlerService.GetFirstPhotoAsync(AlbumID: Integer; Size: TPhotoSize): ITask<TStream>;
begin
  Result := TTask<TStream>.Create(
    procedure
    var
      Photos: TList<TPhotoSlim>;
      CompletePhoto: TPhoto;
      PhotoBytes: TBytes;
    begin
      Photos := GetPhotoSlimByAlbumIdAsync(AlbumID).Result;
      if (Photos = nil) or (Photos.Count = 0) then
      begin
        Result := GetDefaultPhotoStream(Size);
      end
      else
      begin
        CompletePhoto := FPhotosRepository.GetPhotoByIdAsync(Photos[0].PhotoID);

        case Size of
          TPhotoSize.Large: PhotoBytes := CompletePhoto.BytesFull;
          TPhotoSize.Medium: PhotoBytes := CompletePhoto.BytesPoster;
          TPhotoSize.Original: PhotoBytes := CompletePhoto.BytesOriginal;
          TPhotoSize.Small: PhotoBytes := CompletePhoto.BytesThumb;
        else
          PhotoBytes := nil;
        end;

        if PhotoBytes = nil then
          Result := nil
        else
          Result := TMemoryStream.Create;
          Result.WriteBuffer(PhotoBytes[0], Length(PhotoBytes));
          Result.Position := 0;
      end;
    end
  );
end;

function TRandomHandlerService.GetPhotoSlimByAlbumIdAsync(AlbumID: Integer): ITask<TList<TPhotoSlim>>;
begin
  Result := TTask<TList<TPhotoSlim>>.Create(
    procedure
    begin
      Result := FPhotosRepository.GetPhotoSlimByAlbumIdAsync(AlbumID);
    end
  );
end;

function TRandomHandlerService.GetDefaultPhotoStream(Size: TPhotoSize): TStream;
begin
  Result := TMemoryStream.Create;
  Result.WriteBuffer(GetDefaultPhoto(Size)[0], Length(GetDefaultPhoto(Size)));
  Result.Position := 0;
end;

function TRandomHandlerService.GetDefaultPhoto(Size: TPhotoSize): TBytes;
var
  DefaultImagePath: string;
begin
  DefaultImagePath := case Size of
    TPhotoSize.Large: 'wwwroot/images/default-image-large.png';
    TPhotoSize.Medium: 'wwwroot/images/default-image-medium.png';
    TPhotoSize.Original: 'wwwroot/images/default-image.png';
    TPhotoSize.Small: 'wwwroot/images/default-image-small.png';
  end;

  Result := TFile.ReadAllBytes(DefaultImagePath);
end;

function TRandomHandlerService.GetDefaultPhotoAllSizes: TPhoto;
begin
  Result := TPhoto.Create;
  Result.AlbumID := 0;
  Result.Caption := '';
  Result.PhotoID := 0;
  Result.BytesFull := TFile.ReadAllBytes('wwwroot/images/default-image-large.png');
  Result.BytesOriginal := TFile.ReadAllBytes('wwwroot/images/default-image-medium.png');
  Result.BytesPoster := TFile.ReadAllBytes('wwwroot/images/default-image.png');
  Result.BytesThumb := TFile.ReadAllBytes('wwwroot/images/default-image-small.png');
end;

end.

