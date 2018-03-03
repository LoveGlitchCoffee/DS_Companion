require "generalutils/debugprint"
require "generalutils/table_ops"
require "brains/brainutils"

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
local R_MATRICES = {}
Q_MATRICES = {}
-- list containing action objects
local A_LIST = {}
local ALL_ACTIONS = nil

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
local function unpack_action_matrix(matrix, action)
   local unpacked = {}
   for next_action,v in pairs(matrix) do
      if is_satisfykey(A_LIST[action]:PostEffect(), A_LIST[next_action]:Precondition()) then
         table.insert(unpacked, #unpacked+1, v)
      end
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
	for goalname,qmatrix in pairs(Q_MATRICES) do
		for action, value in pairs(qmatrix) do
			local reward = R_MATRICES[goalname][action]
         if reward then
            -- error('reward '..tostring(reward))
				info('q-matrix value before of '..action..': '..tostring(qmatrix[action]))
            local nextqvalues = unpack_action_matrix(qmatrix, action)
            if #nextqvalues > 0 then
               -- error('learning val '..tostring((reward + math.max(unpack(nextqvalues)))))
               qmatrix[action] = value + GAMMA * (reward + math.max(unpack(nextqvalues) - value))
            end
				-- error('q-matrix value after of '..action..': '..tostring(qmatrix[action]))
	   	end
	   end
   end

   -- for goalname,qmatrix in pairs(Q_MATRICES) do
   --    if goalname == 'KeepPlayerFull' then
   --       error('for '..goalname)
   --       for action, value in pairs(qmatrix) do
   --          error('q-value for '..action..': '..tostring(value))
   --       end
   --    end
   -- end
   populatematrices(R_MATRICES, ALL_ACTIONS, nil)

	for goalname,qmatrix in pairs(Q_MATRICES) do
      normalise(qmatrix)
       if goalname == 'KeepPlayerFull' then
          error('for '..goalname)
          for action, value in pairs(qmatrix) do
             error('q-value for '..action..': '..tostring(value))
          end
       end
   end
end

---
-- initialise matrices
-- @param actions all possible actions
-- @return
function populateallmatrices(actions)
   for i,action in ipairs(actions) do
      A_LIST[action.name] = action -- by name safer than by object
   end
   ALL_ACTIONS = actions
   populatematrices(R_MATRICES, actions, nil) -- start off with terrible rewards for all
   if next(Q_MATRICES) == nil then
      error("POPULATING")
      populatematrices(Q_MATRICES, actions, 100) --start off naively taking any action, assuming they all are good. only works this way cuz how A* works
   end
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