unit LinqHelper;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults;

type
  TLinqHelper = class
  public
    class function FirstOrDefault<T>(const Source: TEnumerable<T>; const Predicate: TFunc<T, Boolean>): T; static;
  end;

implementation

class function TLinqHelper.FirstOrDefault<T>(const Source: TEnumerable<T>; const Predicate: TFunc<T, Boolean>): T;
var
  Item: T;
begin
  for Item in Source do
    if Predicate(Item) then
      Exit(Item);
  Result := Default(T); // Return default value for type
end;

end.

