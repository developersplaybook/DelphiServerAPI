unit AlbumViewModel;

interface

type
  [Serializable]
  TAlbumViewModel = class
  private
    FAlbumID: Integer;
    FCaption: string;
    FIsPublic: Boolean;
    FPhotoCount: Integer;
  public
    constructor Create;

    property AlbumID: Integer read FAlbumID write FAlbumID;
    property Caption: string read FCaption write FCaption;
    property IsPublic: Boolean read FIsPublic write FIsPublic;
    property PhotoCount: Integer read FPhotoCount write FPhotoCount;
  end;

implementation

{ TAlbumViewModel }

constructor TAlbumViewModel.Create;
begin
  FCaption := '';   // Default value for Caption (empty string)
  FIsPublic := False;  // Default value for IsPublic
  FPhotoCount := 0;    // Default value for PhotoCount
end;

end.

