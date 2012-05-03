FactoryGirl.define do
  sequence :profile_name do |n|
    "profilename#{n}"
  end

  factory :profile do |profile|
    profile.name        { FactoryGirl.generate :profile_name }
    profile.email       "george.bush@yahoo.com"
    profile.location    "United States of America"
    profile.website     "http://www.bush.com"  
  end
end