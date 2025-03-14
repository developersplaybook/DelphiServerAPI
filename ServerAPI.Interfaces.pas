unit ServerAPI.Interfaces;

interface

uses
  IAlbumsRepositoryIntf,
  IAlbumsServiceIntf,
  IAlbumHelperServiceIntf,
  IPhotosRepositoryIntf,
  IPhotoDetailsServiceIntf,
  IPhotosServiceIntf,
  IRandomHandlerServiceIntf,
  IAlbumValidatorIntf;

type
  IAlbumsRepository = IAlbumsRepositoryIntf.IAlbumsRepository;
  IAlbumsService = IAlbumsServiceIntf.IAlbumsService;
  IAlbumHelperService = IAlbumHelperServiceIntf.IAlbumHelperService;
  IPhotosRepository = IPhotosRepositoryIntf.IPhotosRepository;
  IPhotoDetailsService = IPhotoDetailsServiceIntf.IPhotoDetailsService;
  IPhotosService = IPhotosServiceIntf.IPhotosService;
  IRandomHandlerService = IRandomHandlerServiceIntf.IRandomHandlerService;
  IAlbumValidator = IAlbumValidatorIntf.IAlbumValidator;

implementation

end.

