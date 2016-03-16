module bt.toolbox.events.basic;

import bt.toolbox.event;
import std.conv;

Event eventBasic() {
  auto now = Clock.currTime.toUnixTime;

  return Event(EventType.Standard, now, 3_600);
}

unittest {
  auto testEvent = Event(EventType.Standard, 10_000, 3_600);

  assert(testEvent.begin == 10_000);
  assert(testEvent.end == 13_600);
}
