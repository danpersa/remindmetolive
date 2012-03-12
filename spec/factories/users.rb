Factory.sequence(:username)    {|n| "username#{n}" }
Factory.sequence(:email)       {|n| "person#{n}@example.com" }

FactoryGirl.define do

  factory :user do |user|
    user.username              'Michael Hartl'
    user.email                 'mhartl@example.com'
    user.password              'foobar'
    user.password_confirmation 'foobar'
    user.activation_code       '1234567890'
    user.state                 'pending'
    user.profile { Factory.build(:profile) }
    user.ideas { [Factory.build(:user_idea), Factory.build(:second_user_idea)] }
    user.followers {
      [Factory.build(:unique_user), Factory.build(:unique_user)]
    }
    user.following {
      [Factory.build(:unique_user), Factory.build(:unique_user)]
    }
    user.idea_lists {
      [Factory.build(:idea_list), Factory.build(:idea_list)]
    }
  end

  factory :simple_user, :class => User do |user|
    user.username              'Michael Jackson'
    user.email                 'michael@example.com'
    user.password              'foobar'
    user.password_confirmation 'foobar'
    user.activation_code       '1234567890'
    user.state                 'active'
    user.activated_at          Time.now.utc
  end

  factory :unique_user, :class => User do |user|

    user.username               { Factory.next :username }
    user.email                  { Factory.next :email }

    user.password              'foobar'
    user.password_confirmation 'foobar'
    user.activation_code       '1234567890'
    user.state                 'pending'
    user.profile { Factory.build(:profile) }
    #user.ideas { [Factory.build(:user_idea), Factory.build(:second_user_idea)] }
  end

  factory :activated_user, :class => User  do |user|
    user.username              'Michael Jordan'
    user.email                 'jordan.activated@example.com'
    user.password              'foobar'
    user.password_confirmation 'foobar'
    user.state                 'active'
    user.activated_at          Time.now.utc
  end

  factory :pending_user, :class => User  do |user|
    user.username              'Michael Pending'
    user.email                 'jordan.pending@example.com'
    user.password              'foobar'
    user.password_confirmation 'foobar'
    user.state                 'pending'
    user.activation_code       '1234567890'
  end
end


