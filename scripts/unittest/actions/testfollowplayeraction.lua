lu = require("luaunit")
require("actions/followplayeraction")

------------------------------------------------
-- 
-- Test Suite
-- 
------------------------------------------------

TestFollowPlayerAction = {}

--- Test that Perform() returns correct behaviour
function TestFollowPlayerAction:test_performchoice()   
   local follow = FollowPlayerAction(inst, player)
   local p = follow:Perform()
   lu.AssertEqual(p.name, 'WalkRandomly')

   player.Transform.x = 50
   player.Transform.y = 50
   -- dist from (0,0) and (50,50) should be > 36 and < 100
   p = follow:Perform()
   lu.AssertEqual(p.name, 'Follow')
   lu.AssertEqual(p.min_dist, 4)

   player.Transform.x = 121
   player.Transform.y = 121   
   p = follow:Perform()
   lu.AssertEqual(p.name, 'Follow')
   lu.AssertEqual(p.min_dist, 5)
end