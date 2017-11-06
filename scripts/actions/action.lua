Action = Class(function (self, inst, name)
      self.inst = inst
      self.name = name
end)

function Action:Precondition()
   print('error. This needs to be implemented')
end

function Action:PostEffect()
   print('error. This needs to be implemented')
end
