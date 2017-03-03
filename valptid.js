'use strict';

(function() {

  const TIMER_CLASS         = 'timer';
  const TIMER_TITLE_CLASS   = 'timer-title';
  const TIMER_VALUES_CLASS  = 'timer-values';
  const TIMER_YEARS_CLASS   = 'timer-years';
  const TIMER_MONTHS_CLASS  = 'timer-months';
  const TIMER_DAYS_CLASS    = 'timer-days';
  const TIMER_HOURS_CLASS   = 'timer-hours';
  const TIMER_MINUTES_CLASS = 'timer-minutes';
  const TIMER_SECONDS_CLASS = 'timer-seconds';

  /* creates a valptid timer object to initialise and modify a timer element */
  function ValptidTimer(element) {

    // initialise this object from the element
    this.initialise_from_element(element);

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
    /* reflow once per timer by working on a document fragment in memory */
    var working_element = document.createDocumentFragment();

    /* add title, subtitle, etc */
    working_element.appendChild(this.create_title_element());
    working_element.appendChild(this.create_time_value_container_element());

    /* add the working element to the DOM */
    this.elements['parent'].appendChild(working_element);
  }

  /*
   *
   * ValptidTimer data initialisation functions
   *
   */

  /* initialises the title and Date object from the timer element */
  ValptidTimer.prototype.initialise_from_element = function(element) {
    this.elements = { 'parent': element };

    /* title comes from data-title attribute. defaults to 'untitled' if not present */
    this.title = element.dataset.hasOwnProperty('title') ? element.dataset.title : 'untitled';

    /* Date object is initialised by data-date attribute. defaults to unix epoch if not present */
    /* TODO display an error if data-date wasn't defined */
    this.date = new Date(element.dataset.hasOwnProperty('date') ? element.dataset.date : '1970-01-01');

    this.years   = 0;
    this.months  = 0;
    this.days    = 0;
    this.hours   = 0;
    this.minutes = 0;
    this.seconds = 0;

    /* initialise the DOM with the new properties of this timer */
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

    // kick off the timers
    initialise_timers();

  }

  // kick off valptid
  Valptid();

})();
