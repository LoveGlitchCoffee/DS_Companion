require 'actions/action'
require 'general-utils/debugprint'
require 'general-utils/table_ops'

Attack = Class(Action, function (self, inst, enemy)
   self.enemy = enemy
   Action._ctor(self, inst, 'Attack ' .. enemy)   
end)

ENEMY_LOOT = {}
ENEMY_LOOT['pigman']={'meat', 'pigskin'}
ENEMY_LOOT['perd']={'drumstick'}
ENEMY_LOOT['frog']={'froglegs'}

function Attack:Precondition()
   local seenkey = ('seen_'..self.enemy)
   local pred = {}   
   pred[seenkey] = true
   pred['has_weapon'] = true
   return pred
end

function Attack:PostEffect()   
   local post = {}
   if ENEMY_LOOT[self.enemy] then      
      for i, v in ipairs(ENEMY_LOOT[self.enemy]) do
         local seenkey = ('seen_'..v)
         post[seenkey] = true
      end
   end
   
   return post   
end

function Attack:Cost()
   return 2
end

function Attack:Perform()   
   return ChaseAndAttack(self.inst, nil, nil, nil,    
   function ()
      local pt = self.inst:GetPosition()
      local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 7)
      for k,entity in pairs(ents) do
         if entity.prefab == self.enemy then
            return entity
         end
      end
   end
   , false)
end