PerformEat = Class(BehaviourNode, function(self, inst)
   BehaviourNode._ctor(self, "PerformEat")
   self.inst = inst
end)

function PerformEat:Visit()
   if self.status == READY then
      local allFoodInInventory = self.inst.components.inventory:FindItems(function(item) return 
         self.inst.components.eater:CanEat(item) and 
         item.components.edible:GetHunger(self.inst) > 0 and
         item.components.edible:GetHealth(self.inst) >= 0 and
         item.components.edible:GetSanity(self.inst) >= 0 
      end)
      self.status = SUCCESS -- maybe change eating to something else so      
   end
end