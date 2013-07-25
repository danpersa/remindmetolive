require 'mandrill'

desc "This task sends the weekly reminders"
task :send_weekly_reminders => :environment do
  puts 'Start send_weekly_reminders task...'
  # email = 'example@railstutorial.org'
  email = 'danix007ro@yahoo.com'
  user = User.find_by_email email
  if user.nil?
    puts "User with email '#{email}' not found..."
    next
  end
  puts "Found user #{user.display_name}"
  reminders = UserWeeklyReminders.new(user, DateTime.now.utc.midnight).reminders

  content = ''
  reminders.each do |reminder|
    puts "Add reminder for date #{reminder.reminder_date.to_s}..."
    content << "<li>#{reminder.idea.content} on #{reminder.reminder_date.to_s}</li>"
  end

  puts 'Start sending the mail...'
  send_mail content
  
  puts 'Done...'
end

def send_mail content
  m = Mandrill::API.new 'XkJNeyUp9PxKFPi9qraQDg' # All official Mandrill API clients will automatically pull your API key from the environment
  # rendered = m.templates.render 'daily-reminders', [
  #   {:name => 'display_name', :content => 'Danix'},
  #   {:name => 'reminders', :content => '<li>Remind me to live</li><li>Remind me to  play the piano</li>'}]
  # @mail_template = rendered['html'] # print out the rendered HTML

  m.messages.send_template 'daily-reminders', [
    {:name => 'display_name', :content => 'Danix'},
    {:name => 'reminders', :content => content}],
    {
      html: "<p>Example HTML content</p>",
      text: "Example text content",
      subject: "You want to be reminded of something",
      from_email: "reminders@remindmetolive.com",
      from_name: "Remind Me To Live",
      to: [
          {
              email: "dan.persa@gmail.com",
              name: "Dan Persa"
          }
      ]
  }
end