local function splitString(string, delimeter, numerical)
   local res = {}
   for w in string.gmatch( time, numerical ) do
      if numerical then
         table.insert( res, #res+1, tonumber(w))
      else
         table.insert( res, #res+1, w)
      end
   end
end

function timePassedInSeconds(startt, endt)
   local startdt = splitString(startt, ' ', false)
   local enddt = splitString(endt, ' ', false)

   local startdate = splitString(startdt[1], '/', true)
   local enddate = splitString(enddt[1], '/', true)
   local starttime = splitString(startdt[2], ':', true)
   local endtime = splitString(enddt[2], ':', true)

   if startdate == enddate then
      -- same day
      local h = (endtime[1] - starttime[1]) * 3600
      local m = (endtime[2] - starttime[2]) * 60
      local s = endtime[3] - starttime[3]

      return h + m + s
   else      
      local prevh = (24 - starttime[1]) * 3600
      local prevm = (60 - startdate[2]) * 60
      local prevs = (60 - startdate[3])
      -- diff day
      return prevh + prevm + prevs + (endtime[1] * 3600) + (endtime[2] * 60) + (endtime[3])
   end
end

