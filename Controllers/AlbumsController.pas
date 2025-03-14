unit AlbumsController;

interface

uses
  System.SysUtils, System.Classes, MVCFramework, ServerAPI.Interfaces, ServerAPI.ViewModels,
  System.Generics.Collections, System.Threading;

type
  [Route('/api/[controller]')]
  TAlbumsController = class(TMVCController)
  private
    FAlbumsService: IAlbumsService;
  public
    constructor Create(const AAlbumsService: IAlbumsService); reintroduce;

    [HttpGet]
    [Route('{id}')]
    [SwaggerOperation('Get album by ID', 'Get a specific album by its ID')]
    procedure GetAlbumById(const id: Integer);

    [HttpGet]
    [Route('')]
    [SwaggerOperation('Get all albums', 'Get all albums')]
    procedure Index;

    [HttpPost]
    [Route('add')]
    [Authorize]
    [SwaggerOperation('Add album', 'Add album')]
    procedure Add(const caption: string);

    [HttpPut]
    [Route('update/{id}')]
    [Authorize]
    [SwaggerOperation('Update album', 'Update album')]
    procedure Update(const id: Integer; const caption: string);

    [HttpDelete]
    [Route('delete/{id}')]
    [Authorize]
    [SwaggerOperation('Delete album', 'Delete album')]
    procedure Delete(const id: Integer);
  end;

implementation

{ TAlbumsController }

constructor TAlbumsController.Create(const AAlbumsService: IAlbumsService);
begin
  inherited Create;
  FAlbumsService := AAlbumsService;
end;

procedure TAlbumsController.GetAlbumById(const id: Integer);
var
  Albums: TList<TAlbumViewModel>;
  Album: TAlbumViewModel;
begin
  try
    // Correct usage of TTask.Future with the expected result type
    Albums := TTask.Future<TList<TAlbumViewModel>>(
      function: TList<TAlbumViewModel>
      begin
        Result := FAlbumsService.GetAlbumsWithPhotoCountAsync.Value;  // Return the result directly
      end).Value;  // Block and wait for the result

    // Find the album matching the ID
    Album := Albums.FirstOrDefault(
      function(const a: TAlbumViewModel): Boolean
      begin
        Result := a.AlbumID = id;
      end
    );

    if Assigned(Album) then
      Render(Album)
    else
      RaiseNotFound('Album with ID ' + id.ToString + ' not found');
  except
    on E: Exception do
    begin
      LogError(E, 'Error occurred while retrieving album with ID ' + id.ToString);
      Render(500, 'An error occurred while processing your request.');
    end;
  end;
end;

procedure TAlbumsController.Index;
var
  Albums: TList<TAlbumViewModel>;
begin
  try
    // Correct usage of TTask.Future to get the async result
    Albums := TTask.Future<TList<TAlbumViewModel>>(
      function: TList<TAlbumViewModel>
      begin
        Result := FAlbumsService.GetAlbumsWithPhotoCountAsync.Value;  // Call the async function directly
      end).Value;  // Block and wait for the result

    Render(Albums);
  except
    on E: Exception do
    begin
      LogError(E, 'Error occurred while retrieving albums');
      Render(500, 'An error occurred while processing your request.');
    end;
  end;
end;

procedure TAlbumsController.Add(const caption: string);
var
  Response: TAddAlbumResponse;
begin
  // Correct usage of TTask.Future to get the async result
  Response := TTask.Future<TAddAlbumResponse>(
    function: TAddAlbumResponse
    begin
      Result := FAlbumsService.AddAlbumAsync(caption).Value;  // Call the async function directly
    end).Value;

  if Response.IsValid then
    Render(Response.Album)
  else
    Render(400, '{"success": false, "message": "Failed to create album"}');
end;

procedure TAlbumsController.Update(const id: Integer; const caption: string);
var
  Response: TUpdateAlbumResponse;
begin
  // Correct usage of TTask.Future to get the async result
  Response := TTask.Future<TUpdateAlbumResponse>(
    function: TUpdateAlbumResponse
    begin
      Result := FAlbumsService.UpdateAlbumAsync(caption, id).Value;  // Call the async function directly
    end).Value;

  if Response.IsValid then
    Render(200, '{"success": true, "data": "' + caption + '"}')
  else
    Render(400, '{"success": false, "message": "Failed to update album"}');
end;

procedure TAlbumsController.Delete(const id: Integer);
var
  Response: Integer;
begin
  // Correct usage of TTask.Future to get the async result
  Response := TTask.Future<Integer>(
    function: Integer
    begin
      Result := FAlbumsService.DeleteAlbumAsync(id).Value;  // Call the async function directly
    end).Value;

  if Response > 0 then
    Render(200, '{"success": true, "message": "Album deleted successfully"}')
  else
    Render(404, '{"success": false, "message": "Album not found"}');
end;

end.

