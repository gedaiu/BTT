module btt;

public import bt.toolbox.rule;
public import bt.toolbox.event;

public import bt.toolbox.events.autopostpone;
public import bt.toolbox.events.basic;
public import bt.toolbox.events.fixedbasic;
public import bt.toolbox.events.repetable;
public import bt.toolbox.events.unknownend;


CalendarEvent CalendarFrom(Json data) {
  if(data["itemType"] == "Standard")
    return BasicCalendarEvent.fromJson(data);

  if(data["itemType"] == "UnknownEnd")
    return UnknownEndCalendarEvent.fromJson(data);

  if(data["itemType"] == "FixedStandard")
    return FixedBasicCalendarEvent.fromJson(data);

  if(data["itemType"] == "AutoPostpone")
    return AutoPostponeCalendarEvent.fromJson(data);

  throw new Exception("`" ~ data["itemType"].to!string ~ "` not implemented.");
}
