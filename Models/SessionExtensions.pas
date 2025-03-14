unit SessionExtensions;

interface

uses
  System.SysUtils, System.Generics.Collections, System.JSON, Web.HTTPApp, System.Classes;

type
  TSessionExtensions = class
  private
    // Static session store
    class var FSessionStore: TDictionary<string, TDictionary<string, string>>;
    class procedure InitializeSessionStore; static;
    class procedure FinalizeSessionStore; static;
  public
    // Create or retrieve the sessionId from cookies
    class function GetOrCreateSessionId(Request: TWebRequest; Response: TWebResponse): string;

    // Set a value in the session (thread-safe)
    class procedure SetValue(Request: TWebRequest; Response: TWebResponse; const Key, Value: string);

    // Get a value from the session (thread-safe)
    class function GetValue(Request: TWebRequest; Response: TWebResponse; const Key: string): string;

    // Destructor to free resources
    class destructor Destroy;
  end;

implementation

{ TSessionExtensions }

class procedure TSessionExtensions.InitializeSessionStore;
begin
  if not Assigned(FSessionStore) then
    FSessionStore := TDictionary<string, TDictionary<string, string>>.Create;
end;

class procedure TSessionExtensions.FinalizeSessionStore;
begin
  if Assigned(FSessionStore) then
  begin
    FSessionStore.Free;
    FSessionStore := nil;
  end;
end;

class function TSessionExtensions.GetOrCreateSessionId(Request: TWebRequest; Response: TWebResponse): string;
var
  SessionId: string;
  MyCookies: TStringList;
begin
  // Try to retrieve the sessionId from cookies
  SessionId := Request.CookieFields.Values['sessionId'];

  if SessionId.IsEmpty then
  begin
    // If no sessionId exists, create a new one (using a GUID)
    SessionId := TGuid.NewGuid.ToString;

    // Create the cookie list as a TStrings object
    MyCookies := TStringList.Create;
    try
      MyCookies.Add('sessionId=' + SessionId); // Set sessionId as the cookie name and value

      // Set the sessionId cookie with the appropriate parameters using SetCookieField
      Response.SetCookieField(MyCookies, 'localhost', '/', (Now + 1), False); // Adjust domain, path, etc.
    finally
      MyCookies.Free;
    end;
  end;

  // Ensure that the sessionId exists in the session store
  InitializeSessionStore;

  if not FSessionStore.ContainsKey(SessionId) then
    FSessionStore.Add(SessionId, TDictionary<string, string>.Create);

  Result := SessionId;
end;

class procedure TSessionExtensions.SetValue(Request: TWebRequest; Response: TWebResponse; const Key, Value: string);
var
  SessionId: string;
  SessionData: TDictionary<string, string>;
  JsonValue: string;
begin
  SessionId := GetOrCreateSessionId(Request, Response);

  // Retrieve or create a new session for this sessionId
  if not FSessionStore.ContainsKey(SessionId) then
    FSessionStore.Add(SessionId, TDictionary<string, string>.Create);

  // Serialize the value to JSON (as string) and store it in session data
  JsonValue := TJSONObject.Create.AddPair('value', Value).ToString;

  // Store the serialized value in session data
  SessionData := FSessionStore.Items[SessionId];
  SessionData.AddOrSetValue(Key, JsonValue);
end;

class function TSessionExtensions.GetValue(Request: TWebRequest; Response: TWebResponse; const Key: string): string;
var
  SessionId: string;
  SessionData: TDictionary<string, string>;
  JsonValue: string;
  JsonObject: TJSONObject;
begin
  SessionId := GetOrCreateSessionId(Request, Response);

  // Retrieve the value from the session if it exists
  if FSessionStore.TryGetValue(SessionId, SessionData) then
  begin
    if SessionData.TryGetValue(Key, JsonValue) then
    begin
      // Deserialize the JSON value into the string
      JsonObject := TJSONObject.ParseJSONValue(JsonValue) as TJSONObject;
      try
        // Return the value stored in the JSON object
        Result := JsonObject.GetValue('value').Value;
      finally
        JsonObject.Free;
      end;
    end
    else
      Result := ''; // Return empty string if the key is not found
  end
  else
    Result := ''; // Return empty string if the session does not exist
end;

class destructor TSessionExtensions.Destroy;
begin
  FinalizeSessionStore;
end;

initialization
  // Initialize the session store when the application starts
  TSessionExtensions.InitializeSessionStore;

finalization
  // Ensure the session store is finalized when the application ends
  TSessionExtensions.FinalizeSessionStore;

end.

