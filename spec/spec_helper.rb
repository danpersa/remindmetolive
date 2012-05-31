require 'rubygems'
require 'spork'

#require 'simplecov'
#SimpleCov.start 'rails'


# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

Spork.prefork do
  require File.expand_path('../../config/environment', __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join('spec/support/**/*.rb')].each {|f| require f}
end

Spork.each_run do
  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    # config.mock_with :mocha
    config.mock_with :rspec

    # keep our mongo DB all shiney and new between tests
    # require 'database_cleaner'

    config.before(:suite) do
    #   DatabaseCleaner.strategy = :truncation
    #   DatabaseCleaner.orm = "mongoid"
      #@session = Moped::Session.new([ 'localhost:27017' ])
      #@session.use 'remind_me_to_live_test'
    end

    config.before(:each) do
      Mongoid.purge!
      
      #@session['system.namespaces'].find(name: { '$not' => /system|\$/ }).to_a.map do |collection|
      #  _, name = collection['name'].split('.', 2)
      #  @session[name].drop
      #end

      #DatabaseCleaner.clean
      #User.delete_all
      #UserIdea.delete_all
      #Idea.delete_all
      #SocialEvent.delete_all
    end
    

	  def test_activate_user(user)
      if !user.activated?
        user.activate!
      end
    end
  
    def test_sign_in(user)
      test_activate_user(user)
      controller.sign_in(user)
    end
    
    def test_web_sign_in(user)
      test_activate_user(user)
      visit signin_path
      fill_in "Email",    :with => user.email
      fill_in "Password", :with => user.password
      click_button "Sign in"
      return user
    end
    
    def create_community_user
      community_user = User.create!(:name => "community", :email => "community@remindmetolive.com", :password => "thesercretpassword123")
      # we don't let anyone to sign in as the community user
      community_user.block!
    end
    
    def future_date
      Time.now.next_year.strftime("%d/%m/%Y")
    end
    
    def puts_validation_errors(model)
      if not model.valid?
        model.errors.full_messages.each do |error|
          puts error
        end
      end
    end

    def enable_social_event_notifications
      RemindMeToLive::Application.config.enable_social_event_notifications = true
    end

    def disable_social_event_notifications
      RemindMeToLive::Application.config.enable_social_event_notifications = false
    end
    
    def puts_backtrace(exception)
      exception.backtrace.join("\n")
    end
  end
end
