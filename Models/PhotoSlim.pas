unit PhotoSlim;

interface

type
  [Serializable]
  TPhotoSlim = class
  private
    FPhotoID: Integer;
    FAlbumID: Integer;
    FCaption: string;
  public
    constructor Create;
    property PhotoID: Integer read FPhotoID write FPhotoID;
    property AlbumID: Integer read FAlbumID write FAlbumID;
    property Caption: string read FCaption write FCaption;
  end;

implementation

constructor TPhotoSlim.Create;
begin
  FCaption := '';  // Initialize Caption to an empty string
end;

end.

