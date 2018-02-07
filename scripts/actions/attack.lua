require 'actions/action'
require 'general-utils/debugprint'
require 'general-utils/table_ops'
require("general-utils/gameutils")
require("general-utils/config")

Attack = Class(Action, function (self, inst, enemy)
   self.enemy = enemy
   Action._ctor(self, inst, 'Attack ' .. enemy, "CANNOT LOCATE PREY")
end)

ENEMY_LOOT = {}
ENEMY_LOOT['pigman']={'meat', 'pigskin'}
ENEMY_LOOT['perd']={'drumstick'}
ENEMY_LOOT['frog']={'froglegs'}
ENEMY_LOOT['spider']={'silk', 'spidergland', 'monstermeat'}

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
   local centrept = GetClosestInstOf(self.enemy, self.inst, ASSUME_DANGER_DIST)
   if centrept then
      return CheckDangerLevel(centrept)
   end
   return 0
end

function Attack:Perform()      
   return ChaseAndAttack(self.inst, nil, nil, nil,
   function ()
      return GetClosestInstOf(self.enemy, self.inst, 7)      
   end,   
   false)
end