lu = require("luaunit")
require("unittest/testcommon")
require("brains/utils")

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

TestBrainUtils = {}

function TestBrainUtils:test_goaltuple()
   local expectedtuple = {goalone, 1}
   lu.assertEquals(goaltuple(goalone, 1), expectedtuple)
end

--- Tests 'is_satisfykey' with normal cases.
-- Normal actions do not have 'seen_' or 'has_weapon'.
-- Test for cases with both true and false outputs, can have multiple states.
function TestBrainUtils:test_is_satisfykey_normal()
   lu.AssertTrue(is_satisfykey({c=true}, {c=true}))
   lu.AssertFalse(is_satisfykey({c=true}, {d=true}))

   lu.AssertTrue(is_satisfykey({c=true, d=true}, {c=true, d=true, e=true}))
   lu.AssertFalse(is_satisfykey({c=true, d=true}, {a=false}))
end


--- Tests 'is_satisfykey' where some posteffect satisfy some preconditions
function TestBrainUtils:test_is_satisfied_partial()
   lu.AssertTrue(is_satisfykey({c=true, b=true}, {c=true, a=true}))
end


---- Following cases cater for historical issues

--- Tests 'is_satisfykey' with 'seen' cases and is satisfied.
-- 'seen' cases are statements with 'seen_*' in them.
function TestBrainUtils:test_is_satisfykey_seentrue()
   lu.AssertTrue(is_satisfykey({seen_a=true, b=true}, {seen_a=true, seen_b=true}))
end


--- Tests 'is_satisfykey' with 'seen' cases with multiple seen in posteffect,
-- but only 1 satisfied seen in precondition
function TestBrainUtils:test_issatisfykey_seenmultipost()
   lu.AssertTrue(is_satisfykey({seen_a=true, seen_b=true}, {seen_a=true}))
end


--- Tests 'is_satisfykey' where invalid posteffect
-- Cases to test is empty posteffect.
function TestBrainUtils:test_is_satisfykey_invalid()
   lu.AssertFalse(is_satisfykey({}, {b=true}))
end


--- Tests 'is_satisfykey' with 'has_weapon' case.
-- 'has_weapon' case  also ends with build <item> so testing is thats skipped
function TestBrainUtils:test_is_satisfykey_hasweapon()
   lu.AssertTrue(is_satisfykey({has_weapon=true}, {has_weapon=true, b=true}))
end


--- Tests 'is_satisfystate' where states has bool values.
-- Sample bool values: 'has_weapon'=true
function TestBrainUtils:test_is_satisfystate_bool()
   lu.AssertTrue(is_satisfystate({a=true}, {a=true}))
   lu.AssertTrue(is_satisfystate({a=true, b=true}, {a=true, b=true}))
end


--- Tests 'is_satisfystate' where states has bool values not all state satisfied.
-- Sample bool values: 'has_weapon'=true
function TestBrainUtils:test_is_satisfystate_boolinvalid()
   lu.AssertFalse(is_satisfystate({a=true}, {a=true, b=true}))
end


--- Tests 'is_satisfystate' where states has number values.
-- Sample number values: cutgrass=2
function TestBrainUtils:test_is_satisfystate_number()
   lu.AssertTrue(is_satisfystate({itema=3, itemb=2}, {itema=3, itemb=2}))
end


--- Tests 'is_satisfystate' where states has number values but mismatch.
-- Sample number values: cutgrass=2
function TestBrainUtils:test_is_satisfystate_number()
   lu.AssertFalse(is_satisfystate({itema=1, itemb=2}, {itema=3, itemb=2}))
   lu.AssertFalse(is_satisfystate({itemb=2}, {itema=3, itemb=2}))
end


--- Tests 'is_satisfystate' where states has other values.
-- Sample values: cutgrass='hello'
function TestBrainUtils:test_is_satisfystate_other()
   lu.AssertTrue(is_satisfystate({a=b}, {a=b}))
   lu.AssertFalse(is_satisfystate({a=b}, {a=c}))
end