require 'actions/action'
require 'general-utils/debugprint'
require 'general-utils/table_ops'
require("behaviours/performidle")

Idle = Class(Action, function (self, inst)   
   Action._ctor(self, inst, 'Idle')
end)

function Idle:Precondition()   
   return {}
end

function Idle:PostEffect()   
   return {idle=true} -- no state has this prcondition atm. could make the default state
end

function Idle:Cost()
   return 0
end

function Idle:Perform()
   return PerformIdle()
end