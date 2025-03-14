unit PhotoDetailsService;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  ServerAPI.Interfaces, ServerAPI.Models, ServerAPI.ViewModels,
  System.Threading;

type
  TPhotoDetailsService = class(TInterfacedObject, IPhotoDetailsService)
  private
    FPhotosRepository: IPhotosRepository;
    FAlbumsRepository: IAlbumsRepository;
    FAlbumHelperService: IAlbumHelperService;
  public
    constructor Create(PhotosRepository: IPhotosRepository; AlbumsRepository: IAlbumsRepository; AlbumHelperService: IAlbumHelperService);
    function GetPhotoViewModelByIdAsync(PhotoID: Integer): ITask<PhotoViewModel>;
  end;

implementation

constructor TPhotoDetailsService.Create(PhotosRepository: IPhotosRepository; AlbumsRepository: IAlbumsRepository; AlbumHelperService: IAlbumHelperService);
begin
  inherited Create;
  FPhotosRepository := PhotosRepository;
  FAlbumsRepository := AlbumsRepository;
  FAlbumHelperService := AlbumHelperService;
end;

function TPhotoDetailsService.GetPhotoViewModelByIdAsync(PhotoID: Integer): ITask<PhotoViewModel>;
begin
  Result := TTask<PhotoViewModel>.Create(
    procedure
    var
      Photo: TPhotoSlim;
      Album: TAlbum;
    begin
      Photo := FPhotosRepository.GetPhotoSlimByIdAsync(PhotoID).Result;
      if Photo = nil then
      begin
        Result := nil;
        Exit;
      end;

      Album := FAlbumsRepository.GetAlbumByIdAsync(Photo.AlbumID).Result;

      Result := TPhotoViewModel.Create;
      Result.AlbumCaption := IfThen(Assigned(Album), Album.Caption, '');
      Result.AlbumID := Photo.AlbumID;
      Result.Caption := Photo.Caption;
      Result.PhotoID := Photo.PhotoID;
    end
  );
end;

end.

