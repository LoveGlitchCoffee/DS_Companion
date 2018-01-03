require 'actions/action'
require("general-utils/table_ops")
require("behaviours/performgive")

Give = Class(Action, function(self, inst, item, target)   
   Action._ctor(self, inst, 'Give '..item)
   self.item = item
   self.target = target -- usually player
end)

function Give:Precondition()
   local pred = {}
   pred[self.item] = 1 -- goal always 1 (for now)
   return pred
end

function Give:PostEffect()
   local post = {}
   local key = 'gave_'..self.item
   post[key] = true
   return post
end

function Give:Cost()
   return 1
end

function Give:Perform()   
   return PerformGive(self.inst, self.item, self.target)
end