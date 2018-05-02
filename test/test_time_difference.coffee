require '../valptid.js'

describe 'time difference', ->

  it 'should wrap hours around the hour, minute, and second offset of the timer', ->
    timer = new ValptidTimer(new Date('2017-01-02T12:30:30'))

    test_data =
      # past times
      '2017-01-01T11:30:30':  1, # 1d01h00m00s until
      '2017-01-01T11:30:31':  0, # 1d00h59m59s until
      '2017-01-01T12:30:30':  0, # 1d00h00m00s until
      '2017-01-01T13:30:30': 23, # 0d23h00m00s until
      # present time
      '2017-01-02T11:30:30':  1, # 0d01h00m00s until
      '2017-01-02T11:30:31':  0, # 0d00h59m59s until
      '2017-01-02T13:30:29':  0, # 0d00h59m59s since
      '2017-01-02T13:30:30':  1, # 0d01h00m00s since
      # future times
      '2017-01-03T12:30:29': 23, # 0d23h59m59s since
      '2017-01-03T12:30:30':  0, # 1d00h00m00s since
      '2017-01-03T13:30:29':  0, # 1d00h59m59s since
      '2017-01-03T13:30:30':  1, # 1d01h00m00s since

    for compare_date, expected_hours of test_data
      diff = timer.diff_against(new Date(compare_date))
      diff.hours.should.equal expected_hours, compare_date

  it 'should wrap minutes around the minute and second offset of the timer', ->
    timer = new ValptidTimer(new Date('2017-01-01T12:30:30'))

    test_data =
      # past times
      '2017-01-01T00:29:30':  1, # 12h01m00s until
      '2017-01-01T00:29:31':  0, # 12h00m59s until
      '2017-01-01T01:30:30':  0, # 11h00m00s until
      '2017-01-01T01:30:31': 59, # 10h59m59s until
      # present time
      '2017-01-01T12:29:30':  1, # 00h01m00s until
      '2017-01-01T12:29:31':  0, # 00h00m59s until
      '2017-01-01T12:31:29':  0, # 00h00m59s since
      '2017-01-01T12:31:30':  1, # 00h01m00s since
      # future times
      '2017-01-01T13:29:30': 59, # 00h59m00s since
      '2017-01-01T13:30:30':  0, # 01h00m00s since
      '2017-01-01T13:31:29':  0, # 01h00m59s since
      '2017-01-01T13:31:30':  1, # 01h01m00s since

    for compare_date, expected_minutes of test_data
      diff = timer.diff_against(new Date(compare_date))
      diff.minutes.should.equal expected_minutes, compare_date

  it 'should wrap seconds around the second offset of the timer', ->
    timer = new ValptidTimer(new Date('2017-01-01T12:30:30'))

    test_data =
      # past times
      '2017-01-01T00:30:29':  1, # 12h00m01s until
      '2017-01-01T00:30:30':  0, # 12h00m00s until
      '2017-01-01T00:30:31': 59, # 11h59m59s until
      # present time
      '2017-01-01T12:30:29':  1, # 00h00m01s until
      '2017-01-01T12:30:30':  0, # 00h00m00s until
      '2017-01-01T12:30:31':  1, # 00h00m01s since
      # future times
      '2017-01-01T12:31:29': 59, # 00h00m59s since
      '2017-01-01T12:31:30':  0, # 00h01m00s since
      '2017-01-01T12:31:31':  1, # 00h01m01s since

    for compare_date, expected_seconds of test_data
      diff = timer.diff_against(new Date(compare_date))
      diff.seconds.should.equal expected_seconds, compare_date
