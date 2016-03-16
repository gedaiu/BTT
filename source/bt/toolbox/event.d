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

TimeInterval interval(const Event event) {
  return TimeInterval(event.begin, event.end);
}

struct Event {
	EventType itemType;

	long expectedBegin;
	long expectedDuration;

	long boundary;
	long postpone;

	Rule[] rules;
}

long begin(inout Event event) {
  if(event.itemType == EventType.AutoPostpone) {
    auto now = Clock.currTime.toUnixTime;

    if(now + event.boundary >= event.expectedBegin) {
      return now + event.postpone;
    }
  }

	return event.expectedBegin;
}

void begin(ref Event event, long value) {
  event.expectedBegin = value;
}

long end(inout Event event) {
  if(event.itemType == EventType.UnknownEnd) {
    auto now = Clock.currTime.toUnixTime;

    if(now + event.boundary >= event.expectedBegin + event.expectedDuration) {
      return now;
    }
  }

	return event.begin + event.expectedDuration;
}

void end(ref Event event, long value) {
  auto const duration = value - event.begin;
	event.expectedDuration = duration > 0 ? duration : 0;
}

long duration(inout Event event) {
	return event.end - event.begin;
}

void duration(ref Event event, long value) {
  event.expectedDuration = value;
}

bool isEventOn(Event event, long date) {
  auto begin = event.begin;
  auto end = event.end;

  if(date < begin || date >= end) return false;
  if(event.itemType != EventType.Repetable) return true;

  bool result = false;

  foreach(rule; event.rules) {
    result = result || rule.isInside(begin, end, date);
  }

  return result;
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
