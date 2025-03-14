unit DateTimeUtil;

interface

uses
  System.SysUtils, System.DateUtils, System.Math;

type
  TDateTimeUtil = class
  public
    type
      TDateInterval = (Year, Month, Weekday, Day, Hour, Minute, Second);

    class function DateDiff(Interval: TDateInterval; Date1, Date2: TDateTime): Int64; static;
    class function IsLeapYear(Year: Int64): Boolean; static;
  private
    class function Fix(Number: Double): Int64; static;
  end;

implementation

class function TDateTimeUtil.DateDiff(Interval: TDateInterval; Date1, Date2: TDateTime): Int64;
begin
  case Interval of
    Year:
      Result := YearOf(Date2) - YearOf(Date1);
    Month:
      Result := (YearOf(Date2) - YearOf(Date1)) * 12 + (MonthOf(Date2) - MonthOf(Date1));
    Weekday:
      Result := DaysBetween(Date1, Date2) div 7;
    Day:
      Result := DaysBetween(Date1, Date2);
    Hour:
      Result := HoursBetween(Date1, Date2);
    Minute:
      Result := MinutesBetween(Date1, Date2);
  else
    Result := SecondsBetween(Date1, Date2);
  end;
end;


class function TDateTimeUtil.IsLeapYear(Year: Int64): Boolean;
begin
  Result := (Year > 0) and (Year mod 4 = 0) and not ((Year mod 100 = 0) and (Year mod 400 <> 0));
end;

class function TDateTimeUtil.Fix(Number: Double): Int64;
begin
  if Number >= 0 then
    Result := Floor(Number)
  else
    Result := Ceil(Number);
end;

end.

