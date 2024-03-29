--- This module contains functions to conveniently debug
-- hiding certain debug info as appropriate depending on the level

INFO = false
WARNING = false
ERROR = true

function info(string)
   if INFO then
      print('INFO: '..string)
   end
end

function warning(string)
   -- body
   if WARNING then
      print('WARNING: '..string)
   end
end

function error(string)
   -- body
   if ERROR then
      print('ERROR: '..string)
   end
end