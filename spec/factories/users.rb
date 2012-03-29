FactoryGirl.define do

  sequence :username do |n|
    "username#{n}"
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user do |user|
    user.username              'Michael Hartl'
    user.email                 'mhartl@example.com'
    user.password              'foobar'
    user.password_confirmation 'foobar'
    user.activation_code       '1234567890'
    user.state                 'pending'
    user.profile { FactoryGirl.build(:profile) }
    user.ideas { [FactoryGirl.build(:user_idea), FactoryGirl.build(:second_user_idea)] }
    user.followers {
      [FactoryGirl.build(:unique_user), FactoryGirl.build(:unique_user)]
    }
    user.following {
      [FactoryGirl.build(:unique_user), FactoryGirl.build(:unique_user)]
    }
    user.idea_lists {
      [FactoryGirl.build(:idea_list), FactoryGirl.build(:idea_list)]
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

    user.username               { FactoryGirl.generate :username }
    user.email                  { FactoryGirl.generate :email }

    user.password              'foobar'
    user.password_confirmation 'foobar'
    user.activation_code       '1234567890'
    user.state                 'pending'
    user.profile { FactoryGirl.build(:profile) }
    #user.ideas { [FactoryGirl.build(:user_idea), FactoryGirl.build(:second_user_idea)] }
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


