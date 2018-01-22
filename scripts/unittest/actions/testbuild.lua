lu = require("luaunit")
require("actions/build")

------------------------------------------------
-- 
-- Test Suite
-- 
------------------------------------------------

TestBuild = {}

--- Tests that Build precondition is that correct recipe
function TestBuild:test_preconditionrecipe()
   local b = Build(inst, 'heatrock')
   local pred = b:Precondition()
   lu.AssertEquals(pred, {rocks=10,pickaxe=1,flint=3})
end


--- Tests that post effect normall is the built item
function TestBuild:test_posteffect()
   local a = Build(inst, 'heatrock')
   local posteff = a:PostEffect()
   lu.AssertEquals(posteff, {heatrock=1})
end


--- Tests that post effect when item is weapon is 'has_weapon'=true
function TestBuild:test_posteffectweapon()
   local a = Build(inst, 'spear')
   local posteff = a:PostEffect()
   lu.AssertEquals(posteff, {spear=1, has_weapon=true})
end