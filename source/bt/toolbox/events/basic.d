module bt.toolbox.events.basic;

import bt.toolbox.event;
import std.conv;

/**
 * Implementation for a basic calendar event
 */

class BasicCalendarEvent : CalendarEvent {
  //Event start date
  protected long _begin;

  //Event end date
  protected long _end;

  this() {
    _begin = long.min;
    _end = long.max;
  }

  override {
    @property {
      const(EventType) itemType() const {
        return EventType.Standard;
      }

      void begin(const long begin) {
        _begin = begin;
      }

      long begin() const {
        return _begin;
      }

      void end(const long end) {
        _end = end;
      }

      long end() const {
        return _end;
      }

      long endLimit() const {
        return long.max;
      }

      ///return event duration
      long duration() const {
        return end - begin;
      }

      ///ditto
      void duration(long duration) {
        end = begin + duration;
      }

      ///return event boundary
      long boundary() const {
        return ldur!"minutes"(0);
      }

      ///ditto
      void boundary(const long customBoundary) {
        throw new Exception("Base Event does not support boundary setter");
      }

      ///return event postpone
      long postpone() const {
        return ldur!"minutes"(0);
      }

      ///ditto
      void postpone(const long customPostpone) {
        throw new Exception("Base Event does not support postpone setter");
      }

      Rule[] rules() const {
        return null;
      }

      void rules(Rule[] someRules) {
        throw new Exception("Base Event does not support rules setter");
      }
    }

    void set(long time1, long time2) in {
      assert(time1 <= time2);
    } body{
      if(time1 > _end) {
        _end = time2;
        _begin = time1;
      } else {
        _begin = time1;
        _end = time2;
      }
    }

    Json toJson() const {
      Json data = Json.emptyObject;

      data["itemType"] = itemType.to!string;
      data["end"] = SysTime.fromUnixTime(end).toUTC.toISOExtString;
      data["begin"] = SysTime.fromUnixTime(begin).toUTC.toISOExtString;

      return data;
    }
  }

  static BasicCalendarEvent fromJson(Json src) {
    auto elm = new BasicCalendarEvent();

    elm.set(SysTime.fromISOExtString(src.begin.to!string).toUnixTime,
            SysTime.fromISOExtString(src.end.to!string).toUnixTime);

    return elm;
  }

  ///Invariant to check the event consistency
  invariant() {
    assert(_begin <= _end, "`begin` > `end`: " ~ _begin.to!string ~ ">" ~ _end.to!string);
  }
}

Event eventBasic() {
  auto now = Clock.currTime.toUnixTime;

  return Event(EventType.Standard, now, 3_600);
}


unittest {
  auto testEvent = Event(EventType.Standard, 10_000, 3_600);

  assert(testEvent.begin == 10_000);
  assert(testEvent.end == 13_600);
}




unittest {
  auto testEvent = new BasicCalendarEvent;
  bool failed = false;

  try {
    testEvent.begin = 10_000;
    testEvent.end = 10_000 - ldur!"hours"(1);
  } catch (Throwable e) {
    failed = true;
  }

  assert(failed);
}

unittest {
  auto testEvent = new BasicCalendarEvent;

  testEvent.begin = 10_000;
  testEvent.end = 10_000 + ldur!"hours"(1);

  bool failed = false;

  try {
    assert(testEvent);
  } catch (Throwable e) {
    failed = true;
  }

  assert(!failed);
}
