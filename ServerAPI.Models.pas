unit ServerAPI.Models;

interface

uses
  Album,
  AlbumValidationResult,
  DateTimeUtil,
  Photo,
  PhotoSize,
  PhotoSlim,
  SessionExtensions;

type
  TAlbum = Album.TAlbum;
  TAlbumValidationResult = AlbumValidationResult.TAlbumValidationResult;
  TDateTimeUtil = DateTimeUtil.TDateTimeUtil;
  TPhoto = Photo.TPhoto;
  TPhotoSize = PhotoSize.TPhotoSize;
  TPhotoSlim = PhotoSlim.TPhotoSlim;
  TSessionExtensions = SessionExtensions.TSessionExtensions;

implementation

end.
