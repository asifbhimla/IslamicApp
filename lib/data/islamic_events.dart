/// Notable dates of the Islamic year, keyed by (hijri month, hijri day).
class IslamicEvent {
  const IslamicEvent(this.month, this.day, this.name);

  final int month;
  final int day;
  final String name;
}

const List<IslamicEvent> islamicEvents = [
  IslamicEvent(1, 1, 'Islamic New Year'),
  IslamicEvent(1, 10, 'Day of Ashura'),
  IslamicEvent(3, 12, 'Mawlid an-Nabi ﷺ'),
  IslamicEvent(7, 27, "Isra' and Mi'raj"),
  IslamicEvent(8, 15, "Mid-Sha'ban"),
  IslamicEvent(9, 1, 'First day of Ramadan'),
  IslamicEvent(9, 27, 'Laylatul Qadr (27th night)'),
  IslamicEvent(10, 1, 'Eid al-Fitr'),
  IslamicEvent(12, 9, 'Day of Arafah'),
  IslamicEvent(12, 10, 'Eid al-Adha'),
];

IslamicEvent? eventOn(int hijriMonth, int hijriDay) {
  for (final event in islamicEvents) {
    if (event.month == hijriMonth && event.day == hijriDay) return event;
  }
  return null;
}
