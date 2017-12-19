GOAPSequenceNode = Class(BehaviourNode, function(self, planfn)
    BehaviourNode._ctor(self, "Sequence")
    self.idx = 1
    self.planfn = planfn    
end)

function GOAPSequenceNode:DBString()
    return tostring(self.idx)
end

function GOAPSequenceNode:Reset()
    self._base.Reset(self)
    self.idx = 1
end

function GOAPSequenceNode:Visit()
    
    if self.status ~= RUNNING then
        self.idx = 1
    end
    
    local done = false
    local plan = self.planfn() -- generate plan
    while self.idx <= #plan do
    
        local child = plan[self.idx]
        child:Visit()
        if child.status == RUNNING or child.status == FAILED then
            self.status = child.status
            return
        end
        
        self.idx = self.idx + 1
    end 
    
    self.status = SUCCESS
end