require '../valptid.js'

describe 'date difference', ->

  it 'should wrap days around months and the time offset of the timer', ->
    timer = new ValptidTimer(new Date('2017-02-03T12:30:30Z'))

    test_data =
      # past dates
      '2017-01-03T12:30:30':  0, # 1m00d00h00h00s until
      '2017-01-03T12:30:31': 30, # 0m30d23h59m59s until
      '2017-01-04T12:30:30': 30, # 0m30d00h00m00s until
      '2017-01-04T12:30:31': 29, # 0m29d23h59m59s until
      # present dates
      '2017-02-02T12:30:30':  1, # 0m1d00h00m00s until
      '2017-02-02T12:30:31':  0, # 0m0d23h59m59s until
      '2017-02-04T12:30:29':  0, # 0m0d23h59m59s since
      '2017-02-04T12:30:30':  1, # 0m1d00h00m00s since
      # future dates
      '2017-03-03T12:30:29': 27, # 0m27d23h59m59s since
      '2017-03-03T12:30:30':  0, # 1m00d00h00m00s since
      '2017-03-04T12:30:29':  0, # 1m00d23h59m59s since
      '2017-03-04T12:30:30':  1, # 1m01d00h00m00s since

    for compare_date, expected_days of test_data
      diff = timer.diff_against(new Date(compare_date + 'Z'))
      diff.days.should.equal expected_days, compare_date

  it 'should wrap days around february 29 on leap years', ->
    timer = new ValptidTimer(new Date('2016-03-01T12:30:30Z'))

    test_data =
      # past dates
      '2016-02-28T12:30:30': 2, # 2d00h00h00s until
      '2016-02-28T12:30:31': 1, # 1d23h59m59s until
      '2016-02-29T12:30:30': 1, # 1d00h00h00s until
      '2016-02-29T12:30:31': 0, # 0d23h59m59s until
      # future dates
      '2016-03-02T12:30:29': 0, # 0d23h59m59s since
      '2016-03-02T12:30:30': 1, # 1d00h00m00s since
      '2016-03-03T12:30:29': 1, # 1d23h59m59s since
      '2016-03-03T12:30:30': 2, # 2d00h00m00s since

    for compare_date, expected_days of test_data
      diff = timer.diff_against(new Date(compare_date + 'Z'))
      diff.days.should.equal expected_days, compare_date

  it 'should wrap total days around the time offset of the timer', ->
    timer = new ValptidTimer(new Date('2017-02-01T12:30:30Z'))

    test_data =
      # past dates
      '2017-01-01T12:30:30': 31, # 31d00h00h00s until
      '2017-01-01T12:30:31': 30, # 30d23h59m59s until
      '2017-01-02T12:30:30': 30, # 30d00h00m00s until
      '2017-01-02T12:30:31': 29, # 29d23h59m59s until
      # present dates
      '2017-01-31T12:30:30':  1, # 1d00h00m00s until
      '2017-01-31T12:30:31':  0, # 0d23h59m59s until
      '2017-02-02T12:30:29':  0, # 0d23h59m59s since
      '2017-02-02T12:30:30':  1, # 1d00h00m00s since
      # future dates
      '2017-03-03T12:30:29': 29, # 29d23h59m59s since
      '2017-03-03T12:30:30': 30, # 30d00h00m00s since
      '2017-03-04T12:30:29': 30, # 30d23h59m59s since
      '2017-03-04T12:30:30': 31, # 31d00h00m00s since

    for compare_date, expected_days of test_data
      diff = timer.diff_against(new Date(compare_date + 'Z'))
      diff.total_days.should.equal expected_days, compare_date

  it 'should count february 29 in total days on leap years', ->
    timer = new ValptidTimer(new Date('2016-02-01T12:30:30Z'))

    test_data =
      '2016-02-01T12:30:30':  0, # 0d since
      '2016-02-02T12:30:30':  1, # 1d since
      '2016-02-29T12:30:29': 27, # 27d since
      '2016-02-29T12:30:30': 28, # 28d since
      '2016-03-01T12:30:30': 29, # 29d since

    for compare_date, expected_days of test_data
      diff = timer.diff_against(new Date(compare_date + 'Z'))
      diff.total_days.should.equal expected_days, compare_date

  it 'should wrap months around the time offset of the timer', ->
    timer = new ValptidTimer(new Date('2017-02-15T12:30:30Z'))

    test_data =
      # past dates
      '2016-01-15T12:30:30':  1, # 1y01m00d00h00m00s until
      '2016-01-15T12:30:31':  0, # 1y00m30d23h59m59s until
      '2016-02-15T12:30:30':  0, # 1y00m00d00h00m00s until
      '2016-02-15T12:30:31': 11, # 0y11m30d23h59m59s until
      # present dates
      '2017-01-15T12:30:30':  1, # 1m00d00h00m00s until
      '2017-01-15T12:30:31':  0, # 0m30d23h59m59s until
      '2017-03-15T12:30:29':  0, # 0m27d23h59m59s since
      '2017-03-15T12:30:30':  1, # 1m00d00h00m00s since
      # future dates
      '2018-02-15T12:30:29': 11, # 0y11m30d23h59m59s since
      '2018-02-15T12:30:30':  0, # 1y00m00d00h00m00s since
      '2018-03-15T12:30:29':  0, # 1y00m27d23h59m59s since
      '2018-03-15T12:30:30':  1, # 1y01m00d00h00m00s since

    for compare_date, expected_months of test_data
      diff = timer.diff_against(new Date(compare_date + 'Z'))
      diff.months.should.equal expected_months, compare_date

  it 'should wrap months around february 29 on leap years', ->
    timer = new ValptidTimer(new Date('2016-04-01T12:30:30Z'))

    test_data =
      # past dates
      '2016-02-01T12:30:30': 2, # 2m00d00h00m00s until
      '2016-02-29T12:30:30': 1, # 1m01d00h00m00s until
      '2016-03-01T12:30:30': 1, # 1m00d00h00m00s until
      '2016-03-02T12:30:30': 0, # 0m30d00h00m00s until

    for compare_date, expected_months of test_data
      diff = timer.diff_against(new Date(compare_date + 'Z'))
      diff.months.should.equal expected_months, compare_date

    timer = new ValptidTimer(new Date('2016-01-01T12:30:30Z'))

    test_data =
      # future dates
      '2016-01-31T12:30:30': 0, # 0m30d00h00m00s since
      '2016-02-01T12:30:30': 1, # 1m00d00h00m00s since
      '2016-02-29T12:30:30': 1, # 1m28d00h00m00s since
      '2016-03-01T12:30:30': 2, # 2m00d00h00m00s since

    for compare_date, expected_months of test_data
      diff = timer.diff_against(new Date(compare_date + 'Z'))
      diff.months.should.equal expected_months, compare_date

  it 'should wrap years around the time offset of the timer', ->
    timer = new ValptidTimer(new Date('2017-01-01T12:30:30Z'))

    test_data =
      # past dates
      '2015-01-01T12:30:30': 2, # 2y00m00d00h00m00s until
      '2015-01-01T12:30:31': 1, # 1y11m30d23h59m59s until
      '2016-01-01T12:30:30': 1, # 1y00m00d00h00m00s until
      '2016-01-01T12:30:31': 0, # 0y11m30d23h59m59s until
      # future dates
      '2018-01-01T12:30:29': 0, # 0y11m30d23h59m59s since
      '2018-01-01T12:30:30': 1, # 1y00m00d00h00m00s since
      '2019-01-01T12:30:29': 1, # 1y11m30d23h59m59s since
      '2019-01-01T12:30:30': 2, # 1y01m00d00h00m00s since

    for compare_date, expected_years of test_data
      diff = timer.diff_against(new Date(compare_date + 'Z'))
      diff.years.should.equal expected_years, compare_date

  it 'should wrap months and days together', ->
    timer = new ValptidTimer(new Date('2017-02-03T12:30:30Z'))

    test_data =
      '2016-12-03T12:30:30': [ 2,  0], # [ months, days ]
      '2016-12-03T12:30:31': [ 1, 30],
      '2017-01-03T12:30:30': [ 1,  0],
      '2017-01-03T12:30:31': [ 0, 30],
      '2017-02-03T12:30:30': [ 0,  0], # timer date
      '2017-03-03T12:30:29': [ 0, 27],
      '2017-03-03T12:30:30': [ 1,  0],
      '2017-04-03T12:30:29': [ 1, 30],
      '2017-04-03T12:30:30': [ 2,  0],
      '2017-05-03T12:30:29': [ 2, 29],
      '2017-05-03T12:30:30': [ 3,  0],
      '2017-06-03T12:30:29': [ 3, 30],
      '2017-06-03T12:30:30': [ 4,  0],
      '2017-07-03T12:30:29': [ 4, 29],
      '2017-07-03T12:30:30': [ 5,  0],
      '2017-08-03T12:30:29': [ 5, 30],
      '2017-08-03T12:30:30': [ 6,  0],
      '2017-09-03T12:30:29': [ 6, 30],
      '2017-09-03T12:30:30': [ 7,  0],
      '2017-10-03T12:30:29': [ 7, 29],
      '2017-10-03T12:30:30': [ 8,  0],
      '2017-11-03T12:30:29': [ 8, 30],
      '2017-11-03T12:30:30': [ 9,  0],
      '2017-12-03T12:30:29': [ 9, 29],
      '2017-12-03T12:30:30': [10,  0],
      '2018-01-03T12:30:29': [10, 30],
      '2018-01-03T12:30:30': [11,  0],
      '2018-02-03T12:30:29': [11, 30],
      '2018-02-03T12:30:30': [ 0,  0],
      '2018-03-03T12:30:29': [ 0, 27],
      '2018-03-03T12:30:30': [ 1,  0],
      '2018-04-03T12:30:29': [ 1, 30],

    for compare_date, expected of test_data
      diff = timer.diff_against(new Date(compare_date + 'Z'))
      diff.months.should.equal expected[0], compare_date
      diff.days.should.equal expected[1], compare_date

  it 'should calculate known date differences correctly', ->
    test_data = [
      ['1970-01-01T00:00:00', '2017-03-10T01:15:20', 47, 2, 9, 1, 15, 20, 17235]
    ]

    for data in test_data
      timer = new ValptidTimer(new Date(data[0]))
      diff = timer.diff_against(new Date(data[1]))
      diff.years.should.equal      data[2], "#{data[0]} to #{data[1]} years"
      diff.months.should.equal     data[3], "#{data[0]} to #{data[1]} months"
      diff.days.should.equal       data[4], "#{data[0]} to #{data[1]} days"
      diff.hours.should.equal      data[5], "#{data[0]} to #{data[1]} hours"
      diff.minutes.should.equal    data[6], "#{data[0]} to #{data[1]} minutes"
      diff.seconds.should.equal    data[7], "#{data[0]} to #{data[1]} seconds"
      diff.total_days.should.equal data[8], "#{data[0]} to #{data[1]} day total"
