require "actions/action"
require "generalutils/debugprint"
require "generalutils/table_ops"
require "generalutils/gameutils"
require "generalutils/config"

--- a table containing enemy loot drops
ENEMY_LOOT = {}
ENEMY_LOOT['pigman']={'meat', 'pigskin'}
ENEMY_LOOT['perd']={'drumstick'}
ENEMY_LOOT['frog']={'froglegs'}
ENEMY_LOOT['spider']={'silk', 'spidergland', 'monstermeat'}

--- 
-- STRIPS action for attacking an enemy
-- @param  inst Instance performing the attack
-- @param enemy Enemy to attack, as a prefab name
-- @class Attack
Attack = Class(Action, function (self, inst, enemy)
   self.enemy = enemy
   Action._ctor(self, inst, 'Attack ' .. enemy, "CANNOT LOCATE PREY")
end)

--- 
-- STRIPS precondition for attacking
-- Must have:
-- 1. Seen enemy
-- 2. Has a weapon
-- @return preconditions as table
function Attack:Precondition()
   local seenkey = ('seen_'..self.enemy)
   local pred = {}
   pred[seenkey] = true
   pred['has_weapon'] = true
   return pred
end

--- 
-- Effect after finish attacking and sucessfully kill.
-- Will see enemy loot as defined in table ENEMY_LOOT.
-- @return effect post attack as table
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

--- 
-- Preceived cost of attacking enemy.
-- Cost of attacking enemy depends on how many other enemies are around.
-- If cannot see enemy of prefab type, then 0 danger because it will likely fail
-- @return the 'danger level'
-- @see generalutils/gameutils.CheckDangerLevel
function Attack:PreceivedCost()
   local centrept = GetClosestInstOf(self.enemy, self.inst, ASSUME_DANGER_DIST)
   if centrept then
      return CheckDangerLevel(centrept)
   end
   return 0
end

---
-- Perform attack uses the DS ChaseAndAttack() Behaviour.
-- Target is closest instance of enemy prefab
-- @return ChaseAndAttack() Behaviour to attack closest instance with enemy prefab
-- @see generalutils/gameutils.GetClosesInstOf
function Attack:Perform()      
   return ChaseAndAttack(self.inst, nil, nil, nil,
   function ()
      return GetClosestInstOf(self.enemy, self.inst, 7)      
   end,   
   false)
end