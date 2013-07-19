
class UserWeeklyReminders

  def initialize user, current_time
    @user = user
    @current_time = current_time
  end

  def reminders
    @user.ideas
  end

private
  def next_monday
    @current_time.advance(days: (reminder_on - current_time.wday))
  end

  def next_sunday
  end
end