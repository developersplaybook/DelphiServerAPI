unit ServerAPI.Controllers;

interface

uses
  AlbumsController,
  AuthorizationController,
  PhotoDetailsController,
  PhotosController,
  RandomHandlerController;

type
  TAlbumsController = AlbumsController.TAlbumsController;
  TAuthorizationController = AuthorizationController.TAuthorizationController;
  TPhotoDetailsController = PhotoDetailsController.TPhotoDetailsController;
  TPhotosController = PhotosController.TPhotosController;
  TRandomHandlerController = RandomHandlerController.TRandomHandlerController;

implementation

end.
