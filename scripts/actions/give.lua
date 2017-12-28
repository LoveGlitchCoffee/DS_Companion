require 'actions/action'

Give = Class(Action, function(self, inst, item)
   self.item = item
   Action._ctor(self, inst, 'Give '..item)
end)

function Give:Precondition()
   local pred = {}
   pred[self.item] = 1 -- goal always 1 (for now)
   return pred
end

function Give:PostEffect()
   local post = {}
   post['giving'] = self.item   
   return post
end

function Give:Cost()
   return 1
end