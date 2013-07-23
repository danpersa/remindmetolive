
class UserWeeklyReminders

  def initialize user, current_time
    @user = user
    @current_time = current_time
  end

  def reminders
    @user.ideas.select do |reminder|
       not reminder.reminder_date.nil? and reminder.reminder_date >= next_monday && reminder.reminder_date <= next_sunday
    end
  end

private
  def next_monday
    @current_time.advance(days: (8 - @current_time.wday))
  end

  def next_sunday
    next_monday.advance days: 6
  end
end