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

--- Tests 'is_satisfypred' with normal cases.
-- Normal actions do not have 'seen_' or 'has_weapon'.
-- Test for cases with only 1 in set, 2> in set and both true and false outputs.
function TestBrainUtils:test_is_satisfypred_normal()
   lu.AssertTrue(is_satisfypred({c=true}, {c=true}))
   lu.AssertFalse(is_satisfypred({c=true}, {d=true}))
   lu.AssertTrue(is_satisfypred({c=true, d=true}, {c=true, d=true, e=true}))
   lu.AssertFalse(is_satisfypred({c=true, d=true}, {a=false}))
end

-- should also test for case where only some statement in pred satisfy some in post


--- Tests 'is_satisfypred' with 'seen' cases and is satisfied.
-- 'seen' cases are statements with 'seen_*' in them.
function TestBrainUtils:test_is_satisfypred_seentrue()
   lu.AssertTrue(is_satisfypred({seen_a=true}, {seen_a=true, seen_b=true}))
end

--- Tests 'is_satisfypred' with 'seen' cases and not satisfied.
-- Cases to test include invalid and empty posteffect.
function TestBrainUtils:test_is_satisfypred_seeninvalid( ... )
   lu.AssertFalse(is_satisfypred({seen_a=true}, {seen_b=true}))
end

--- Tests 'is_satisfypred' with 'seen' cases with multiple seen in posteffect,
-- but only 1 satisfied seen in precondition
function TestBrainUtils:test_issatisfypred_seenmultipost( ... )
   
end

--- Tests 'is_satisfypred' with 'seen' cases with multiple seen in both
-- desired precondition and posteffect, all satisfied.


--- Tests 'is_satisfypred' with 'seen' cases with multiple seen in both
-- desired precondition and posteffect, none satisfied.


--- Tests 'is_satisfypred' with 'seen' cases with multiple seen in precondition,
-- but only 1 satisfied with posteffect.


--- Tests 'is_satisfypred' with 'has_weapon' case.
-- 'has_weapon' case  also ends with build <item> so testing is thats skipped
