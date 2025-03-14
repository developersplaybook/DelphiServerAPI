unit Photo;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  [Serializable]
  TPhoto = class
  private
    FPhotoID: Integer;
    FAlbumID: Integer;
    FCaption: string;
    FBytesOriginal: TBytes;
    FBytesFull: TBytes;
    FBytesPoster: TBytes;
    FBytesThumb: TBytes;
  public
    constructor Create;
    property PhotoID: Integer read FPhotoID write FPhotoID;
    property AlbumID: Integer read FAlbumID write FAlbumID;
    property Caption: string read FCaption write FCaption;
    property BytesOriginal: TBytes read FBytesOriginal write FBytesOriginal;
    property BytesFull: TBytes read FBytesFull write FBytesFull;
    property BytesPoster: TBytes read FBytesPoster write FBytesPoster;
    property BytesThumb: TBytes read FBytesThumb write FBytesThumb;
  end;

implementation

constructor TPhoto.Create;
begin
  FCaption := '';  // Initialize Caption to an empty string
  FBytesOriginal := nil;
  FBytesFull := nil;
  FBytesPoster := nil;
  FBytesThumb := nil;
end;

end.

