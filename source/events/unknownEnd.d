module btt.events.unknownend;

import btt.event;
import btt.events.basic;

import std.datetime;

class UnknownEndCalendarEvent : BasicCalendarEvent
{
  this() {
    _begin = Clock.currTime.toUnixTime;
    _duration = ldur!"hours"(1);
  }

  protected long _begin;
  protected long _duration;

  ///Event start date
  @property override {
    const(EventType) itemType() const { return EventType.UnknownEnd; }

    long begin() const {
      return _begin;
    }

    void begin(const long start) {
      _begin = start;
    }

    long end() const {
      auto _end = begin + _duration;
      auto now = Clock.currTime.toUnixTime;

      return (_end < now ? now : _end);
    }

    long endLimit() const { return long.max; }

    void end(const long end)  {
      _duration = _duration <= 0 ? 0 : end - _begin;
    }

    ///return event duration
    long duration() const { return _duration; }

    ///ditto
    void duration(long customlong) { _duration = customlong; }

    ///return event postpone
    long postpone() const { return 0; }

    ///ditto
    void postpone(const long customPostpone) { throw new Exception("Unknown end event does not support postpone setter"); }

    ///return event boundary
    long boundary() const { return 0; }

    ///ditto
    void boundary(const long customBoundary) { throw new Exception("Unknown end event does not support boundary setter"); }

    @property
    Rule[] rules() const { return null; }

    @property
    void rules(Rule[] someRules) { throw new Exception("Unknown end event does not support rules setter");  }

    void set(long time1, long time2) {
      if(time1 > end) {
        end = time2;
        begin = time1;
      } else {
        begin = time1;
        end = time2;
      }
    }
  }
}

// UnknownEnd end should be equal to current time
unittest {
  auto begin = Clock.currTime.toUnixTime;
  auto event = new UnknownEndCalendarEvent;
  event.begin = SysTime(DateTime(2000,1,1), UTC()).toUnixTime;

  assert(event.end <= Clock.currTime.toUnixTime && event.end >= begin);
}

// UnknownEnd end should be equal to initial end time
unittest {
  auto event = new UnknownEndCalendarEvent;
  event.begin = SysTime(DateTime(2100,1,1), UTC()).toUnixTime;

  assert(event.end == SysTime(DateTime(2100,1,1, 1,0,0), UTC()).toUnixTime);
}
