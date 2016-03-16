module bt.toolbox.events.fixedbasic;

import bt.toolbox.events.basic;
import bt.toolbox.event;

class FixedBasicCalendarEvent : BasicCalendarEvent {
  override {
    const(EventType) itemType() const { return EventType.FixedStandard; }
    long endLimit() const { return end; }
  }
}
