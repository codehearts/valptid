describe 'date string', ->

  it 'should not display times of 00:00:00', ->
    timer = new ValptidTimer(new Date('2017-01-01T00:00:00-00:00'))
    diff = timer.diff_against(new Date('2017-01-02T00:00:00-00:00'))

    diff.subtitle.should.equal 'time since January 1, 2017 GMT'

  it 'should not display 0 seconds', ->
    timer = new ValptidTimer(new Date('2017-01-01T12:30:00-00:00'))
    diff = timer.diff_against(new Date('2017-01-02T12:30:00-00:00'))

    diff.subtitle.should.equal 'time since January 1, 2017 at 12:30 GMT'

  it 'should determine if time is since or until', ->
    timer = new ValptidTimer(new Date('2017-01-01T12:30:00-00:00'))
    diff = timer.diff_against(new Date('2018-01-01T12:30:00-00:00'))

    diff.subtitle.should.equal 'time since January 1, 2017 at 12:30 GMT'

    timer = new ValptidTimer(new Date('2017-01-01T12:30:00-00:00'))
    diff = timer.diff_against(new Date('2016-01-01T12:30:00-00:00'))

    diff.subtitle.should.equal 'time until January 1, 2017 at 12:30 GMT'

  it 'should display correct month name', ->
    test_data =
      'January':   '01',
      'February':  '02',
      'March':     '03',
      'April':     '04',
      'May':       '05',
      'June':      '06',
      'July':      '07',
      'August':    '08',
      'September': '09',
      'October':   '10',
      'November':  '11',
      'December':  '12',

    for month_name, month_number of test_data
      timer = new ValptidTimer(
        new Date("2017-#{month_number}-01T12:30:00-00:00"))
      diff = timer.diff_against(new Date('2018-01-01T12:30:00-00:00'))

      diff.subtitle.should.equal \
        "time since #{month_name} 1, 2017 at 12:30 GMT", month_number
