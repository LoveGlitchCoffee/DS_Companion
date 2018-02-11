require "generalutils/debugprint"
require "generalutils/table_ops"

local GAMMA = 0.5 -- learning rate
local UPDATECOUNT = 0
local UPDATE = 5 -- when to update matrices

--- table contains all possible goals
-- each goal has its own action matrix
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

--- Q and reward matrices for each goal
local Q_MATRICES, R_MATRICES = {}, {}

---
-- populate the matrices, either Q or R, with the default value
-- note that because action encompases possible state->state
-- it is just a vector of action to represent the q/r matrix for a goal
-- @param matrices the matrices to populate
-- @param allactions all possible actions
-- @param defaultvalue the default value to populate matrices with
local function populatematrices(matrices, allactions, defaultvalue)	
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

---
-- normalise the matrix values
-- @param matrix matrix to normalise
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

---
-- unpack a matrix into a list of values
-- @param matrix matrix to unpack
-- @return unpacked matrix as table
local function unpackmatrix(matrix)
	local unpacked = {}
	for k,v in pairs(matrix) do
		table.insert(unpacked, #unpacked+1, v)
	end
	return unpacked
end

---
-- update all the matrix values according to q-learning:
-- m[a] = r + gammer*max(m[a+1])
-- reward is taken from reward matrix.
-- This is done for all matrices for every goal.
-- This is done repeteadly so can normalise more easily
-- @see unpackmatrix
local function updateallqmatrix()
	info('UPDATE Q MATRIX')
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
      error('for '..goalname)
      for action, value in pairs(qmatrix) do
         error('q-value for '..action..': '..tostring(value))
      end
   end   
end

---
-- initialise matrices
-- @param actions all possible actions
-- @return 
function populateallmatrices(actions)
   populatematrices(R_MATRICES, actions, -1) -- start off with terrible rewards for all
	populatematrices(Q_MATRICES, actions, 100) --start off naively taking any action, assuming they all are good. only works this way cuz how A* works
end

---
-- updates the reward for an action being performed to achieve a certain goal.
-- If reward has been updated UPDATE number of times, update the learning Q matrices
-- @param goalname name of goal trying to achieve
-- @param actionname name of action to update
-- @param value new reward value
function updaterewardmatrix(goalname, actionname, value)   
   local gmatrix = R_MATRICES[goalname]
	gmatrix[actionname] = value
	info('new value for transition '..actionname..' : '..tostring(value))

	if UPDATECOUNT == UPDATE then		
		info('UPDATE COUNT '..tostring(UPDATECOUNT))
		UPDATECOUNT = 0
		updateallqmatrix()
		info('NEW UPDATE COUNT '..tostring(UPDATECOUNT))
	else		
		UPDATECOUNT = UPDATECOUNT + 1
		info('UPDATE COUNT '..tostring(UPDATECOUNT))
	end
end

---
-- get the current q-value for an action performed achieving a goal
-- this is used to calculate cost for plannig
-- @param goalname name of goal trying to achieve
-- @param actionname name of action to get cost learning value for
-- @return the learning q-value of action
function getcost(goalname, actionname)
   return Q_MATRICES[goalname][actionname]
end