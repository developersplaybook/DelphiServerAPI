unit AlbumHelperService;

interface

uses
  System.Generics.Collections, System.SysUtils, System.Threading, ServerAPI.Interfaces,
  ServerAPI.ViewModels, IAlbumsRepositoryIntf, IPhotosRepositoryIntf;

type
  TAlbumHelperService = class(TInterfacedObject, IAlbumHelperService)
  private
    FAlbumsRepository: IAlbumsRepository;
    FPhotosRepository: IPhotosRepository;
  public
    constructor Create(const AAlbumsRepository: IAlbumsRepository; const APhotosRepository: IPhotosRepository);

    function GetAlbumsWithPhotoCountAsync: ITask<TList<TAlbumViewModel>>;
  end;

implementation

{ TAlbumHelperService }

constructor TAlbumHelperService.Create(const AAlbumsRepository: IAlbumsRepository;
  const APhotosRepository: IPhotosRepository);
begin
  inherited Create;
  FAlbumsRepository := AAlbumsRepository;
  FPhotosRepository := APhotosRepository;
end;

function TAlbumHelperService.GetAlbumsWithPhotoCountAsync: ITask<TList<TAlbumViewModel>>;
begin
  Result := TTask.Run<TList<TAlbumViewModel>>(function: TList<TAlbumViewModel>
    var
      Albums: TList<TAlbum>;
      PhotoCounts: TDictionary<Integer, Integer>;
      Album: TAlbum;
      ViewModel: TAlbumViewModel;
    begin
      Result := TList<TAlbumViewModel>.Create;
      try
        // Fetch albums and photo counts
        Albums := FAlbumsRepository.GetAllAlbumsAsync.Result;
        PhotoCounts := FPhotosRepository.GetPhotoCountsPerAlbumAsync.Result;

        // Populate ViewModel list
        for Album in Albums do
        begin
          ViewModel := TAlbumViewModel.Create;
          ViewModel.AlbumID := Album.AlbumID;
          ViewModel.Caption := Album.Caption;
          ViewModel.IsPublic := Album.IsPublic;
          if PhotoCounts.ContainsKey(Album.AlbumID) then
            ViewModel.PhotoCount := PhotoCounts[Album.AlbumID]
          else
            ViewModel.PhotoCount := 0;

          Result.Add(ViewModel);
        end;
      finally
        Albums.Free;
        PhotoCounts.Free;
      end;
    end);
end;

end.
