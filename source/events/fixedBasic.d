module btt.events.fixedbasic;

import btt.events.basic;
import btt.event;

class FixedBasicCalendarEvent : BasicCalendarEvent {
  override {
    const(EventType) itemType() const { return EventType.FixedStandard; }
    long endLimit() const { return end; }
  }
}
