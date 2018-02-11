lu = require("luaunit")
require("generalutils/sets")

------------------------------------------------
-- 
-- Mocks, Stubs and other test related setups
-- 
------------------------------------------------



------------------------------------------------
-- 
-- Test Suite
-- 
------------------------------------------------

TestSets = {}


--- Test creating a set is mathematically correct
function TestSets:test_setcreation()
   local s = Set.new({a, b, a})
   lu.AssertEquals(s, {a, b})
end


--- Test that union works correctly
function TestSets:test_union()
   local sone = Set.new({a, b})
   local stwo = Set.new({b, c})

   lu.AssertEquals(sone + stwo, {a, b, c})
end


--- Test that union works correctly
function TestSets:test_union()
   local sone = Set.new({a, b})
   local stwo = Set.new({b, c})

   lu.AssertEquals(sone - stwo, {a, c})
end