require("general-utils/debugprint")

GOAPPriorityNode = Class(BehaviourNode, function(self, planfn, period)
    BehaviourNode._ctor(self, "GOAPPriority") 
    self.period = period or 1
    self.planfn = planfn
end)

function GOAPPriorityNode:GetSleepTime()
    if self.status == RUNNING then
        error('SLEEPING')
        if not self.period then
            return 0
        end
        
        
        local time_to = 0
        if self.lasttime then
            time_to = self.lasttime + self.period - GetTime()
            if time_to < 0 then
                time_to = 0
            end
        end
    
        return time_to
    elseif self.status == READY then        
        return 0
    end
    
    return nil
    
end


function GOAPPriorityNode:DBString()
    local time_till = 0
    if self.period then
       time_till = (self.lasttime or 0) + self.period - GetTime()
    end
    
    return string.format("execute %d, eval in %2.2f", self.idx or -1, time_till)
end


function GOAPPriorityNode:Reset()
    self._base.Reset(self)
    self.idx = nil
end

function GOAPPriorityNode:Visit()
    error('current status: '..tostring(self.status))    
    local time = GetTime()
    local do_eval = not self.lasttime or not self.period or self.lasttime + self.period < time 
    local oldidx = self.idx
    error('do_eval '..tostring(do_eval))

    local plan = self.planfn()
    if do_eval then
        
        local old_event = nil
        if self.idx and plan[self.idx]:is_a(EventNode) then
            old_event = plan[self.idx]
        end
        
        self.lasttime = time
        
        local found = false
        for idx, child in ipairs(plan) do
        
            local should_test_anyway = old_event and child:is_a(EventNode) and old_event.priority <= child.priority
            if not found or should_test_anyway then
                error ('should test bheaviour anyway: '..tostring(child.name))
                if child.status == FAILED or child.status == SUCCESS then
                    error('FINISH BEHAVIOUR')
                    child:Reset()
                end
                error('visiting child')
                child:Visit()
                local cs = child.status
                if cs == SUCCESS or cs == RUNNING then
                    if should_test_anyway and self.idx ~= idx then
                        error('reset current behaviour: '..plan[self.idx].name)
                        plan[self.idx]:Reset()
                    end
                    error('behaviour running: '..tostring(child.name))
                    self.status = cs
                    found = true
                    self.idx = idx
                end
            else
                error('skip behaviour: '..tostring(child.name))
                child:Reset()
            end
        end
        if not found then
            self.status = FAILED
        end
        
    else        
        if self.idx then
            local child = plan[self.idx]
            if child.status == RUNNING then
                child:Visit()
                self.status = child.status
                if self.status ~= RUNNING then
                    self.lasttime = nil
                end
            end
        end
    end
    
end


GOAPSequenceNode = Class(BehaviourNode, function(self, planfn)
    BehaviourNode._ctor(self, "GOAPSequence")
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