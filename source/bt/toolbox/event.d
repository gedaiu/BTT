module bt.toolbox.event;

public import bt.toolbox.rule;
public import bt.toolbox.timeinterval;
public import vibe.data.json;
public import std.datetime;

enum EventType {
  Undefined = "Undefined",
  Standard = "Standard",
  FixedStandard = "FixedStandard",
  UnknownEnd = "UnknownEnd",
  AutoPostpone = "AutoPostpone",
  Repetable = "Repetable"
}

TimeInterval interval(const CalendarEvent event) {
  return TimeInterval(event.begin, event.end);
}

abstract class CalendarEvent {

	@property {
		const(EventType) itemType() const;

		void begin(const long begin);
		long begin() const;

		void end(const long end);
		long end() const;

		long endLimit() const;

		long duration() const;
		void duration(long duration);

		void boundary(const long customBoundary);
		long boundary() const;

		void postpone(const long customBoundary);
		long postpone() const;

		Rule[] rules() const;
		void rules(Rule[] someRules);
	}

	Json toJson() const;
	string toICS() const {
		return "";
	}

	void set(long time1, long time2);
}

long ldur(string units, T)(T count) {
  static if(units == "weeks") {
    return count * 7 /*days*/ * 24 /*hours*/ * 3600;
  } else static if(units == "days") {
    return count * 24 /*hours*/ * 3600;
  } else static if(units == "hours") {
    return count * 3600;
  } else static if(units == "minutes") {
    return count * 60;
  } else {
    static assert(units ~ "not supported");
  }
}

string toISOExtString(long date) {
  return  std.datetime.SysTime.fromUnixTime(date).toUTC.toISOExtString;
}

long toTimeStamp(string date) {
  return std.datetime.SysTime.fromISOExtString(date).toUnixTime;
}