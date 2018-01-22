lu = require("luaunit")
require("actions/attack")

------------------------------------------------
-- 
-- Test Suite
-- 
------------------------------------------------

TestAttack = {}

--- Test that posteffect of 'Attack' gives correct loot
-- 
function TestAttack:test_posteffectloot()
   local a = Attack(inst, 'pigman')
   local posteff = a:PostEffect()
   lu.AssertEquals(posteff, {'seen_meat', 'seen_pigskin'})
end