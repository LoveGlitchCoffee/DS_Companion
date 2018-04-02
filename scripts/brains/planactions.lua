require "brains/goapplanner"

require "actions/gather"
require "actions/gatherfood"
require "actions/build"
require "actions/searchfor"
require "actions/searchforresource"
require "actions/eat"
require "actions/give"
require "actions/followplayeraction"
require "actions/givefood"
require "actions/attack"
require "actions/fishing"
require "actions/stayput"

require "goals/keepplayerfull"

require "generalutils/table_ops"
require "generalutils/debugprint"
require "generalutils/config"

ALL_ACTIONS = nil

---
-- populate ALL_ACTIONS with all the STRIPS actions character can take (in the mod)
-- @param inst instance of the character
function populate_actions(inst)
   local player = GetPlayer()
   ALL_ACTIONS = {
      -- need Give (food) as well if want command
      FollowPlayerAction(inst, player),
      StayPut(inst),
      Gather(inst, "twigs"),
      Gather(inst, "cutgrass"),
      -- Gather(inst, "carrot"),
      Gather(inst, "flint"),
      Gather(inst, "silk"),
      Gather(inst, "seeds"),
      Gather(inst, "log"),
      Gather(inst, "rocks"),
      Gather(inst, "goldnugget"),
      GatherFood(inst, "carrot"), -- special case
      GatherFood(inst, "berries"),
      GatherFood(inst, "meat"),
      GatherFood(inst, "froglegs"),
      GatherFood(inst, "fish"),
      Give(inst, "twigs", player),
      Give(inst, "cutgrass", player),
      Give(inst, "flint", player),
      Give(inst, "silk", player),
      Give(inst, "seeds", player),
      Give(inst, "carrot", player),
      Give(inst, "log", player),
      Give(inst, "rocks", player),
      Give(inst, "goldnugget", player),
      GiveFood(inst, "carrot", player),
      GiveFood(inst, "berries", player),
      GiveFood(inst, "meat", player),
      GiveFood(inst, "froglegs", player),
      GiveFood(inst, "fish", player),
      SearchForResource(inst, "twigs"),
      SearchForResource(inst, "cutgrass"),
      SearchForResource(inst, "carrot"),
      SearchForResource(inst, "berries"),
      SearchFor(inst, "seeds"),
      SearchFor(inst, "pigman"),
      SearchFor(inst, "frog"),
      --SearchFor(inst, "meat"),
      SearchFor(inst, "flint"),
      SearchFor(inst, "silk"),
      SearchFor(inst, "spider"),
      SearchFor(inst, "pond"),
      SearchFor(inst, "log"),
      SearchFor(inst, "rocks"),
      SearchFor(inst, "goldnugget"),
      -- SearchFor(inst, 'berries'), -- if on ground, may need to merge
      -- SearchFor(inst, 'carrot'),
      Build(inst, "trap"),
      Build(inst, "rope"),
      Build(inst, "spear"),
      Build(inst, "fishingrod"),
      Attack(inst, "pigman"),
      Attack(inst, "frog"),
      Fishing(inst),
      Attack(inst, "spider")
      --Eat(inst)
   }
end

---
-- modify the world state to account for inventory.
-- basically generates whats in inventory and whether have weapon.
-- handles generating correct value for number of items in inventory, even accounting for stacks
-- @param inventory inventory component
-- @param state the world state to modify
function generate_inv_state(inventory, state)
   if not inventory:IsFull() then
      state["has_inv_spc"] = true
   end

   -- info('inventory item number start over ' .. tostring(inventory:GetNumSlots()))

   for i = 1, inventory:GetNumSlots() do
      local item = inventory:GetItemInSlot(i)
      if item then
         info(tostring(item))
         if state[item.prefab] then
            -- handle different stack but already accounted for
            info("item exist in state")
            if item.components.stackable then
               -- is a stack
               -- total stack size, not restricted by in-game
               state[item.prefab] = state[item.prefab] + item.components.stackable.stacksize
            else
               -- no stack
               state[item.prefab] = state[item.prefab] + 1
            end
         else
            -- handle new stack
            if item.components.stackable then
               -- is a stack
               state[item.prefab] = item.components.stackable.stacksize
            else
               -- no stack
               state[item.prefab] = 1
            end
         end
         if has_v(item.prefab, WEAPONS) then
            state["has_weapon"] = true -- but not equipped
         end
      --local has_key = 'has' .. tostring(item.prefab)
      end
   end

   for k, v in pairs(inventory.equipslots) do
      if has_v(v.prefab, WEAPONS) then
         state["has_weapon"] = true
      else
         state[v.prefab] = 1 -- should do normal adding, not in scope
      end
   end
end


---
-- modify world state to account for items in view.
-- for resources that are gatherable, see them as the resource instead
-- accounts for items that are not interactable (LIMBO)
-- @param inventory inventory component
-- @param state the world state to modify
-- @param inst the companion instance which will be centre point to viewing
function generate_items_in_view(inventory, state, inst)
   -- centre point is companion's position
   local pos = inst:GetPosition()

   local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, SIGHT_DISTANCE) -- make distance config
   for k, entity in pairs(ents) do
      if entity then
         -- don't see itself
         if entity ~= inst then
            info("see " .. tostring(entity))
            local entityname = entity.prefab

            -- handle resource
            if entity.components.pickable and entity.components.pickable:CanBePicked() then
               entityname = entity.components.pickable.product -- so gather works
            end

            -- handle inventory item
            if entity.inlimbo then
               info("item is part of inventory")
            else
               if entityname == nil or entityname == '' then
                  error("WHAT THE FUK")
               else
                  local seenkey = ("seen_" .. entityname)
                  state[seenkey] = true
                  info(seenkey)                  
               end
            end
         end
      end
   end
end

---
-- generate the world state for planning
-- @param inst instance of character
-- @return the world state
function generate_world_state(inst)
   local state = {}
   local inventory = inst.components.inventory
   generate_inv_state(inventory, state)
   generate_items_in_view(inventory, state, inst)
   return state
end

---
-- plan a sequence of actions to be performed to reach the goal
-- @param inst instance of character to do the planning
-- @param goal goal to reach through planning
-- @return action plan
-- @see brains/goapplanner.goap_backward_plan_action
function planactions(inst, goal)
   local world_state = generate_world_state(inst)
   info(".\n")
   info("world state: ")
   --printt(world_state)
   info(".\n")
   local action_sequence = goap_backward_plan_action(world_state, goal, ALL_ACTIONS)
   if #action_sequence > 0 then
      --error('succeed')
      return action_sequence
   end
   error("Failed, no plan produced")
   return nil
end
