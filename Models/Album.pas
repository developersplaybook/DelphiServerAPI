unit Album;

interface

uses
  System.SysUtils, System.Classes;

type
  // Klassdefiniering för Album
  TAlbum = class
  private
    FAlbumID: Integer;
    FCaption: string;
    FIsPublic: Boolean;
  public
    constructor Create; // Konstruktor för att skapa ett nytt objekt
    destructor Destroy; override; // För att frigöra resurser vid rensning

    property AlbumID: Integer read FAlbumID write FAlbumID;
    property Caption: string read FCaption write FCaption;
    property IsPublic: Boolean read FIsPublic write FIsPublic;
  end;

implementation

{ TAlbum }

constructor TAlbum.Create;
begin
  inherited Create;
  // Initiera standardvärden om det behövs
end;

destructor TAlbum.Destroy;
begin
  // Rensa eventuella resurser om det behövs
  inherited;
end;

end.

