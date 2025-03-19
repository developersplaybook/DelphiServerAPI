unit IAlbumsRepositoryIntf;

interface

uses
  System.Generics.Collections, ServerAPI.Models, System.SysUtils, System.Threading;

type
  IAlbumsRepository = interface
    ['{D1B9B32F-A28B-48F2-8C85-D2A899A2D6A9}']

    // Updated methods to use IFuture<T> for asynchronous operations
    function GetRandomAlbumIdWithPhotosAsync: IFuture<Integer>;
    function GetAllAlbumsAsync: IFuture<TList<TAlbum>>;
    function GetAlbumByIdAsync(AlbumId: Integer): IFuture<TAlbum>;

    procedure AddAlbumAsync(Album: TAlbum);
    procedure UpdateAlbum(Album: TAlbum);
    procedure DeleteAlbum(Album: TAlbum);

    // Transaction methods
    function BeginTransactionAsync: IFuture<Boolean>;
    function CommitTransactionAsync: IFuture<Boolean>;
    function RollbackTransactionAsync: IFuture<Boolean>;
  end;

implementation

end.

