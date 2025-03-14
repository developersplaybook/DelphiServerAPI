unit IAlbumValidatorIntf;

interface

uses
  ServerAPI.Models, System.Threading;

type
  IAlbumValidator = interface
    ['{F9D09E3C-11F0-45A3-A18F-89C6D5B3B5F7}']

    function ValidateAlbumCaptionAsync(const Caption: string; AlbumId: Integer = 0): IFuture<TAlbumValidationResult>;
  end;

implementation

end.

