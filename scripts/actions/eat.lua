require 'actions/action'
require 'behaviours/performeat'

Eat = Class(Action, function (self, inst)
	       Action._ctor(self, inst, 'Eat')
end)

function Eat:Precondition()
   return {have_food=true} -- has space
end

function Eat:PostEffect()
   return {eaten=true}
end

function Eat:Cost()
   return 1
end

function Eat:Perform()
   return PerformEat(self.inst)
end