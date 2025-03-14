unit IAlbumHelperServiceIntf;

interface

uses
  System.Generics.Collections, // För generiska samlingar som List
  System.Threading,            // För Task och asynkron programmering
  ServerAPI.ViewModels;        // För att använda AlbumViewModel

type
  // Deklarera vårt interface
  IAlbumHelperService = interface
    ['{A0E63534-93F7-4D55-B96C-3709E9E00F11}']

    // Asynkron metod som returnerar en lista av AlbumViewModels
    function GetAlbumsWithPhotoCountAsync: IFuture<TList<TAlbumViewModel>>;
  end;

implementation

end.

