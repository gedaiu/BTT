module bt.toolbox.events.repetable;

import bt.toolbox.event;
import bt.toolbox.events.basic;

import std.datetime;

Event eventRepetable() {
  auto now = Clock.currTime.toUnixTime;

  return Event(EventType.Repetable, now, 3_600);
}

// Test outside events
unittest {
  auto testEvent = eventRepetable();
  testEvent.begin = SysTime(DateTime(2014,1,1)).toUnixTime;
  testEvent.end = SysTime(DateTime(2015,1,1)).toUnixTime;

  assert(!testEvent.isEventOn( SysTime(DateTime(2014,1,1)).toUnixTime - 1 ));
  assert(!testEvent.isEventOn( SysTime(DateTime(2015,1,1)).toUnixTime ));
}

// Test outside events
unittest {
  auto testEvent = eventRepetable();
  testEvent.begin = SysTime(DateTime(2014,1,1)).toUnixTime;
  testEvent.end = SysTime(DateTime(2015,1,1)).toUnixTime;

  Rule rule1 = new Rule;
  rule1.days.monday = true;
  rule1.startTime = TimeOfDay(10,0,0);
  rule1.endTime = TimeOfDay(11,0,0);
  rule1.repeatAfterWeeks = 2;

  Rule rule2 = new Rule;
  rule2.days.tuesday = true;
  rule2.startTime = TimeOfDay(12,0,0);
  rule2.endTime = TimeOfDay(14,0,0);
  rule2.repeatAfterWeeks = 2;

  auto rules = [rule1, rule2];
  testEvent.rules = rules;

  //test the first rule
  assert(!testEvent.isEventOn( SysTime(DateTime(2014,1,20, 10,0,0)).toUnixTime - 1));
  assert( testEvent.isEventOn( SysTime(DateTime(2014,1,20, 10,0,0)).toUnixTime));
  assert( testEvent.isEventOn( SysTime(DateTime(2014,1,20, 11,0,0)).toUnixTime - 1));
  assert(!testEvent.isEventOn( SysTime(DateTime(2014,1,20, 11,0,0)).toUnixTime));

  assert(!testEvent.isEventOn( SysTime(DateTime(2014,1,13, 10,0,0)).toUnixTime));
  assert(!testEvent.isEventOn( SysTime(DateTime(2014,1,13, 11,0,0)).toUnixTime - 1));

  //test the second rule
  assert(!testEvent.isEventOn( SysTime(DateTime(2014,1,21, 12,0,0)).toUnixTime - 1));
  assert( testEvent.isEventOn( SysTime(DateTime(2014,1,21, 12,0,0)).toUnixTime));
  assert( testEvent.isEventOn( SysTime(DateTime(2014,1,21, 14,0,0)).toUnixTime - 1));
  assert(!testEvent.isEventOn( SysTime(DateTime(2014,1,21, 14,0,0)).toUnixTime));

  assert(!testEvent.isEventOn( SysTime(DateTime(2014,1,14, 12,0,0)).toUnixTime));
  assert(!testEvent.isEventOn( SysTime(DateTime(2014,1,14, 14,0,0)).toUnixTime - 1));
}
