unit ServerAPI.Services;

interface

uses
  AlbumHelperService,
  AlbumsService,
  AlbumValidator,
  KeyService,
  PhotoDetailsService,
  PhotosService,
  RandomHandlerService;

type
  TAlbumHelperService = AlbumHelperService.TAlbumHelperService;
  TAlbumsService = AlbumsService.TAlbumsService;
  TAlbumValidator = AlbumValidator.TAlbumValidator;
  TKeyService = KeyService.TKeyService;
  TPhotoDetailsService = PhotoDetailsService.TPhotoDetailsService;
  TPhotosService = PhotosService.TPhotosService;
  TRandomHandlerService = RandomHandlerService.TRandomHandlerService;

implementation

end.
