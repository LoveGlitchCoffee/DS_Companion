require "brains/qlearner"

local QLearnerSave = Class(function(self, inst)
   self.inst = inst
end)

function QLearnerSave:OnSave()
   local data = {
      qmatrices = Q_MATRICES
   }

   return data
end

function QLearnerSave:OnLoad(data)   
   Q_MATRICES = data.qmatrices
end

return QLearnerSave