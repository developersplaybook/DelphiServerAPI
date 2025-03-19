  unit AlbumsRepository;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Threading,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.Param,
  ServerAPI.Models, ServerAPI.Interfaces;

type
  TAlbumsRepository = class(TInterfacedObject, IAlbumsRepository)
  private
    FContext: TFDConnection;  // Connection to the database
    FTransaction: TFDTransaction; // Holds the current transaction
    function GetRandomAlbumIdWithPhotos: Integer; // Helper function for async task
  public
    constructor Create(const AContext: TFDConnection);

    function GetRandomAlbumIdWithPhotosAsync: IFuture<Integer>;
    function GetAllAlbumsAsync: IFuture<TList<TAlbum>>;
    function GetAlbumByIdAsync(const id: Integer): IFuture<TAlbum>;
    procedure AddAlbumAsync(const Album: TAlbum);
    procedure UpdateAlbum(const Album: TAlbum);
    procedure DeleteAlbum(const Album: TAlbum);
    function SaveChangesAsync: IFuture<Integer>;

    // Transaction Management Methods
    procedure BeginTransactionAsync;
    procedure CommitTransactionAsync;
    procedure RollbackTransactionAsync;
  end;

implementation

uses
  System.Math; // For Random function

{ TAlbumsRepository }

constructor TAlbumsRepository.Create(const AContext: TFDConnection);
begin
  inherited Create;
  FContext := AContext;
  FTransaction := TFDTransaction.Create(nil);  // You may want to initialize the transaction object
  FTransaction.Connection := FContext;        // Associate the transaction with the context
end;

function TAlbumsRepository.GetRandomAlbumIdWithPhotos: Integer;
var
  AlbumIds: TList<Integer>;
  RandomIndex: Integer;
  Query: TFDQuery; // Declare a local query instance
begin
  AlbumIds := TList<Integer>.Create;
  Query := TFDQuery.Create(nil); // Create a FireDAC query object
  try
    Query.Connection := FContext; // Ensure query is connected to the database
    Query.SQL.Text := 'SELECT AlbumID FROM Albums WHERE EXISTS ' +
                      '(SELECT 1 FROM Photos WHERE Photos.AlbumID = Albums.AlbumID)';
    Query.Open;

    // Populate the AlbumIds list
    while not Query.Eof do
    begin
      AlbumIds.Add(Query.FieldByName('AlbumID').AsInteger);
      Query.Next;
    end;

    if AlbumIds.Count = 0 then
      Exit(0); // No albums found with photos

    // Pick a random album from the list
    Randomize; // Initialize random generator
    RandomIndex := Random(AlbumIds.Count);
    Result := AlbumIds[RandomIndex];
  finally
    Query.Free;     // Free the query object
    AlbumIds.Free;  // Free the list of album IDs
  end;
end;

function TAlbumsRepository.GetRandomAlbumIdWithPhotosAsync: IFuture<Integer>;
begin
  // Pass the explicit function reference to TTask.Future
  Result := TTask.Future<Integer>(GetRandomAlbumIdWithPhotos);
end;

function TAlbumsRepository.GetAllAlbumsAsync: IFuture<TList<TAlbum>>;
begin
  Result := TTask.Future<TList<TAlbum>>(
  TFunc<TList<TAlbum>>(
    function: TList<TAlbum>
    var
      Albums: TList<TAlbum>;
      Query: TFDQuery;
    begin
      Albums := TList<TAlbum>.Create;
      Query := TFDQuery.Create(nil);
      try
        try
          Query.Connection := FContext;  // Ensure FContext is assigned properly
          Query.SQL.Text := 'SELECT AlbumID, Caption FROM Albums';
          Query.Open;

          while not Query.Eof do
          begin
            Albums.Add(TAlbum.Create(Query.FieldByName('AlbumID').AsInteger,
                                     Query.FieldByName('Caption').AsString));
            Query.Next;
          end;

          // Return the populated list of albums
          Result := Albums;
        except
          FreeAndNil(Albums); // Ensure albums list is freed on error
          raise;
        end;
      finally
        Query.Free; // Free the query object
      end;
    end
    )
  );
end;


function TAlbumsRepository.GetAlbumByIdAsync(const id: Integer): IFuture<TAlbum>;
begin
  Result := TTask.Future<TAlbum>(
    TFunc<TAlbum>(
    function: TAlbum
    var
      Album: TAlbum;
      Query: TFDQuery;
    begin
      Album := nil;
      Query := TFDQuery.Create(nil);
      try
        Query.Connection := FContext; // Ensure FContext is properly assigned
        Query.SQL.Text := 'SELECT AlbumID, AlbumName FROM Albums WHERE AlbumID = :AlbumID';
        Query.ParamByName('AlbumID').AsInteger := id;
        Query.Open;

        if not Query.Eof then
          Album := TAlbum.Create(Query.FieldByName('AlbumID').AsInteger, Query.FieldByName('AlbumName').AsString);

        Result := Album; // Return the album or nil if not found
      finally
        Query.Free; // Ensure query is freed
      end;
    end
    )
  );
end;


procedure TAlbumsRepository.AddAlbumAsync(const Album: TAlbum);
begin
  TTask.Run(TProc(
   procedure
    var
      Query: TFDQuery;  // Declare the Query object inside the anonymous method
    begin
      Query := TFDQuery.Create(nil);  // Initialize the query object
      try
        Query.Connection := FContext;  // Ensure the query uses the correct connection
        Query.SQL.Text := 'INSERT INTO Albums (AlbumID, Caption) VALUES (:AlbumID, :Caption)';
        Query.ParamByName('AlbumID').AsInteger := Album.AlbumID;
        Query.ParamByName('Caption').AsString := Album.Caption;
        Query.ExecSQL;  // Execute the SQL to insert the album
      finally
        Query.Free;  // Ensure the query is freed after use
      end;
    end
  ));
end;



procedure TAlbumsRepository.UpdateAlbum(const Album: TAlbum);
begin
    var
      LQuery: TFDQuery; // Assuming FireDAC is used
      try
        LQuery.SQL.Text := 'UPDATE Albums SET Caption = :Caption WHERE AlbumID = :AlbumID';
        LQuery.ParamByName('AlbumID').AsInteger := Album.AlbumID;
        LQuery.ParamByName('Caption').AsString := Album.Caption;
        LQuery.ExecSQL;
      finally
        LQuery.Free; // Clean up the query object
      end;
end;


procedure TAlbumsRepository.DeleteAlbum(const Album: TAlbum);
begin
    var
      LQuery: TFDQuery; // Assuming FireDAC is used
      try
        LQuery.SQL.Text := 'DELETE FROM Albums WHERE AlbumID = :AlbumID';
        LQuery.ParamByName('AlbumID').AsInteger := Album.AlbumID;
        LQuery.ExecSQL;
      finally
        LQuery.Free; // Clean up the query object
      end;
end;


procedure TAlbumsRepository.BeginTransactionAsync;
begin
  FTransaction.StartTransaction;
end;

procedure TAlbumsRepository.CommitTransactionAsync;
begin
  if FTransaction.InTransaction then
    FTransaction.Commit;
end;

procedure TAlbumsRepository.RollbackTransactionAsync;
begin
  if FTransaction.InTransaction then
    FTransaction.Rollback;
end;

end.

