unit AlbumValidationResult;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, ServerAPI.ViewModels;

type
  TAlbumValidationResult = class
  private
    FIsValid: Boolean;
    FErrors: TList<string>;
    FAlbum: TAlbumViewModel;
  public
    constructor Create;
    destructor Destroy; override;

    property IsValid: Boolean read FIsValid write FIsValid;
    property Errors: TList<string> read FErrors;
    property Album: TAlbumViewModel read FAlbum write FAlbum;
  end;

implementation

constructor TAlbumValidationResult.Create;
begin
  inherited Create;
  FErrors := TList<string>.Create;
end;

destructor TAlbumValidationResult.Destroy;
begin
  FErrors.Free;
  FAlbum.Free;
  inherited Destroy;
end;

end.

