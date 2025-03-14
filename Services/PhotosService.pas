unit PhotosService;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  ServerAPI.Interfaces, ServerAPI.Models, ServerAPI.ViewModels,
  System.Threading, Vcl.Graphics, System.IOUtils,
  SixLabors.ImageSharp, SixLabors.ImageSharp.Formats.Jpeg,
  SixLabors.ImageSharp.Processing;

type
  TPhotosService = class(TInterfacedObject, IPhotosService)
  private
    FPhotosRepository: IPhotosRepository;
    FAlbumsRepository: IAlbumsRepository;

    class function ResizeImageFile(const ImageFile: TBytes; TargetSize: Integer): TBytes; static;
    class function CalculateDimensions(const OriginalSize: TSize; TargetSize: Integer): TSize; static;

  public
    constructor Create(PhotosRepository: IPhotosRepository; AlbumsRepository: IAlbumsRepository);
    procedure AddPhotoAsync(AlbumID: Integer; Caption: string; const BytesOriginal: TBytes);
    procedure DeletePhotoAsync(PhotoID: Integer);
    function GetPhotosViewModelByAlbumIdAsync(AlbumID: Integer): ITask<TList<PhotoViewModel>>;
    procedure UpdatePhotoAsync(Caption: string; PhotoID: Integer);
  end;

implementation

constructor TPhotosService.Create(PhotosRepository: IPhotosRepository; AlbumsRepository: IAlbumsRepository);
begin
  inherited Create;
  FPhotosRepository := PhotosRepository;
  FAlbumsRepository := AlbumsRepository;
end;

procedure TPhotosService.AddPhotoAsync(AlbumID: Integer; Caption: string; const BytesOriginal: TBytes);
var
  Photo: TPhoto;
begin
  FPhotosRepository.BeginTransactionAsync;

  try
    Photo := TPhoto.Create;
    try
      Photo.AlbumID := AlbumID;
      Photo.Caption := Caption;
      Photo.BytesOriginal := BytesOriginal;
      Photo.BytesFull := ResizeImageFile(BytesOriginal, 600);
      Photo.BytesPoster := ResizeImageFile(BytesOriginal, 198);
      Photo.BytesThumb := ResizeImageFile(BytesOriginal, 100);
      Photo.PhotoID := 0;

      FPhotosRepository.AddPhotoAsync(Photo);
      FPhotosRepository.SaveChangesAsync;
      FPhotosRepository.CommitTransactionAsync;
    finally
      Photo.Free;
    end;
  except
    on E: Exception do
    begin
      FPhotosRepository.RollbackTransactionAsync;
      raise;
    end;
  end;
end;

procedure TPhotosService.DeletePhotoAsync(PhotoID: Integer);
begin
  FPhotosRepository.BeginTransactionAsync;

  try
    FPhotosRepository.DeletePhoto(PhotoID);
    FPhotosRepository.SaveChangesAsync;
    FPhotosRepository.CommitTransactionAsync;
  except
    on E: Exception do
    begin
      FPhotosRepository.RollbackTransactionAsync;
      raise;
    end;
  end;
end;

function TPhotosService.GetPhotosViewModelByAlbumIdAsync(AlbumID: Integer): ITask<TList<PhotoViewModel>>;
begin
  Result := TTask<TList<PhotoViewModel>>.Create(
    procedure
    var
      Album: TAlbum;
      Photos: TList<TPhotoSlim>;
      Photo: TPhotoSlim;
      PhotoViewModel: PhotoViewModel;
    begin
      Album := FAlbumsRepository.GetAlbumByIdAsync(AlbumID);
      Photos := FPhotosRepository.GetPhotoSlimByAlbumIdAsync(AlbumID).Result;

      Result := TList<PhotoViewModel>.Create;
      try
        for Photo in Photos do
        begin
          PhotoViewModel := PhotoViewModel.Create;
          try
            PhotoViewModel.AlbumCaption := Album.Caption;
            PhotoViewModel.AlbumID := Photo.AlbumID;
            PhotoViewModel.Caption := Photo.Caption;
            PhotoViewModel.PhotoID := Photo.PhotoID;
            Result.Add(PhotoViewModel);
          except
            PhotoViewModel.Free;
            raise;
          end;
        end;
      except
        Result.Free;
        raise;
      end;
    end
  );
end;

procedure TPhotosService.UpdatePhotoAsync(Caption: string; PhotoID: Integer);
begin
  FPhotosRepository.BeginTransactionAsync;

  try
    FPhotosRepository.UpdatePhoto(Caption, PhotoID);
    FPhotosRepository.SaveChangesAsync;
    FPhotosRepository.CommitTransactionAsync;
  except
    on E: Exception do
    begin
      FPhotosRepository.RollbackTransactionAsync;
      raise;
    end;
  end;
end;

class function TPhotosService.ResizeImageFile(const ImageFile: TBytes; TargetSize: Integer): TBytes;
var
  Image: IImage;
  NewSize: TSize;
  MemoryStream: TMemoryStream;
begin
  Image := ImageSharp.Image.Load(ImageFile);
  NewSize := CalculateDimensions(Image.Size, TargetSize);
  Image.Mutate(
    procedure
    begin
      x.Resize(NewSize.Width, NewSize.Height);
    end
  );

  MemoryStream := TMemoryStream.Create;
  try
    Image.Save(MemoryStream, TJpegEncoder.Create);
    SetLength(Result, MemoryStream.Size);
    MemoryStream.Position := 0;
    MemoryStream.ReadBuffer(Pointer(Result)^, MemoryStream.Size);
  finally
    MemoryStream.Free;
  end;
end;

class function TPhotosService.CalculateDimensions(const OriginalSize: TSize; TargetSize: Integer): TSize;
var
  AspectRatio: Double;
begin
  AspectRatio := OriginalSize.Width / OriginalSize.Height;
  if AspectRatio > 1 then
  begin
    Result.Width := TargetSize;
    Result.Height := Round(TargetSize / AspectRatio);
  end
  else
  begin
    Result.Width := Round(TargetSize * AspectRatio);
    Result.Height := TargetSize;
  end;
end;

end.

