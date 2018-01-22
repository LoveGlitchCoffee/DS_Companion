lu = require("luaunit")
require("general-utils/table_ops")

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

TestTableOps = {}


--- Test has_v operates correctly
function TestTableOps:test_hasv()
   local list = {'a', 'b', 'c'}
   local value = 'a'
   local wrongvalue = 'd'

   lu.AssertTrue(value, list)
   lu.AssertFalse(wrongvalue, list)
end


--- Test tablesize gives correct size for table
function TestTableOps:test_tablesize()
   local list = {'a', 'b', 'c'}
   lu.AssertEquals(tablesize(list), 3)

   local listzero = {}
   lu.AssertEquals(tablesize(listzero), 0)
end