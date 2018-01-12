PerformAttack = Class(BehaviourNode, function(self, inst, enemy)
   BehaviourNode._ctor(self, "PerformAttack")
   self.inst = inst
   self.enemytype = enemy
end)

function PerformAttack:Visit()
   if self.status == READY then
      local target = nil
      local pt = self.inst:GetPosition()
      local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 7)
      for k,entity in pairs(ents) do
         if entity.prefab = self.enemytype then
            target = entity
         end
      end
   
      if target then
         if self.inst.components.combat then
            self.inst.components.combat:SetTarget(target)
            self.status = RUNNING
         end
      else
         self.status = FAILED
      end
   elseif self.status == RUNNING then      
     
   end
end