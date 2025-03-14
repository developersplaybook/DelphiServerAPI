unit AlbumValidator;

interface

uses
  System.SysUtils, System.Classes, System.Threading, System.Generics.Collections,
  ServerAPI.Interfaces, ServerAPI.Models, PersonalContextUnit;

type
  TAlbumValidator = class(TInterfacedObject, IAlbumValidator)
  private
    FContext: TPersonalContext;
  public
    constructor Create(const AContext: TPersonalContext);

    function ValidateAlbumCaptionAsync(const Caption: string; AlbumId: Integer = 0): ITask<TAlbumValidationResult>;
  end;

implementation

{ TAlbumValidator }

constructor TAlbumValidator.Create(const AContext: TPersonalContext);
begin
  inherited Create;
  FContext := AContext;
end;

function TAlbumValidator.ValidateAlbumCaptionAsync(const Caption: string; AlbumId: Integer = 0): ITask<TAlbumValidationResult>;
begin
  Result := TTask.Run<TAlbumValidationResult>(
    function: TAlbumValidationResult
    var
      ExistingAlbum: TAlbum;
      ValidationResult: TAlbumValidationResult;
    begin
      ValidationResult := TAlbumValidationResult.Create;
      ValidationResult.IsValid := True;

      // Check for existing album with the same caption (excluding the current one)
      ExistingAlbum := FContext.Albums.FirstOrDefault(
        function(const A: TAlbum): Boolean
        begin
          Result := (A.Caption = Caption) and (A.AlbumID <> AlbumId);
        end
      );

      if Assigned(ExistingAlbum) then
      begin
        ValidationResult.IsValid := False;
        ValidationResult.Errors.Add('Caption must be unique');
      end;

      Result := ValidationResult;
    end
  );
end;

end.

