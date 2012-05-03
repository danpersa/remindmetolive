Given /^an? ([^"]*) exists with an? ([^"]*) of "([^"]*)"$/i do |factory_name, attribute_name, value|
  FactoryGirl.create(factory_name, attribute_name => value)
end