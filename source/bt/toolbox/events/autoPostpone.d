module bt.toolbox.events.autopostpone;

import bt.toolbox.event;
import std.datetime;

Event eventAutoPostpone() {
  auto now = Clock.currTime.toUnixTime;

  return Event(EventType.AutoPostpone, now, 3_600, ldur!"minutes"(15), ldur!"minutes"(15));
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
