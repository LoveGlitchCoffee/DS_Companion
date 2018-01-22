lu = require("luaunit")
require("unittest/testcommon")
require("brains/selectgoal")

------------------------------------------------
-- 
-- Mocks, Stubs and other test related setups
-- 
------------------------------------------------
   
local gwulistfn = function ()
   return {{name='goalone', goal=goalonetuple}, {name='goaltwo', goal=goaltwotuple}}
end

------------------------------------------------

TestSelectGoal = {}


--- Tests that 'getweightedgoals' calculates the correct weighting.
-- Correct weighting applies to each goal in the given goal_tuple list
function TestSelectGoal:test_getweightedgoals_weight()

   local goallist = {goalonetuple, goaltwotuple}
   local expectedres = {{goal=goalone, weighted_value=0.175}, {goal=goaltwo, weighted_value=0.25}}
   local res = get_weighted_goals(goallist)
   lu.assertEquals(actualres, expectedres)
end


--- Tests that 'getweightedgoals' give nil when input is invalid.
-- Input is invalid when its either nil,
-- or has length less than 1
function TestSelectGoal:test_getweightedgoals_nil()

   local goallist = nil
   local res = get_weighted_goals(goallist)
   lu.assertNil(res)

   local goalist = {}
   local res = get_weighted_goals(goallist)
   lu.assertNil(res)
end


--- Test 'maxgoal' gives correct output.
-- Correct output is the goal with highest 'weighted_value' as input.
function TestSelectGoal:test_maxgoal_normal()   

   local weightedgoallist = {{goal=goalone, weighted_value=0.5}, {goal=goaltwo, weighted_value = 0.3}}
   local expectedgoal = max_goal(weightedgoallist)
   lu.assertEquals(goalone, expectedgoal)
end


--- Test 'maxgoal' gives the first goal that has the highest weighting.
-- This occurs when two or more goals have the same weighting.
function TestSelectGoal:test_maxgoal_samevalue()

   local weightedgoallist = {{goal=goaltwo, weighted_value=0.5}, {goal=goalone, weighted_value = 0.5}}
   local expectedgoal = max_goal(weightedgoallist)
   lu.assertEquals(goaltwo, expectedgoal)
end


--- Test 'maxgoal' gives correct output if only 1 goal.
-- The expected behaviour is that the 1 goal is returned.
function TestSelectGoal:test_maxgoal_onegoal()

   local weightedgoallist = {{goal=goalone, weighted_value=0.5}}
   local expectedgoal = max_goal(weightedgoallist)
   lu.assertEquals(goalone, expectedgoal)
end


--- Test 'selectgoal' gives correct output under normal circumstances.
function TestSelectGoal:test_selectgoal_normal()
   
   local res = selectgoal(gwulistfn)
   lu.assertEquals(res, goaltwo)
end


--- Tests 'selectgoal' returns correct output if no list.
-- 'selectgoal' should return nil if the input function is nil
function TestSelectGoal:test_selectgoal_nogoals()
   
   local res = selectgoal(nil)
   lu.assertNil(res)
end

os.exit(lu.LuaUnit.run())