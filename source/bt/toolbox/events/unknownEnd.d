module bt.toolbox.events.unknownend;

import bt.toolbox.event;
import bt.toolbox.events.basic;

import std.datetime;

Event eventUnknownEnd() {
  auto now = Clock.currTime.toUnixTime;

  return Event(EventType.UnknownEnd, now, 3_600, ldur!"minutes"(15), ldur!"minutes"(15));
}


// UnknownEnd end should be equal to current time
unittest {
  auto now = Clock.currTime.toUnixTime;
  auto begin = SysTime(DateTime(2000,1,1), UTC()).toUnixTime;

  auto event = eventUnknownEnd();
  event.begin = begin;

  assert(event.end <= Clock.currTime.toUnixTime && event.end >= begin);
  assert(event.duration == now - begin);
}

// UnknownEnd end should be equal to initial end time
unittest {
  auto event = eventUnknownEnd();
  event.begin = SysTime(DateTime(2100,1,1), UTC()).toUnixTime;

  assert(event.end == SysTime(DateTime(2100,1,1, 1,0,0), UTC()).toUnixTime);
  assert(event.duration == 3600);
}
