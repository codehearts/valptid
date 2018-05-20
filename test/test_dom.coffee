fs = require 'fs'
path = require 'path'
Browser = require 'zombie'
istanbul = require 'istanbul-lib-instrument'

describe 'timer DOM elements', ->

  browser = undefined
  instrumenter = istanbul.createInstrumenter coverageVariable: '__browser__'
  testcase = 1

  beforeEach ->
    browser = new Browser()

    # Add a pipeline handler to instrument the response body for valptid.js
    browser.pipeline.addHandler (browser, request, response) ->
      if request.url.endsWith 'valptid.js'
        code_file = request.url.replace 'file://', ''
        code = fs.readFileSync(code_file).toString()

        response = new Browser.Response \
          instrumenter.instrumentSync(code, code_file)

      return response

    # basic.html timer:    1970-01-01T00:00:00-00:00
    # basic.html Date.now: 1971-02-02T01:01:01-00:00
    browser.visit "file://#{__dirname}/html/basic.html"

  afterEach ->
    # Restore the global clock object in the browser
    browser.evaluate 'clock.restore()'

    # Create a unique file to store the instrumentation
    fileName = path.basename this.currentTest.file, '.coffee'
    filePath = path.join './.nyc_output', fileName + '-' + testcase + '.json'

    # Write the instrumentation as JSON
    content = JSON.stringify browser.evaluate '__browser__'
    fs.writeFileSync filePath, content

    # Increment the testcase number
    testcase++

  it 'should display correct hour difference in hours element', ->
    browser.assert.text ".#{ValptidTimer.classes.hours}", "1hours"
