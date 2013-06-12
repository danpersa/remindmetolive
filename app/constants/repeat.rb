class Repeat
  Values = {
    every_day: 0,
    every_week: 1,
    every_month: 2,
    every_season: 3,
    every_year: 4
  }
  Weekdays = {
    sunday: 0,
    monday: 1,
    tuesday: 2,
    wendesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6
  }
  Seasons = {
    spring: 0,
    summer: 1,
    autumn: 2,
    winter: 3
  }
  
  Subvalues = {
    Values[:every_day] => {

    },
    Values[:every_week] => {
      Weekdays[:sunday] => :sunday,
      Weekdays[:monday] => :monday,
      Weekdays[:tuesday] => :tuesdaytuesday,
      Weekdays[:wendesday] => :wendesday,
      Weekdays[:thursday] => :thursday,
      Weekdays[:friday] => :friday,
      Weekdays[:saturday] => :saturday,
    },
    Values[:every_month] => {

    },
    Values[:every_season] => {
      Seasons[:spring] => 0,
      Seasons[:summer] => 1,
      Seasons[:autumn] => 2,
      Seasons[:winter] => 3,
    },
    Values[:every_year] => {
    }
  }

end