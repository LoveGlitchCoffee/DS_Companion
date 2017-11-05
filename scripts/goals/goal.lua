Goal = Class(function(self, inst, name)
    -- constructor
    self.inst = inst
    self.name = name
    self.urgency = 0.1
end)

function Goal:__tostring()
   return string.format("Goal: %s", self.name)
end

function Goal:Satisfaction()
   print('error. This needs to be implemented')
end

function Goal:Urgency()
   return self.urgency
end
