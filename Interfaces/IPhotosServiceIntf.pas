unit IPhotosServiceIntf;

interface

uses
  ServerAPI.Models, ServerAPI.ViewModels,
  System.Generics.Collections, System.Threading, System.SysUtils;

type
  IPhotosService = interface
    ['{F3D4A307-A51D-4C98-9A23-CCF41A9849C1}']

    function AddPhotoAsync(AlbumId: Integer; Caption: string; BytesOriginal: TBytes): IFuture<Boolean>;
    function DeletePhotoAsync(PhotoId: Integer): IFuture<Boolean>;
    function UpdatePhotoAsync(Caption: string; PhotoId: Integer): IFuture<Boolean>;
    function GetPhotosViewModelByAlbumIdAsync(AlbumId: Integer): IFuture<TList<TPhotoViewModel>>;
  end;

implementation

end.

