require "brains/qlearner"
require "generalutils/debugprint"

local QLearnerSave = Class(function(self, inst)
   self.inst = inst
end)

function QLearnerSave:OnSave()
   local data = {
      qmatrices = "hello"
   }

   return data
end

function QLearnerSave:OnLoad(data, newents)
   print("LOADING Q VALUES")
   if data.qmatrices then
      print(data.qmatrices)
   end
end

return QLearnerSave