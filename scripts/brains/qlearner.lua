require("general-utils/debugprint")
require("general-utils/table_ops")

local GAMMA = 0.5
local UPDATECOUNT = 0
local UPDATE = 2 -- variable

local GOALNAMES = {
	-- should be exact same name as goals
	'KeepPlayerFull',
	'FollowPlayer',
	'GetForPlayerlog',
	'GetForPlayertwigs',
	'GetForPlayercutgrass',
	'GetForPlayerrocks',
	'GetForPlayercarrot',
	'GetForPlayerberries',
	'GetForPlayersilk',
	'GetForPlayergoldnugget',
	'GetForPlayerflint'
}

local Q_MATRICES, R_MATRICES = {}, {}

local function populatematrices(matrices, allactions, defaultvalue)
	-- populate each goal matrix with
	-- action x action matrix
	if allactions then
		for _, goalname in ipairs(GOALNAMES) do
			matrices[goalname] = {}
		end

		for goalname,matrix in pairs(matrices) do
			for i,action in ipairs(allactions) do
			   matrix[action.name] = defaultvalue
			end
      end
	else
		info('Actions not populated, reward will not work')
	end
end

-- remember 'action' is actually state in this case
-- Scratch the above, trying action as action


local function normalise(matrix)
   -- computationally expensive
   local largestvalue = -2
   for k,v in pairs(matrix) do      
      if v > largestvalue then
         largestvalue = v
      end      
   end

   for k,v in pairs(matrix) do      
		local normalised_v = v/largestvalue * 100 --get percentage
		matrix[k]= normalised_v
   end
end

local function unpackmatrix(matrix)
	local unpacked = {}
	for k,v in pairs(matrix) do
		table.insert(unpacked, #unpacked+1, v)
	end
	return unpacked
end

local function updateallqmatrix()
	error('UPDATE Q MATRIX')
	for i=1,10 do
	   for goalname,qmatrix in pairs(Q_MATRICES) do
			for action, value in pairs(qmatrix) do

				local reward = R_MATRICES[goalname][action]
				if reward and reward >= 0 then					
					info('q-matrix value before of '..action..': '..tostring(qmatrix[action]))
					local qvalues = unpackmatrix(qmatrix)
					qmatrix[action] = reward + GAMMA * math.max(unpack(qvalues))
					info('q-matrix value after of '..action..': '..tostring(qmatrix[action]))
		   	end
		   end
      end
	end

	for goalname,qmatrix in pairs(Q_MATRICES) do
		normalise(qmatrix)
	end
end

function populateallmatrices(actions)
   populatematrices(R_MATRICES, actions, -1) -- start off with terrible rewards for all
	populatematrices(Q_MATRICES, actions, 100) --start off naively taking any action, assuming they all are good. only works this way cuz how A* works
end

function updaterewardmatrix(goalname, actionname, value)
   -- occurs when Perform is ran

   local gmatrix = R_MATRICES[goalname]
	gmatrix[actionname] = value
	info('new value for transition '..actionname..' : '..tostring(value))

	if UPDATECOUNT == UPDATE then		
		error('UPDATE COUNT '..tostring(UPDATECOUNT))
		UPDATECOUNT = 0
		updateallqmatrix()
		error('NEW UPDATE COUNT '..tostring(UPDATECOUNT))
	else		
		UPDATECOUNT = UPDATECOUNT + 1
		error('UPDATE COUNT '..tostring(UPDATECOUNT))
	end
end

function getcost(goalname, actionname)
   return Q_MATRICES[goalname][actionname]
end