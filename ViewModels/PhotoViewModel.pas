unit PhotoViewModel;

interface

type
  [Serializable]
  TPhotoViewModel = class
  private
    FPhotoID: Integer;
    FAlbumID: Integer;
    FCaption: string;
    FAlbumCaption: string;
  public
    constructor Create;

    property PhotoID: Integer read FPhotoID write FPhotoID;
    property AlbumID: Integer read FAlbumID write FAlbumID;
    property Caption: string read FCaption write FCaption;
    property AlbumCaption: string read FAlbumCaption write FAlbumCaption;
  end;

implementation

{ TPhotoViewModel }

constructor TPhotoViewModel.Create;
begin
  FCaption := '';       // Default value for Caption
  FAlbumCaption := '';  // Default value for AlbumCaption
end;

end.

