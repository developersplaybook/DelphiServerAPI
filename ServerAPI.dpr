program ServerAPI;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  MVCFramework,
  AlbumsController in 'Controllers\AlbumsController.pas',
  AuthorizationController in 'Controllers\AuthorizationController.pas',
  PhotoDetailsController in 'Controllers\PhotoDetailsController.pas',
  PhotosController in 'Controllers\PhotosController.pas',
  RandomHandlerController in 'Controllers\RandomHandlerController.pas',
  IAlbumHelperServiceIntf in 'Interfaces\IAlbumHelperServiceIntf.pas',
  IAlbumsRepositoryIntf in 'Interfaces\IAlbumsRepositoryIntf.pas',
  IAlbumsServiceIntf in 'Interfaces\IAlbumsServiceIntf.pas',
  IAlbumValidatorIntf in 'Interfaces\IAlbumValidatorIntf.pas',
  IPhotoDetailsServiceIntf in 'Interfaces\IPhotoDetailsServiceIntf.pas',
  IPhotosRepositoryIntf in 'Interfaces\IPhotosRepositoryIntf.pas',
  IPhotosServiceIntf in 'Interfaces\IPhotosServiceIntf.pas',
  IRandomHandlerServiceIntf in 'Interfaces\IRandomHandlerServiceIntf.pas',
  AlbumViewModel in 'ViewModels\AlbumViewModel.pas',
  Album in 'Models\Album.pas',
  AlbumValidationResult in 'Models\AlbumValidationResult.pas',
  DateTimeUtil in 'Models\DateTimeUtil.pas',
  Photo in 'Models\Photo.pas',
  PhotoSize in 'Models\PhotoSize.pas',
  PhotoSlim in 'Models\PhotoSlim.pas',
  SessionExtensions in 'Models\SessionExtensions.pas',
  ServerAPI.Interfaces in 'ServerAPI.Interfaces.pas',
  ServerAPI.Controllers in 'ServerAPI.Controllers.pas',
  ServerAPI.Models in 'ServerAPI.Models.pas',
  ServerAPI.ViewModels in 'ServerAPI.ViewModels.pas',
  PhotoViewModel in 'ViewModels\PhotoViewModel.pas',
  AlbumHelperService in 'Services\AlbumHelperService.pas',
  AlbumsService in 'Services\AlbumsService.pas',
  AlbumValidator in 'Services\AlbumValidator.pas',
  KeyService in 'Services\KeyService.pas',
  PhotoDetailsService in 'Services\PhotoDetailsService.pas',
  PhotosService in 'Services\PhotosService.pas',
  RandomHandlerService in 'Services\RandomHandlerService.pas',
  ServerAPI.Services in 'ServerAPI.Services.pas';

// Detta är den centrala enheten för MVC Framework

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
