unit IPhotosRepositoryIntf;

interface

uses
  ServerAPI.Models, System.Generics.Collections, System.Threading;

type
  IPhotosRepository = interface
    ['{8A2C2D60-6E12-4C6D-A2F2-7A6B51681B47}']

    function GetRandomPhotoIdAsync(AlbumId: Integer): IFuture<Integer>;
    function GetPhotoCountsPerAlbumAsync: IFuture<TDictionary<Integer, Integer>>;
    function GetPhotoByIdAsync(PhotoId: Integer): IFuture<TPhoto>;
    function GetPhotoSlimByIdAsync(PhotoId: Integer): IFuture<TPhotoSlim>;
    function GetPhotoSlimByAlbumIdAsync(AlbumId: Integer): IFuture<TEnumerable<TPhotoSlim>>;
    procedure AddPhotoAsync(Photo: TPhoto);
    procedure DeletePhoto(PhotoId: Integer);
    procedure UpdatePhoto(Caption: string; PhotoId: Integer);
    function SaveChangesAsync: IFuture<Integer>;

    // Transaction methods
    function BeginTransactionAsync: ITask;
    function CommitTransactionAsync: ITask;
    function RollbackTransactionAsync: ITask;
  end;

implementation

end.

