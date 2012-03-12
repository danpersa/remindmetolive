## 0.3.7
 * added user ideas controller and views
 * fixed homepage form
 
## 0.3.6
 * fixed the tests for the model

## 0.3.5
 * UserIdea will not be embedded anymore

## 0.3.4
 * using edge-captcha and edge-auth

## 0.3.3
 * using edge-layouts for layouts
 * fixed lots of tests
 * added tests for users controller, ideas controller and profile controller
 * fixed reset an change passwords

## 0.3.2
 * removed pagination for idea lists
 * change password
 * settings screen
 * public profile screen

## 0.3.1
 * pagination for idea lists show and index

## 0.3.0
* specs for idea lists controller

## 0.2.9
 * centered-supersized-form-div instead of signin and new user forms
 * list of ideas form
 * fixed singin and signup forms
 * idea_list.ideas_count
 * user.idea_lists_count
 * removed Idea.create_idea_for! in order to prepare the next two steps

## 0.2.8
 * fixed test

## 0.2.7
 * update to rails 3.2
 * idea lists page
 * remove idea from list
 * added SimpleCov
 * tests for idea list model


## TODO
 * should store the date of the social event, so it can calculate suggestions later
 * CRUD with AJAX for IdeaLists
 * user.created_ideas
 * user.created_ideas_count
 * user.inspired_ideas_count
 * idea.users_having_this_idea
 * idea.users_having_this_idea_count


query
{"created_at": {"$gte": ISODate("2012-01-15T00:00:00Z"), "$lt": ISODate("2012-01-16T00:00:00Z")},"created_by_id":  ObjectId('4f134b5773d98767ee000005'),"user_ids": {"$in": [ ObjectId('4f134b5873d98767ee000009')]}, "_type": {"$in": ["FollowingUserSocialEvent"]}}
