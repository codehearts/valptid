fs = require 'fs'
path = require 'path'
Browser = require 'zombie'
istanbul = require 'istanbul-lib-instrument'

describe 'timer DOM elements', ->

  valptid_path = "#{__dirname.split('/').slice(0, -1).join '/'}/valptid.js"
  valptid_source = fs.readFileSync(valptid_path).toString()
  instrumented_valptid = istanbul.createInstrumenter() \
    .instrumentSync(valptid_source, valptid_path)
  browser = undefined
  testcase = 1

  beforeEach ->
    browser = new Browser()

    # Add a pipeline handler to instrument the response body for valptid.js
    browser.pipeline.addHandler (browser, request, response) ->
      if request.url.endsWith 'valptid.js'
        response = new Browser.Response instrumented_valptid

      return response

    browser.visit "file://#{__dirname}/html/basic.html"

  afterEach ->
    # Restore the global clock object in the browser
    browser.evaluate 'clock.restore()'

    # Create a unique file to store the instrumentation
    fileName = path.basename this.currentTest.file, '.coffee'
    filePath = path.join './.nyc_output', fileName + '-' + testcase + '.json'

    # Write the instrumentation as JSON
    content = JSON.stringify __coverage__
    fs.writeFileSync filePath, content

    # Increment the testcase number
    testcase++

  set_browser_time = (epoch_time) ->
    browser.evaluate "clock.setSystemTime(#{epoch_time - 1000})"
    browser.evaluate "clock.tick(1000)"

  it 'should display correct hour difference in hours element', ->
    set_browser_time Date.parse '1971-02-02T01:01:01-00:00'
    browser.assert.text ".#{ValptidTimer.classes.hours}", "1hours"

  it 'should update seconds element every second', ->
    set_browser_time Date.parse '1971-02-02T01:01:01-00:00'
    browser.assert.text ".#{ValptidTimer.classes.seconds}", "1seconds"
    browser.evaluate "clock.next()"
    browser.assert.text ".#{ValptidTimer.classes.seconds}", "2seconds"
    browser.evaluate "clock.next()"
    browser.assert.text ".#{ValptidTimer.classes.seconds}", "3seconds"

  it 'should update minutes element when seconds wrap', ->
    set_browser_time Date.parse '1971-02-02T01:01:59-00:00'
    browser.assert.text ".#{ValptidTimer.classes.minutes}", "1minutes"
    browser.evaluate "clock.next()"
    browser.assert.text ".#{ValptidTimer.classes.minutes}", "2minutes"

  it 'should update hours element when minutes wrap', ->
    set_browser_time Date.parse '1971-02-02T01:59:59-00:00'
    browser.assert.text ".#{ValptidTimer.classes.hours}", "1hours"
    browser.evaluate "clock.next()"
    browser.assert.text ".#{ValptidTimer.classes.hours}", "2hours"

  it 'should update days element when hours wrap', ->
    set_browser_time Date.parse '1971-02-02T23:59:59-00:00'
    browser.assert.text ".#{ValptidTimer.classes.days}", "1days"
    browser.evaluate "clock.next()"
    browser.assert.text ".#{ValptidTimer.classes.days}", "2days"

  it 'should update months element when days wrap', ->
    set_browser_time Date.parse '1971-02-28T23:59:59-00:00'
    browser.assert.text ".#{ValptidTimer.classes.months}", "1months"
    browser.evaluate "clock.next()"
    browser.assert.text ".#{ValptidTimer.classes.months}", "2months"

  it 'should update years element when months wrap', ->
    set_browser_time Date.parse '1971-12-31T23:59:59-00:00'
    browser.assert.text ".#{ValptidTimer.classes.years}", "1years"
    browser.evaluate "clock.next()"
    browser.assert.text ".#{ValptidTimer.classes.years}", "2years"
