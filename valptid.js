'use strict';

const TIMER_CLASS          = 'timer';
const TIMER_TITLE_CLASS    = 'timer-title';
const TIMER_SUBTITLE_CLASS = 'timer-subtitle';
const TIMER_VALUES_CLASS   = 'timer-values';
const TIMER_YEARS_CLASS    = 'timer-years';
const TIMER_MONTHS_CLASS   = 'timer-months';
const TIMER_DAYS_CLASS     = 'timer-days';
const TIMER_HOURS_CLASS    = 'timer-hours';
const TIMER_MINUTES_CLASS  = 'timer-minutes';
const TIMER_SECONDS_CLASS  = 'timer-seconds';
const MONTH_NAMES          = ['January','February','March','April','May','June','July','August','September','October','November','December'];

/* creates a valptid timer object to initialise and modify a timer element */
function ValptidTimer(element) {

  if (Date.prototype.isPrototypeOf(element)) {
    // initialise from Date object
    this.date = element;
  } else {
    // initialise this object from the element
    this.initialise_from_element(element);
  }

}

ValptidTimer.classes = {
  hours: TIMER_HOURS_CLASS,
}

/*
 *
 * ValptidTimer DOM functions
 *
 */

/* creates the title element for this timer */
ValptidTimer.prototype.create_title_element = function() {
  var element = document.createElement('h1');
  element.className   = TIMER_TITLE_CLASS;
  element.textContent = this.title;
  return element;
}

/* creates the subtitle element for this timer */
ValptidTimer.prototype.create_subtitle_element = function() {
  var element = document.createElement('h2');
  element.className   = TIMER_SUBTITLE_CLASS;
  element.textContent = this.subtitle;
  return element;
}

/* creates an individual time value element with a label, and stores it as this.elements[label] */
ValptidTimer.prototype.create_time_value_element = function(value, label, cls) {
  var container_element = document.createElement('figure'),
      label_element = document.createElement('figcaption');

  container_element.className   = cls;
  container_element.textContent = value;

  label_element.textContent = label;
  container_element.appendChild(label_element);

  this.elements[label] = container_element;

  return container_element;
}

/* creates the time value elements for this timer */
ValptidTimer.prototype.create_time_value_container_element = function() {
  var container_element = document.createElement('section');
  container_element.className = TIMER_VALUES_CLASS;

  container_element.appendChild(this.create_time_value_element(this.years,   'years',   TIMER_YEARS_CLASS));
  container_element.appendChild(this.create_time_value_element(this.months,  'months',  TIMER_MONTHS_CLASS));
  container_element.appendChild(this.create_time_value_element(this.days,    'days',    TIMER_DAYS_CLASS));
  container_element.appendChild(this.create_time_value_element(this.hours,   'hours',   TIMER_HOURS_CLASS));
  container_element.appendChild(this.create_time_value_element(this.minutes, 'minutes', TIMER_MINUTES_CLASS));
  container_element.appendChild(this.create_time_value_element(this.seconds, 'seconds', TIMER_SECONDS_CLASS));

  return container_element;
}

/* initialises all DOM nodes for this timer */
ValptidTimer.prototype.initialise_dom = function() {
  // reflow once per timer by working on a document fragment in memory
  var working_element = document.createDocumentFragment();

  // add title, subtitle, etc
  working_element.appendChild(this.create_title_element());
  working_element.appendChild(this.create_subtitle_element());
  working_element.appendChild(this.create_time_value_container_element());

  // add the working element to the DOM
  this.elements['parent'].appendChild(working_element);
}

/*
 *
 * ValptidTimer data initialisation and processing functions
 *
 */

