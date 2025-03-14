unit IAlbumsServiceIntf;

interface

uses
  System.Generics.Collections, ServerAPI.Models, ServerAPI.ViewModels, System.Threading;

type
  IAlbumsService = interface
    ['{FA80B6A3-F0AC-4B87-B6C1-1A1A150C1B1B}']

    function AddAlbumAsync(const Caption: string): IFuture<TAlbumValidationResult>;
    function DeleteAlbumAsync(AlbumId: Integer): IFuture<Integer>;
    function UpdateAlbumAsync(const Caption: string; AlbumId: Integer): IFuture<TAlbumValidationResult>;
    function GetAlbumsWithPhotoCountAsync: IFuture<TList<TAlbumViewModel>>;
  end;

implementation

end.

