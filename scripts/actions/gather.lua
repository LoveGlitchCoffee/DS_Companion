require 'actions/action'

Gather = Class(Action, function (self, inst, item)
		  self.item_to_gather = item
		  Action._ctor(self, inst, 'Gather')
end)

function Gather:Precondition()
   return {has_inv_spc=true} -- has space
end

function Gather:PostEffect()
   if self.item_to_gather == 'food' then
      return {have_food=true}
   end
   return {have=item} -- need to have something for increased invenctory space
end

function Gather:Cost()
   return 2
end
