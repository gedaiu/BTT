module bt.toolbox.timeinterval;

import std.algorithm;

struct TimeInterval {
	long begin;
	long end;
}

long length(TimeInterval a) {
  return a.end - a.begin;
}

bool intersects(TimeInterval a, TimeInterval b) {
  return a.begin < b.end && a.end > b.begin;
}

TimeInterval intersection(TimeInterval a, TimeInterval b) {
  auto begin = a.begin > b.begin ? a.begin : b.begin;
  auto end = a.end < b.end ? a.end : b.end;

  return TimeInterval(begin, end);
}

TimeInterval[] intersection(TimeInterval[] list, TimeInterval interval) {
  TimeInterval[] intersections;

  foreach(item; list)
    if(item.intersects(interval))
      intersections ~= item.intersection(interval);

  return intersections;
}

unittest {
  import std.datetime : SysTime;

  auto start = SysTime.fromISOExtString("2010-01-01T00:00:00Z").toUnixTime;
  auto end = SysTime.fromISOExtString("2010-01-01T01:00:00Z").toUnixTime;

  auto start1 = SysTime.fromISOExtString("2010-01-01T00:25:00Z").toUnixTime;
  auto end1 = SysTime.fromISOExtString("2010-01-01T00:45:00Z").toUnixTime;

  auto interval = TimeInterval(start1, end1);

  auto inter = intersection( [ TimeInterval(start, end) ], interval );

  assert(inter.length == 1);
  assert(inter[0].begin == start1);
  assert(inter[0].end == end1);
}

TimeInterval[] intersection(TimeInterval[] list1, TimeInterval[] list2) {
  TimeInterval[] intersections = list1;

  foreach(item; list2)
    intersections = intersections.intersection(item);

  return intersections;
}

void subtract(ref TimeInterval[] list, TimeInterval interval) {
  TimeInterval[] newList;

  foreach(item; list) {
    if(item.intersects(interval)) {
      auto intersection = item.intersection(interval);

      auto a = TimeInterval(min(item.begin, interval.begin), intersection.begin);
      auto b = TimeInterval(intersection.end, max(item.end, interval.end));

      if(a.length > 0) newList ~= a;
      if(b.length > 0) newList ~= b;
    } else {
      newList ~= item;
    }
  }

  list = newList;
}

unittest {
  import std.datetime : SysTime;

  auto start = SysTime.fromISOExtString("2010-01-01T00:00:00Z").toUnixTime;
  auto end = SysTime.fromISOExtString("2010-01-01T01:00:00Z").toUnixTime;
  auto start1 = SysTime.fromISOExtString("2010-01-01T00:25:00Z").toUnixTime;
  auto end1 = SysTime.fromISOExtString("2010-01-01T00:45:00Z").toUnixTime;

  auto interval = TimeInterval(start1, end1);

  TimeInterval[] list;

  list ~= TimeInterval(start, end);
  list.subtract(interval);

  assert(list.length == 2);
  assert(list[0].begin == start);
  assert(list[0].end == start1);
  assert(list[1].begin == end1);
  assert(list[1].end == end);
}

unittest {
  import std.datetime : SysTime;

  auto start = SysTime.fromISOExtString("2010-01-01T00:00:00Z").toUnixTime;
  auto end = SysTime.fromISOExtString("2010-01-01T01:00:00Z").toUnixTime;

  auto start1 = SysTime.fromISOExtString("2010-01-01T01:25:00Z").toUnixTime;
  auto end1 = SysTime.fromISOExtString("2010-01-01T01:45:00Z").toUnixTime;

  auto interval = TimeInterval(start1, end1);

  TimeInterval[] list;

  list ~= TimeInterval(start, end);
  list.subtract(interval);

  assert(list.length == 1);
  assert(list[0].begin == start);
  assert(list[0].end == end);
}

TimeInterval[] subtract(TimeInterval interval, TimeInterval[] list) {
  TimeInterval[] newList;
  newList ~= interval;

  foreach(item; list) {
    newList.subtract(item);
  }

  return newList;
}

unittest {
  import std.datetime : SysTime, DateTime;

  auto start = SysTime(DateTime(2010,1,1,0,0,0)).toUnixTime;
  auto end   = SysTime(DateTime(2010,1,1,1,0,0)).toUnixTime;

  auto start1 = SysTime(DateTime(2010,1,1,0,0,0)).toUnixTime;
  auto end1   = SysTime(DateTime(2010,1,1,0,15,0)).toUnixTime;

  auto start2 = SysTime(DateTime(2010,1,1,0,20,0)).toUnixTime;
  auto end2   = SysTime(DateTime(2010,1,1,0,30,0)).toUnixTime;

  auto result = subtract(TimeInterval(start, end), [TimeInterval(start1, end1), TimeInterval(start2, end2)]);

  assert(result.length == 2);
  assert(result[0].begin == end1);
  assert(result[0].end == start2);
  assert(result[1].begin == end2);
  assert(result[1].end == end);
}
