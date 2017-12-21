INFO = true
WARNING = false
ERROR = true

function info(string)
   if INFO then
      print(string)   
   end
end

function warning(string)
   -- body
   if WARNING then
      print(string)   
   end
end

function error(string)
   -- body
   if ERROR then
      print(string)   
   end
end