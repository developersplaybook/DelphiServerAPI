unit IPhotoDetailsServiceIntf;

interface

uses
  ServerAPI.Models, ServerAPI.ViewModels, System.Threading;

type
  IPhotoDetailsService = interface
    ['{B6715E6B-2AB4-4C9B-9A88-38B59C34750D}']

    function GetPhotoViewModelByIdAsync(PhotoId: Integer): IFuture<TPhotoViewModel>;
  end;

implementation

end.

