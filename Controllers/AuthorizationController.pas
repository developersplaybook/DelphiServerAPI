unit AuthorizationController;

interface

uses
  System.SysUtils, System.Classes, MVCFramework, ServerAPI.Services, ServerAPI.Models,
  System.IdentityModel.Tokens.Jwt, Microsoft.IdentityModel.Tokens, System.Security.Claims,
  System.Generics.Collections;

type
  TAuthorizationController = class(TMVCController)
  private
    FKeyService: IKeyService;
  public
    constructor Create(const AKeyService: IKeyService); reintroduce;

    [HttpPost]
    [Route('login')]
    procedure Login(const Model: TLoginModel);

    [HttpPost]
    [Route('logout')]
    procedure Logout;
  end;

  TLoginModel = class
  public
    Password: string;
  end;

implementation

uses
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

const
  SessionUserLoggedIn = 'UserLoggedIn';

{ TAuthorizationController }

constructor TAuthorizationController.Create(const AKeyService: IKeyService);
begin
  inherited Create;
  FKeyService := AKeyService;
end;

procedure TAuthorizationController.Login(const Model: TLoginModel);
var
  StoredPassword: string;
  Key: string;
  KeyBytes: TBytes;
  SymmetricKey: TSymmetricSecurityKey;
  SigningCredentials: TSigningCredentials;
  Claims: TArray<TClaim>;
  JwtToken: TJwtSecurityToken;
  Handler: TJwtSecurityTokenHandler;
begin
  // Validation
  StoredPassword := 'your_stored_password'; // Store this securely or load from config

  if Model.Password = StoredPassword then
  begin
    Key := FKeyService.GetKey;
    KeyBytes := TNetEncoding.Base64.DecodeStringToBytes(Key);
    SymmetricKey := TSymmetricSecurityKey.Create(KeyBytes);
    SigningCredentials := TSigningCredentials.Create(SymmetricKey, SecurityAlgorithms.HmacSha256);

    Claims := [TClaim.Create(JwtRegisteredClaimNames.Jti, TGuid.NewGuid.ToString)];

    JwtToken := TJwtSecurityToken.Create(
      'issuer', // JwtIssuer from config
      'audience', // JwtAudience from config
      Claims,
      TDateTime.UtcNow.AddMinutes(30),
      SigningCredentials);

    // Set session to logged in
    Session[SessionUserLoggedIn] := True;

    // Write the token to response
    Handler := TJwtSecurityTokenHandler.Create;
    Render(200, '{"token": "' + Handler.WriteToken(JwtToken) + '"}');
  end
  else
  begin
    Render(401, '{"message": "Invalid credentials"}');
  end;
end;

procedure TAuthorizationController.Logout;
var
  IsLoggedIn: Boolean;
begin
  IsLoggedIn := Session[SessionUserLoggedIn];

  if IsLoggedIn then
  begin
    Session[SessionUserLoggedIn] := False;
    Render(200, '{"success": true, "text": "userLoggedOut"}');
  end
  else
  begin
    Render(200, '{"success": true, "text": "userAlreadyLoggedOut"}');
  end;
end;

end.

