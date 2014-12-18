require 'test_helper'

class UserTest < ActiveSupport::TestCase
   test "star_targets_hash" do
     User.destroy_all
     current_user = User.create email: 't@t.com', password: 'tttttttt'
     assert current_user.valid?
     assert current_user.targets.count == 2
     assert current_user.tasks.count == 2
     assert current_user.star_targets_hash.keys == [4, 0] # gtd(2) default(0), 1 five star, 1 one star
     t = current_user.targets.last
     t.tasks << current_user.tasks.first
     t.tasks << current_user.tasks.last
     t.save
     assert current_user.star_targets_hash.keys == [4] # gtd(2) default(2) all five(4+1) star
     task = current_user.targets.first.tasks.create description: 'test', user: User.last#, 
     assert current_user.star_targets_hash.keys == [4, 0] # gtd(3) default(2) all five(4+1) star
     Task.destroy_all
     assert current_user.star_targets_hash.keys == [] # gtd(0) default(0) no show
   end
end
