unit AlbumsService;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Threading, ServerAPI.Interfaces,
  ServerAPI.Models, ServerAPI.ViewModels;

type
  TAlbumsService = class(TInterfacedObject, IAlbumsService)
  private
    FAlbumsRepository: IAlbumsRepository;
    FPhotosRepository: IPhotosRepository;
    FAlbumValidator: IAlbumValidator;
    FAlbumHelperService: IAlbumHelperService;
  public
    constructor Create(const AAlbumsRepository: IAlbumsRepository;
                       const APhotosRepository: IPhotosRepository;
                       const AAlbumValidator: IAlbumValidator;
                       const AAlbumHelperService: IAlbumHelperService);

    function DeleteAlbumAsync(AlbumId: Integer): ITask<Integer>;
    function AddAlbumAsync(const Caption: string): ITask<TAlbumValidationResult>;
    function UpdateAlbumAsync(const Caption: string; AlbumId: Integer): ITask<TAlbumValidationResult>;
    function GetAlbumsWithPhotoCountAsync: ITask<TList<TAlbumViewModel>>;
  end;

implementation

constructor TAlbumsService.Create(const AAlbumsRepository: IAlbumsRepository;
  const APhotosRepository: IPhotosRepository;
  const AAlbumValidator: IAlbumValidator;
  const AAlbumHelperService: IAlbumHelperService);
begin
  inherited Create;
  FAlbumsRepository := AAlbumsRepository;
  FPhotosRepository := APhotosRepository;
  FAlbumValidator := AAlbumValidator;
  FAlbumHelperService := AAlbumHelperService;
end;

function TAlbumsService.DeleteAlbumAsync(AlbumId: Integer): ITask<Integer>;
begin
  Result := TTask.Run<Integer>(
    procedure: Integer
    var
      Album: TAlbum;
    begin
      FAlbumsRepository.BeginTransactionAsync.Result;
      try
        Album := FAlbumsRepository.GetAlbumByIdAsync(AlbumId).Result;
        if not Assigned(Album) then
          raise Exception.Create('Album not found.');

        FAlbumsRepository.DeleteAlbum(Album);
        Result := FAlbumsRepository.SaveChangesAsync.Result;

        FAlbumsRepository.CommitTransactionAsync.Result;
      except
        FAlbumsRepository.RollbackTransactionAsync.Result;
        raise;
      end;
    end);
end;

function TAlbumsService.AddAlbumAsync(const Caption: string): ITask<TAlbumValidationResult>;
begin
  Result := TTask.Run<TAlbumValidationResult>(
    function: TAlbumValidationResult
    var
      Album: TAlbum;
      ValidationResult: TAlbumValidationResult;
    begin
      ValidationResult := FAlbumValidator.ValidateAlbumCaptionAsync(Caption).Result;
      if not ValidationResult.IsValid then
        Exit(ValidationResult);

      FAlbumsRepository.BeginTransactionAsync.Result;
      try
        Album := TAlbum.Create;
        try
          Album.Caption := Caption;
          Album.IsPublic := True;

          FAlbumsRepository.AddAlbumAsync(Album).Result;
          if FAlbumsRepository.SaveChangesAsync.Result <> 1 then
          begin
            ValidationResult.IsValid := False;
            ValidationResult.Errors.Add('Could not add album');
            FAlbumsRepository.RollbackTransactionAsync.Result;
            Exit(ValidationResult);
          end;

          FAlbumsRepository.CommitTransactionAsync.Result;

          ValidationResult.Album := TAlbumViewModel.Create;
          ValidationResult.Album.Caption := Album.Caption;
          ValidationResult.Album.IsPublic := Album.IsPublic;
          ValidationResult.Album.AlbumID := Album.AlbumID;
          ValidationResult.Album.PhotoCount := 0;

          Result := ValidationResult;
        finally
          Album.Free;
        end;
      except
        FAlbumsRepository.RollbackTransactionAsync.Result;
        raise;
      end;
    end);
end;

function TAlbumsService.UpdateAlbumAsync(const Caption: string; AlbumId: Integer): ITask<TAlbumValidationResult>;
begin
  Result := TTask.Run<TAlbumValidationResult>(
    function: TAlbumValidationResult
    var
      Album: TAlbum;
      ValidationResult: TAlbumValidationResult;
    begin
      ValidationResult := FAlbumValidator.ValidateAlbumCaptionAsync(Caption, AlbumId).Result;
      if not ValidationResult.IsValid then
        Exit(ValidationResult);

      FAlbumsRepository.BeginTransactionAsync.Result;
      try
        Album := FAlbumsRepository.GetAlbumByIdAsync(AlbumId).Result;
        if not Assigned(Album) then
          raise Exception.Create('Album not found.');

        Album.Caption := Caption;
        FAlbumsRepository.UpdateAlbum(Album);

        if FAlbumsRepository.SaveChangesAsync.Result <> 1 then
        begin
          ValidationResult.IsValid := False;
          ValidationResult.Errors.Add('Could not update album');
          FAlbumsRepository.RollbackTransactionAsync.Result;
          Exit(ValidationResult);
        end;

        FAlbumsRepository.CommitTransactionAsync.Result;
        Result := ValidationResult;
      except
        FAlbumsRepository.RollbackTransactionAsync.Result;
        raise;
      end;
    end);
end;

function TAlbumsService.GetAlbumsWithPhotoCountAsync: ITask<TList<TAlbumViewModel>>;
begin
  Result := FAlbumHelperService.GetAlbumsWithPhotoCountAsync;
end;

end.

