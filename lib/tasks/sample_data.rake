require 'faker'
# require 'mongo'

namespace :db do
  desc "Fill database with sample data "
  task :populate => :environment do
    RemindMeToLive::Application.config.action_mailer.delivery_method = :test
    RemindMeToLive::Application.config.action_mailer.logger = nil
    Mongoid.logger.level = Logger::INFO
    Moped.logger.level = Logger::INFO

    print ::Rails.env
    Mongoid.purge!
    beginning_time = Time.now

    #conn = Mongo::Connection.new
    #db   = conn['remind_me_to_live_development']
    #indexes = db['system.indexes']

    #indexes.insert([{:name=>"created_at_1", :ns=>"remind_me_to_live_development.social_events", :key=>{"created_at"=>1}, :unique=>false}])
    #indexes.insert([{:name=>"created_by_id_1", :ns=>"remind_me_to_live_development.social_events", :key=>{"created_by_id"=>1}, :unique=>false}])
    #indexes.insert([{:name=>"user_ids_1", :ns=>"remind_me_to_live_development.social_events", :key=>{"user_ids"=>1}, :unique=>false}])

    #indexes.insert([{:name=>"username_1", :ns=>"remind_me_to_live_development.users", :key=>{"username"=>1}, :unique=>true}])
    #indexes.insert([{:name=>"email_1", :ns=>"remind_me_to_live_development.users", :key=>{"email"=>1}, :unique=>true}])
    #indexes.insert([{:name=>"salt_1", :ns=>"remind_me_to_live_development.users", :key=>{"salt"=>1}, :unique=>false}])

    admin = make_users
    make_ideas(admin)
    #Rake::Task['db:mongoid:create_indexes'].invoke
    make_relationships(admin)
    make_idea_lists(admin)
    end_time = Time.now
    debug "Time elapsed #{(end_time - beginning_time)} seconds"
    puts
  end
end

def debug message
  puts
  print message
  Rails.logger.info message
end

def make_users
  debug "make users: "
  admin = User.create!(:username => "ExampleUser",
                       :email => "example@railstutorial.org",
                       :password => "foobar",
                       :password_confirmation => "foobar")
  admin.admin = true
  print "."
  admin.save!
  admin.activate!
  print "."
  49.times do |n|
    print "."
    username = Faker::Name.name[0, 25]
    email = "example-#{n+1}@railstutorial.org"
    password = "password"
    user = User.create!(:username => username,
                        :email => email,
                        :password => password,
                        :password_confirmation => password)
    user.activate!
  end
  return admin
end

def make_ideas(admin)
  debug "make ideas: "
  first_user = admin
  first_user.create_new_idea!(:content => "go to school", :privacy => Privacy::Values[:public], :reminder_date => Time.now.next_year)
  reminder_date = Time.now.next_year
  print "."
  User.all.each do |user|
    print "."
    if user.id == 1
      next
    end
    10.times do
      content = Faker::Lorem.sentence(5).downcase.chomp(".")
      idea = user.create_new_idea!(:content => content, :privacy => Privacy::Values[:public], :reminder_date => reminder_date)
    end
  end
end

def make_relationships(admin)
  debug "make relationships: "
  users = User.all.limit 10
  user = admin
  following = users[3..10]
  followers = users[3..5]
  debug "    admin follows other users: "
  following.each { |followed| user.follow!(followed); print "."; }
  debug "    other users follow admin: "
  followers.each { |follower| follower.follow!(user); print "." }
  other_user = users[4]
  debug "    another user follow some users: "
  followers.each { |follower| follower.follow!(other_user); print "." }
  debug "    some users follow another user: "
  following.each { |followed| other_user.follow!(followed); print "." }
end


def make_idea_lists(admin)
  debug "make idea lists: "
  (0..5).each do
    print "."
    idea_list = admin.create_idea_list Faker::Lorem.sentence(2).downcase.chomp(".")[0, 30]
    debug "zero"
    number_of_ideas = Idea.count
    (0..5).entries.each do |idea|
      debug "unu"
      random = Random.rand(number_of_ideas)
      debug "doi"
      idea = Idea.all.skip(random).first
      debug "trei"
      idea_list.add_idea_as idea, Privacy::Values[:public]
      debug "patru"
    end
    debug "cinci"
  end
end