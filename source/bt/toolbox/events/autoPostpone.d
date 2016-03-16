module bt.toolbox.events.autopostpone;

import bt.toolbox.event;
import std.datetime;

class AutoPostponeCalendarEvent : CalendarEvent {

  this() {
    _begin = Clock.currTime.toUnixTime;
    _duration = ldur!"hours"(1);
    _boundary = ldur!"minutes"(15);
    _postpone = ldur!"minutes"(15);
  }

  protected long _begin;
  protected long _end;

  ///Event start date
  @property override {
    const(EventType) itemType() const { return EventType.AutoPostpone; }

    long begin() const {
      auto now = Clock.currTime.toUnixTime;

      if(now + boundary >= _begin) {
        const auto sDate = now + postpone;
        return sDate;
      } else {
        return _begin;
      }
    }

    void begin(const long start) {
      auto now = Clock.currTime.toUnixTime;

      if(now + boundary >= start) {
        _begin = now + postpone;
      } else {
        _begin = start;
      }

      _end = _begin + _duration;
    }

    long end() const {
      return begin + _duration;
    }

    void end(const long end)  {
      _duration = end - begin;

      if(_duration <= 0) _duration = 0;

      _end = _begin + _duration;
    }

    long endLimit() const { return long.max; }

    ///return event duration
    long duration() const { return _duration; }

    ///ditto
    void duration(long customlong) { _duration = customlong; }

    ///return event postpone
    long postpone() const { return _postpone; }

    ///ditto
    void postpone(const long customPostpone) { _postpone = customPostpone; }

    ///return event boundary
    long boundary() const { return _boundary; }

    ///ditto
    void boundary(const long customBoundary) { _boundary = customBoundary; }

    @property
    Rule[] rules() const { return null; }

    @property
    void rules(Rule[] someRules) { throw new Exception("Base Event does not support rules setter");  }

    void set(long time1, long time2) {
        _duration = time2-time1;
        _begin = time1;
    }

    Json toJson() const {
      Json data = Json.emptyObject;

      data.itemType = itemType.to!string;
      data.desiredBegin = SysTime.fromUnixTime(_begin).toUTC.toISOExtString;
      data.desiredEnd = SysTime.fromUnixTime(_end).toUTC.toISOExtString;
      data.begin = SysTime.fromUnixTime(begin).toUTC.toISOExtString;
      data.end = SysTime.fromUnixTime(end).toUTC.toISOExtString;
      data.boundary = _boundary;
      data.postpone = _postpone;

      return data;
    }
  }

  static AutoPostponeCalendarEvent fromJson(Json data) {
    auto event = new AutoPostponeCalendarEvent();

    event.begin = SysTime.fromISOExtString(data["begin"].to!string).toUnixTime;
    event.end = SysTime.fromISOExtString(data["end"].to!string).toUnixTime;

    event.boundary = data["boundary"].to!long;
    event.postpone = data["postpone"].to!long;

    return event;
  }

  protected {
    long _duration;
    long _boundary;
    long _postpone;
  }
}

Event eventAutoPostpone() {
  auto now = Clock.currTime.toUnixTime;

  return Event(EventType.AutoPostpone, now, 0, ldur!"minutes"(15), ldur!"minutes"(15));
}

// End date estimation test
unittest {
  auto event = eventAutoPostpone();

  event.expectedBegin = SysTime(DateTime(2100,1,1)).toUnixTime;
  event.expectedDuration = ldur!"hours"(10);

  assert(event.end == event.begin + ldur!"hours"(10));
  assert(event.duration == ldur!"hours"(10));
}

// End date estimation test
unittest {
  auto event = eventAutoPostpone();

  event.begin = SysTime(DateTime(2100,1,1)).toUnixTime;
  event.duration = ldur!"hours"(10);

  assert(event.end == event.begin + ldur!"hours"(10));
  assert(event.duration == ldur!"hours"(10));
}

// long from end date
unittest {
  auto event = eventAutoPostpone();

  event.begin = SysTime(DateTime(2100,1,1)).toUnixTime;
  event.end = event.begin + ldur!"hours"(10);

  assert(event.duration == ldur!"hours"(10));
}

unittest {
  auto event = eventAutoPostpone();

  event.begin = SysTime(DateTime(2100,1,1)).toUnixTime;
  event.end = event.begin - ldur!"hours"(10);

  assert(event.duration == 0);
}


// Start date postpone
unittest {
  //start date postpone
  auto event = eventAutoPostpone();

  auto start = Clock.currTime.toUnixTime + ldur!"minutes"(16);
  event.begin = start;

  assert(event.begin == start);
}

// Start date postpone
unittest {
  auto event = eventAutoPostpone();
  auto start = Clock.currTime.toUnixTime;

  assert(event.begin >= start + ldur!"minutes"(14) && event.begin <= start + ldur!"minutes"(15) + 1);
}





// End date estimation test
unittest {
  auto event = new AutoPostponeCalendarEvent;

  event.begin = SysTime(DateTime(2100,1,1)).toUnixTime;
  event.duration = ldur!"hours"(10);

  assert(event.end == event.begin + ldur!"hours"(10));
}

// long from end date
unittest {
  auto event = new AutoPostponeCalendarEvent;

  event.begin = SysTime(DateTime(2100,1,1)).toUnixTime;
  event.end = event.begin + ldur!"hours"(10);

  assert(event.duration == ldur!"hours"(10));
}

// long from end date
unittest {
  auto event = new AutoPostponeCalendarEvent;

  event.begin = SysTime(DateTime(2100,1,1)).toUnixTime;
  event.end = event.begin - ldur!"hours"(10);

  assert(event.duration == 0);
}

// Start date postpone
unittest {
  //start date postpone
  auto event = new AutoPostponeCalendarEvent;

  auto start = Clock.currTime.toUnixTime + ldur!"minutes"(16);
  event.begin = start;

  assert(event.begin == start);
}

// Start date postpone
unittest {
  auto event = new AutoPostponeCalendarEvent;

  auto start = Clock.currTime.toUnixTime;

  event.begin = start;

  assert(event.begin >= start + ldur!"minutes"(14) && event.begin <= start + ldur!"minutes"(15) + 1);
}
