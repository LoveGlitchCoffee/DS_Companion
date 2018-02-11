require "generalutils/gameutils"
require "generalutils/debugprint"
require "generalutils/table_ops"

---
-- Custom Behaviour for crafting items
-- @param inst Instance that will be building
-- @param item Item to craft
-- @class PerformBuild
PerformBuild = Class(BehaviourNode, function(self, inst, item)
   BehaviourNode._ctor(self, "PerformBuild")
   self.inst = inst
   self.item = item
end)

function PerformBuild:OnStop()
end

---
-- Check if can build item from what is available in inventory
-- @param recname name of item to get recipe for
-- @return if can build or not
function PerformBuild:CanBuild(recname)
   -- straight copy of CanBuild from builder component

   local recipe = GetRecipe(recname)
    if recipe then
        for ik, iv in pairs(recipe.ingredients) do
            local amt = math.max(1, RoundUp(iv.amount))
            if not self.inst.components.inventory:Has(iv.type, amt) then
                return false
            end
        end
        return true
    end

    return false
end

---
-- Remove ingredients from inventory when crafting item.
-- @param recname name for recipe of crafted item
function PerformBuild:RemoveIngredients(recname)
   -- straight copy of RemoveIngredients from builder component

    local recipe = GetRecipe(recname)
    self.inst:PushEvent("consumeingredients", {recipe = recipe})
    if recipe then
        for k, v in pairs(recipe.ingredients) do
            local amt = math.max(1, RoundUp(v.amount))
            self.inst.components.inventory:ConsumeByName(v.type, amt)
        end
    end
end

---
-- Copy from builder.DoBuild but decoupled from player.
-- No animation for it at the moment
-- @see components/builder.DoBuild
function PerformBuild:Visit()

   -- currently instantaneous

   if self.status == READY then
      self.inst.components.locomotor:Stop()
      local recipe = GetRecipe(self.item)
      -- local buffered = self:IsBuildBuffered(recname)
      if recipe and self:CanBuild(self.item) then
         self:RemoveIngredients(self.item)

         local prod = SpawnPrefab(recipe.product)
         if prod then
            if prod.components.inventoryitem then
               if self.inst.components.inventory then
                  --self.inst.components.inventory:GiveItem(prod)
                  self.inst:PushEvent("builditem", {item=prod, recipe = recipe})
                  if prod.components.equippable and not self.inst.components.inventory:GetEquippedItem(prod.components.equippable.equipslot) then
                     --The item is equippable. Equip it.
                     self.inst.components.inventory:Equip(prod)
             			if recipe.numtogive > 1 then
             				--Looks like the recipe gave more than one item! Spawn in the rest and give them to the player.
             				for i = 2, recipe.numtogive do
                				local addt_prod = SpawnPrefab(recipe.product)
                				self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
		   				   end
                     end
                  else
                     if recipe.numtogive > 1 and prod.components.stackable then
                        --The item is stackable. Just increase the stack size of the original item.
                        prod.components.stackable:SetStackSize(recipe.numtogive)
		   			   	self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
                     elseif recipe.numtogive > 1 and not prod.components.stackable then
                        --We still need to give the player the original product that was spawned, so do that.
		   			   	self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
		   			   	--Now spawn in the rest of the items and give them to the player.
		   			   	for i = 2, recipe.numtogive do
		   			   		local addt_prod = SpawnPrefab(recipe.product)
		   			   		self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
		   			   	end
                     else
                        --Only the original item is being received.
		   			   	self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
                     end
                  end

		   		--if self.onBuild then
		   		--	self.onBuild(self.inst, prod)
		   		--end
                  prod:OnBuilt(self.inst) -- leave here for now

                  self.status = SUCCESS
                  info('Built '..self.item)
                  printt(self.inst.components.inventory.itemslots)
               end
            else
               pt = pt or Point(self.inst.Transform:GetWorldPosition())
		   	   prod.Transform:SetPosition(pt.x,pt.y,pt.z)
                    self.inst:PushEvent("buildstructure", {item=prod, recipe = recipe})
                    prod:PushEvent("onbuilt")

		   	   --if self.onBuild then
		   	   --	self.onBuild(self.inst, prod)
		   	   --end
               prod:OnBuilt(self.inst)

               self.status = SUCCESS
            end
         end
      else
         info('Cannot find recipe for '..self.item..'or dont have resource for it')
         self.status = FAILED
      end
   end
end