Action = Class(function (self, inst, name)
      self.inst = inst
      self.name = name
end)

function Action:Precondition()
   print('error. Precondition() needs to be implemented')
end

function Action:PostEffect()
   print('error. PostEffect() needs to be implemented')   
end

function Action:Cost()
   print('error. Cost() needs to be implemented')   
end

function Action:Perform()
   print('error. Perform() needs to be implemented')
end

function Action:__eq(b)
   return self.name == b.name -- for now
end

function Action:__tostring()
   return string.format('Action %s', self.name)
end
