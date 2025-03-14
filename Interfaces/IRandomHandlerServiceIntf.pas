unit IRandomHandlerServiceIntf;

interface

uses
  ServerAPI.Models, System.IOUtils, System.Threading, System.Classes;

type
  IRandomHandlerService = interface
    ['{EEC5E100-9F02-4D5A-BF8C-9707C22DA09F}']

    function GetRandomAlbumIdAsync: IFuture<Integer>;
    function GetRandomPhotoIdAsync(AlbumId: Integer): IFuture<Integer>;
    function GetFirstPhotoAsync(AlbumId: Integer; Size: TPhotoSize): IFuture<TStream>;
    function GetPhotoAsync(PhotoId: Integer; Size: TPhotoSize): IFuture<TStream>;
  end;

implementation

end.

