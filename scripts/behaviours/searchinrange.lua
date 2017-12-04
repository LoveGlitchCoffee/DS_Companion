SearchInRange = Class(BehaviourNode, function(self, inst, item, distance)
               BehaviourNode._ctor(self, 'SearchInRange')
               self.item_to_search = item
               self.searching_distance = searching
end)

function SearchInRange:Visit()

end