/* calculates the time difference between this timer's date and the given one */
ValptidTimer.prototype.diff_against = function(other_date) {
  // determine whether the timer is in the past or the future from the other date
  this.is_in_past = (this.date < other_date);

  // store the dates as newer and older
  let [newer_date, older_date] = (this.is_in_past) ? [other_date, this.date] : [this.date, other_date];
  let timezone_adjusted_date = new Date(this.date.getTime() + this.date.getTimezoneOffset() * 60000);

  let older = {
    'year':   older_date.getUTCFullYear(),
    'month':  older_date.getUTCMonth(),
    'day':    older_date.getUTCDate(),
    'hour':   older_date.getUTCHours(),
    'minute': older_date.getUTCMinutes(),
    'second': older_date.getUTCSeconds()
  };

  let newer = {
    'year':   newer_date.getUTCFullYear(),
    'month':  newer_date.getUTCMonth(),
    'day':    newer_date.getUTCDate(),
    'hour':   newer_date.getUTCHours(),
    'minute': newer_date.getUTCMinutes(),
    'second': newer_date.getUTCSeconds()
  };

  let timezone_adjusted = {
    'year':   timezone_adjusted_date.getFullYear(),
    'month':  timezone_adjusted_date.getMonth(),
    'day':    timezone_adjusted_date.getDate(),
    'hour':   timezone_adjusted_date.getHours(),
    'minute': timezone_adjusted_date.getMinutes(),
    'second': timezone_adjusted_date.getSeconds(),
    'string': timezone_adjusted_date.toUTCString()
  };

  // calculate months
  this.months = (newer.year * 12 + newer.month) - (older.year * 12 + older.month);

  if (newer.day < older.day) {
    this.months -= 1; // exclude when newer date's day of month is earlier than older date's
  } else if (older.day == newer.day) {
    if (older.hour > newer.hour || older.minute > newer.minute || older.second > newer.second) {
      this.months -= 1; // exclude when day of month is same, but newer date's time of day is earlier
    }
  }

  // use seconds to calculate seconds, minutes, hours, and days
  this.seconds = newer.second - older.second;
  this.minutes = (60*(newer.minute - older.minute) + this.seconds) / 60;
  this.hours   = (60*(60*(newer.hour - older.hour) + this.minutes) + this.seconds) / 3600;
  this.days    = (60*(60*(24*(newer.day - older.day) + this.hours) + this.minutes) + this.seconds) / 86400;

  // add the number of days in each month until the days are positive
  // if the timer date is before the other date, start from the month before the other date's month
  // if the timer date is after the other date, start from the other date's month
  // 1/15 compared to 2/14 is 14-15 = -1 days, plus the 31 days in the month before february to get 30 days
  // 3/14 compared to 2/15 is 14-15 = -1 days, plus the 28 days in february to get 27 days
  for (let i = (this.is_in_past ? 0 : 1); this.days < 0; i++) {
    this.days += new Date(other_date.getUTCFullYear(), other_date.getUTCMonth() + i, 0, 0, 0, 0, 0).getUTCDate();
  }

  // cap minutes/seconds between 0-59 and hours between 0-23
  // ~~ efficiently casts to int without rounding
  this.seconds =   (60 + this.seconds) % 60;
  this.minutes = ~~(60 + this.minutes) % 60;
  this.hours   = ~~(24 + this.hours)   % 24;
  this.years   = ~~(this.months / 12);
  this.months  =    this.months % 12;
  this.days    = ~~(this.days);
  this.total_days = ~~((newer_date - older_date) / 86400000);

  if (this.is_in_past) {
    this.subtitle = 'time since ';
  } else {
    this.subtitle = 'time until ';
  }

  this.subtitle += MONTH_NAMES[timezone_adjusted.month];
  this.subtitle += ' ' + timezone_adjusted.day;
  this.subtitle += ', ' + timezone_adjusted.year;
  if (timezone_adjusted.hour != 0 || timezone_adjusted.minute != 0 || timezone_adjusted.second != 0) {
    this.subtitle += ' at';
    this.subtitle += ((timezone_adjusted.hour < 10) ? ' 0' : ' ') + timezone_adjusted.hour;
    this.subtitle += ((timezone_adjusted.minute < 10) ? ':0' : ':') + timezone_adjusted.minute;

    if (timezone_adjusted.second != 0) {
      this.subtitle += ((timezone_adjusted.second < 10) ? ':0' : ':') + timezone_adjusted.second;
    }
  }
  this.subtitle += ' ' + timezone_adjusted.string.substr(timezone_adjusted.string.lastIndexOf(' ') + 1);

  return this;
}

/* initialises the title and Date object from the timer element */
ValptidTimer.prototype.initialise_from_element = function(element) {
  this.elements = { 'parent': element };

  // title comes from data-title attribute. defaults to 'untitled' if not present
  this.title = element.dataset.hasOwnProperty('title') ? element.dataset.title : 'untitled';

  // Date object is initialised by data-date attribute. defaults to unix epoch if not present
  this.date = new Date((element.dataset.hasOwnProperty('date') ? element.dataset.date : '1970-01-01'));

  this.diff_against(new Date(Date.now()));

  // initialise the DOM with the new properties of this timer
  this.initialise_dom();
}



/* initialises and periodically updates all timers */
function Valptid() {

  var timers = []; // list of all timers

  /* initialises and tracks ValptidTimers for all timers in the DOM */
  function initialise_timers() {
    for (var timer_element of document.querySelectorAll('.' + TIMER_CLASS)) {
      timers.push(new ValptidTimer(timer_element));
    }
  }

  /* loads in the valptid stylesheet and fonts */
  function initialise_stylesheet() {
    var stylesheet_element  = document.createElement('link'),
        font_element = document.createElement('link');

    // load fonts from google
    font_element.rel  = 'stylesheet';
    font_element.href = 'https://fonts.googleapis.com/css?family=Work+Sans:300,400,700';
    document.head.appendChild(font_element);

    // load the valptid stylesheet
    stylesheet_element.rel  = 'stylesheet';
    stylesheet_element.href = 'style.css';
    document.head.appendChild(stylesheet_element);
  }

  // kick off the timers
  initialise_stylesheet();
  initialise_timers();

}

// if running as a node.js module
if (typeof module !== 'undefined' && module.exports !== null) {
  // export for node.js
  global.ValptidTimer = ValptidTimer;
} else {
  // kick off valptid
  Valptid();
}
