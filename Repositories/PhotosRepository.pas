unit PhotosRepository;

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet, FireDAC.DApt, ServerAPI.Models, ServerAPI.Interfaces;

type
  TPhotosRepository = class(TInterfacedObject, IPhotosRepository)
  private
    FConnection: TFDConnection;
    FTransaction: TFDTransaction;
  public
    constructor Create(AConnection: TFDConnection);
    function GetRandomPhotoIdAsync(AlbumID: Integer): Integer;
    function GetPhotoCountsPerAlbumAsync: TDictionary<Integer, Integer>;
    function GetPhotoByIdAsync(PhotoID: Integer): TPhoto;
    function GetPhotoSlimByIdAsync(PhotoID: Integer): TPhotoSlim;
    function GetPhotoSlimByAlbumIdAsync(AlbumID: Integer): TList<TPhotoSlim>;
    procedure AddPhotoAsync(Photo: TPhoto);
    procedure DeletePhoto(PhotoID: Integer);
    procedure UpdatePhoto(Caption: string; PhotoID: Integer);
    function SaveChangesAsync: Integer;

    // Transaction Management Methods
    procedure BeginTransactionAsync;
    procedure CommitTransactionAsync;
    procedure RollbackTransactionAsync;
  private
    function GetPhotoIdsByAlbumIdAsync(AlbumID: Integer): TList<Integer>;
    procedure DisposeTransactionAsync;
  end;

implementation

constructor TPhotosRepository.Create(AConnection: TFDConnection);
begin
  FConnection := AConnection;
  FTransaction := TFDTransaction.Create(nil);
  FTransaction.Connection := FConnection;
end;

function TPhotosRepository.GetRandomPhotoIdAsync(AlbumID: Integer): Integer;
var
  PhotoIds: TList<Integer>;
  Random: Integer;
begin
  PhotoIds := GetPhotoIdsByAlbumIdAsync(AlbumID);
  try
    if PhotoIds.Count = 0 then
      Exit(0); // Return 0 if no photos exist

    Random := System.Random(PhotoIds.Count); // Randomly pick a photo ID
    Result := PhotoIds[Random];
  finally
    PhotoIds.Free;
  end;
end;

function TPhotosRepository.GetPhotoCountsPerAlbumAsync: TDictionary<Integer, Integer>;
var
  Query: TFDQuery;
  AlbumID, Count: Integer;
begin
  Result := TDictionary<Integer, Integer>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT AlbumID, COUNT(*) AS Count FROM Photos GROUP BY AlbumID';
    Query.Open;

    while not Query.Eof do
    begin
      AlbumID := Query.FieldByName('AlbumID').AsInteger;
      Count := Query.FieldByName('Count').AsInteger;
      Result.Add(AlbumID, Count);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TPhotosRepository.GetPhotoByIdAsync(PhotoID: Integer): TPhoto;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM Photos WHERE PhotoID = :PhotoID';
    Query.ParamByName('PhotoID').AsInteger := PhotoID;
    Query.Open;

    if Query.IsEmpty then
      Exit(nil);

    // Assuming TPhoto has properties corresponding to the table
    Result := TPhoto.Create;
    Result.PhotoID := Query.FieldByName('PhotoID').AsInteger;
    Result.AlbumID := Query.FieldByName('AlbumID').AsInteger;
    Result.Caption := Query.FieldByName('Caption').AsString;
  finally
    Query.Free;
  end;
end;

function TPhotosRepository.GetPhotoSlimByIdAsync(PhotoID: Integer): TPhotoSlim;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT PhotoID, AlbumID, Caption FROM Photos WHERE PhotoID = :PhotoID';
    Query.ParamByName('PhotoID').AsInteger := PhotoID;
    Query.Open;

    if Query.IsEmpty then
      Exit(nil);

    Result := TPhotoSlim.Create;
    Result.PhotoID := Query.FieldByName('PhotoID').AsInteger;
    Result.AlbumID := Query.FieldByName('AlbumID').AsInteger;
    Result.Caption := Query.FieldByName('Caption').AsString;
  finally
    Query.Free;
  end;
end;

function TPhotosRepository.GetPhotoSlimByAlbumIdAsync(AlbumID: Integer): TList<TPhotoSlim>;
var
  Query: TFDQuery;
  PhotoSlim: TPhotoSlim;
begin
  Result := TList<TPhotoSlim>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT PhotoID, AlbumID, Caption FROM Photos WHERE AlbumID = :AlbumID';
    Query.ParamByName('AlbumID').AsInteger := AlbumID;
    Query.Open;

    while not Query.Eof do
    begin
      PhotoSlim := TPhotoSlim.Create;
      PhotoSlim.PhotoID := Query.FieldByName('PhotoID').AsInteger;
      PhotoSlim.AlbumID := Query.FieldByName('AlbumID').AsInteger;
      PhotoSlim.Caption := Query.FieldByName('Caption').AsString;
      Result.Add(PhotoSlim);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TPhotosRepository.AddPhotoAsync(Photo: TPhoto);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'INSERT INTO Photos (AlbumID, Caption) VALUES (:AlbumID, :Caption)';
    Query.ParamByName('AlbumID').AsInteger := Photo.AlbumID;
    Query.ParamByName('Caption').AsString := Photo.Caption;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TPhotosRepository.DeletePhoto(PhotoID: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'DELETE FROM Photos WHERE PhotoID = :PhotoID';
    Query.ParamByName('PhotoID').AsInteger := PhotoID;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TPhotosRepository.UpdatePhoto(Caption: string; PhotoID: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'UPDATE Photos SET Caption = :Caption WHERE PhotoID = :PhotoID';
    Query.ParamByName('Caption').AsString := Caption;
    Query.ParamByName('PhotoID').AsInteger := PhotoID;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TPhotosRepository.GetPhotoIdsByAlbumIdAsync(AlbumID: Integer): TList<Integer>;
var
  Query: TFDQuery;
  PhotoID: Integer;
begin
  Result := TList<Integer>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT PhotoID FROM Photos WHERE AlbumID = :AlbumID';
    Query.ParamByName('AlbumID').AsInteger := AlbumID;
    Query.Open;

    while not Query.Eof do
    begin
      PhotoID := Query.FieldByName('PhotoID').AsInteger;
      Result.Add(PhotoID);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TPhotosRepository.SaveChangesAsync: Integer;
begin
  FConnection.Commit; // Commit any changes if necessary, though FireDAC handles auto-commit for each query
  Result := 1; // Return 1 to simulate success (could be adjusted depending on your needs)
end;

procedure TPhotosRepository.BeginTransactionAsync;
begin
  FTransaction.StartTransaction;
end;

procedure TPhotosRepository.CommitTransactionAsync;
begin
  FTransaction.Commit;
end;

procedure TPhotosRepository.RollbackTransactionAsync;
begin
  FTransaction.Rollback;
end;

procedure TPhotosRepository.DisposeTransactionAsync;
begin
  FTransaction.Free;
end;

end.

