
class NextReminder

  attr_reader :date

  def initialize date
    @date = date
  end

  def self.from current_time, repeat, reminder_on = nil
    unless repeat.nil?
      repeat = repeat.to_i
    else
      repeat = 0
    end
    next_reminder = nil
    case repeat
      when Repeat::Values[:never]
        unless reminder_on.nil?
          next_reminder = NextReminder.new DateTime.strptime(reminder_on, '%m/%d/%Y')
        else
          next_reminder = NextReminder.new nil
        end
      when Repeat::Values[:every_day]
        next_reminder = NextReminder.new current_time.tomorrow.to_date
      when Repeat::Values[:every_week]
        reminder_on = reminder_on.to_i
        if current_time.wday >= reminder_on
          next_reminder = NextReminder.new current_time.next_week
                              .advance(days: reminder_on - 1).to_date
        else
          next_reminder = NextReminder.new current_time
                              .advance(days: (reminder_on - current_time.wday))
        end
      when Repeat::Values[:every_month]
        reminder_on = reminder_on.to_i
        if current_time.mday >= reminder_on
          next_reminder = NextReminder.new current_time.next_month
                                      .advance(days: (reminder_on - current_time.mday))
        else
          next_reminder = NextReminder.new current_time
                              .advance(days: (reminder_on - current_time.mday))
        end
      when Repeat::Values[:every_season]
        reminder_on = reminder_on.to_i
        if season_has_passed? current_time, reminder_on
          next_reminder = NextReminder.new first_day_of(reminder_on, current_time.year + 1)
        else
          next_reminder = NextReminder.new first_day_of(reminder_on, current_time.year)
        end  
      when Repeat::Values[:every_year]
       month_and_day = reminder_on.split '/'
       month = month_and_day[0].to_i
       day = month_and_day[1].to_i
       this_year_date = DateTime.new current_time.year, month, day
       if current_time >= this_year_date
          next_reminder = NextReminder.new this_year_date.next_year
        else
          next_reminder = NextReminder.new this_year_date
        end
      else
        raise 'An error has occured'  
    end
    return next_reminder
  end

  private

  def self.season current_time
    current_month = current_time.month
    if current_month == 12 or current_month == 1 or current_month == 2
      return Repeat::Seasons[:winter]
    elsif current_month == 3 or current_month == 4 or current_month == 5
      return Repeat::Seasons[:spring]
    elsif current_month == 6 or current_month == 7 or current_month == 8
      return Repeat::Seasons[:summer]
    elsif current_month == 9 or current_month == 10 or current_month == 11
      return Repeat::Seasons[:autumn]
    end
  end

  def self.season_has_passed? current_time, the_season
    current_month = current_time.month
    current_season = season current_time
    if the_season == Repeat::Seasons[:winter] and current_month < 12
      return false
    end
    if current_month < 3
      return false
    end
    return current_season >= the_season
  end

  def self.first_day_of season, year
    case season
      when Repeat::Seasons[:spring]
        DateTime.new year, 3, 1
      when Repeat::Seasons[:summer]
        DateTime.new year, 6, 1
      when Repeat::Seasons[:autumn]
        DateTime.new year, 9, 1
      when Repeat::Seasons[:winter]
        DateTime.new year, 12, 1
      else
        raise 'An error has occured'
    end
  end
end
