unit BaseRepository;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FireDAC.DApt;

type
  TBaseRepository = class
  private
    FConnection: TFDConnection;
  public
    constructor Create(AConnection: TFDConnection);
    function SaveChanges: Integer;
    procedure BeginTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
  end;

implementation

constructor TBaseRepository.Create(AConnection: TFDConnection);
begin
  FConnection := AConnection;
end;

function TBaseRepository.SaveChanges: Integer;
begin
  // In Delphi, FireDAC works with TFDQuery and the connection, so changes are automatically
  // committed or rolled back depending on the transaction scope.
  Result := FConnection.ExecSQL('COMMIT');  // Can be adjusted depending on your use case
end;

procedure TBaseRepository.BeginTransaction;
begin
  FConnection.StartTransaction;
end;

procedure TBaseRepository.CommitTransaction;
begin
  if FConnection.InTransaction then
    FConnection.Commit;
end;

procedure TBaseRepository.RollbackTransaction;
begin
  if FConnection.InTransaction then
    FConnection.Rollback;
end;

end.

