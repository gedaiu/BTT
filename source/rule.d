module btt.rule;

import std.datetime;
import btt.event;


struct WeekDays {
  bool monday;
  bool tuesday;
  bool wednesday;
  bool thursday;
  bool friday;
  bool saturday;
  bool sunday;
}

class CalendarRule {
  WeekDays days;

  TimeOfDay startTime = TimeOfDay(0,0,0);
  TimeOfDay endTime = TimeOfDay(1,0,0);

  ulong repeatAfterWeeks;
  bool weekStartOnMonday;

  string[] tags;

  /**
   * Check if a date satisfy a rule
   */
  @safe bool isInside(long start, long end, long date) {
    if(!isInsideDateInterval(start, end, date)) return false;
    if(!isInsideTimeInterval(date)) return false;
    if(!isValidWeek(start, date)) return false;
    if(!isValidDay(date)) return false;

    return true;
  }

  /**
   * Check if date is in a date range
   */
  @safe nothrow pure static bool isInsideDateInterval(long start, long end, long date) {
    if(date < start || date >= end) return false;
    return true;
  }

  /**
   * Check if date is in the same time interva as the rule
   */
  @safe nothrow bool isInsideTimeInterval(long date) {
    auto tod = (cast(DateTime) SysTime.fromUnixTime(date)).timeOfDay;

    if(tod < startTime || tod >= endTime) return false;

    return true;
  }

  /**
   * Check if date is in a valid rule week
   */
  @safe bool isValidWeek(long start, long date) {
    auto s = SysTime.fromUnixTime(start);
    auto d = SysTime.fromUnixTime(date);

    auto firstDay = s - dur!"days"(s.dayOfWeek);
    firstDay.hour = 0;
    firstDay.minute = 0;
    firstDay.second = 0;
    firstDay.fracSec = FracSec.zero;

    if(weekStartOnMonday) firstDay +=  dur!"days"(1);

    auto weeks = (d - firstDay).total!"weeks";

    return weeks % (repeatAfterWeeks+1) == 0;
  }

  /**
   * Check if date is in a valid rule week
   */
  @safe nothrow bool isValidDay(long date) {
    auto d = SysTime.fromUnixTime(date);

    auto day = d.dayOfWeek;

    if(day == 0 && days.sunday)    return true;
    if(day == 1 && days.monday)    return true;
    if(day == 2 && days.tuesday)   return true;
    if(day == 3 && days.wednesday) return true;
    if(day == 4 && days.thursday)  return true;
    if(day == 5 && days.friday)    return true;
    if(day == 6 && days.saturday)  return true;

    return false;
  }

  TimeInterval[] generateIntervalsBetween(long startStamp, long startIntervalStamp, long endIntervalStamp) {
    import std.stdio;

    auto start = SysTime.fromUnixTime(startStamp);

    auto startInterval = SysTime.fromUnixTime(startIntervalStamp);
    auto endInterval = SysTime.fromUnixTime(endIntervalStamp);

    auto firstDay = start - dur!"days"(start.dayOfWeek);
    firstDay.fracSec = FracSec.zero;

    if(weekStartOnMonday) firstDay +=  dur!"days"(1);

    auto currentDay = start;
    currentDay.fracSec = FracSec.zero;

    TimeInterval[] intervals;

    while(currentDay < endInterval) {
      long currentDayStamp = currentDay.toUnixTime;

      if(isValidWeek(startStamp, currentDayStamp) && isValidDay(currentDayStamp)) {
        auto begin = currentDayStamp + ldur!"hours"(startTime.hour);
        begin += ldur!"minutes"(startTime.minute);
        begin += startTime.second;

        auto end = currentDayStamp + ldur!"hours"(endTime.hour);
        end += ldur!"minutes"(endTime.minute);
        end += endTime.second;

        if(isInsideDateInterval(startIntervalStamp, endIntervalStamp, begin) &&
              isInsideDateInterval(startIntervalStamp, endIntervalStamp, end)) {
          intervals ~= TimeInterval(begin, end);
        }
      }

      currentDay += dur!"days"(1);
    }

    return intervals;
  }

  invariant() {
    assert(startTime <= endTime, "`boundary` < `postpone`");
  }
}

unittest {
  auto testProgram = new CalendarRule;

  bool failed = false;

  try {
    assert(testProgram);
  } catch (core.exception.AssertError e) {
    failed = true;
  }

  assert(!failed);
}

unittest {
  auto testProgram = new CalendarRule;

  testProgram.startTime = TimeOfDay(1,0,0);
  testProgram.endTime = TimeOfDay(0,0,0);

  bool failed = false;

  try {
    assert(testProgram);
  } catch (core.exception.AssertError e) {
    failed = true;
  }

  assert(failed);
}

unittest {
  long start = SysTime(DateTime(2014,1,1,0,0,0)).toUnixTime;
  long end = SysTime(DateTime(2014,1,2,0,0,0)).toUnixTime;

  //range check
  assert(!CalendarRule.isInsideDateInterval(start, end, start - 1));
  assert( CalendarRule.isInsideDateInterval(start, end, start) );
  assert( CalendarRule.isInsideDateInterval(start, end, end - 1));
  assert(!CalendarRule.isInsideDateInterval(start, end, end));
}

unittest {
  //check rule colisons
  auto testProgram = new CalendarRule;

  testProgram.startTime = TimeOfDay(10,0,0);
  testProgram.endTime = TimeOfDay(11,0,0);

  //interval check
  assert(!testProgram.isInsideTimeInterval(SysTime(DateTime(2014,1,1,10,0,0)).toUnixTime - 1));
  assert( testProgram.isInsideTimeInterval(SysTime(DateTime(2014,1,1,10,0,0)).toUnixTime) );
  assert( testProgram.isInsideTimeInterval(SysTime(DateTime(2014,1,1,11,0,0)).toUnixTime - 1));
  assert(!testProgram.isInsideTimeInterval(SysTime(DateTime(2014,1,1,11,0,0)).toUnixTime));
}

/*
  Check rule colisons
*/
unittest {
  auto testProgram = new CalendarRule;

  testProgram.startTime = TimeOfDay(10,0,0);
  testProgram.endTime = TimeOfDay(11,0,0);
  testProgram.repeatAfterWeeks = 2;

  long start = SysTime(DateTime(2014,1,1)).toUnixTime;

  //interval check
  assert( testProgram.isValidWeek(start, start));
  assert(!testProgram.isValidWeek(start, start + ldur!"weeks"(1)));
  assert(!testProgram.isValidWeek(start, start + ldur!"weeks"(2)));
  assert( testProgram.isValidWeek(start, start + ldur!"weeks"(3)));
}

/*
  Check interval generation with UTC dates
*/
unittest {
  auto testProgram = new CalendarRule;
  testProgram.startTime = TimeOfDay(10,0,0);
  testProgram.endTime = TimeOfDay(11,0,0);
  testProgram.repeatAfterWeeks = 2;

  testProgram.days.monday = true;

  long start ="2014-01-01T00:00:00Z".toTimeStamp;
  auto res = testProgram.generateIntervalsBetween(start, start, "2014-03-01T00:00:00Z".toTimeStamp);

  assert(res.length == 2);
  assert(res[0] == TimeInterval("2014-01-20T10:00:00Z".toTimeStamp, "2014-01-20T11:00:00Z".toTimeStamp));
  assert(res[1] == TimeInterval("2014-02-10T10:00:00Z".toTimeStamp, "2014-02-10T11:00:00Z".toTimeStamp));
}
