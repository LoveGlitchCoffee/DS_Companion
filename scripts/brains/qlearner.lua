require("general-utils/debugprint")

local GAMMA = 0.5
local UPDATECOUNT = 0
local UPDATE = 5 -- variable 

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

local function populatematrices(matrices, actions, defaultvalue)
	-- populate each goal matrix with
	-- action x action matrix
	if actions then
		for _, goalname in ipairs(GOALNAMES) do
			matrices[goalname] = {}						
		end			
		
		for goalname,matrix in pairs(matrices) do
			for i,actionone in ipairs(actions) do
			   matrix[actionone.name] = {}
			   for j,actiontwo in ipairs(actions) do
				   if i == j then -- hopefully works
                  info('no transition possible')
                  matrix[actionone.name][actiontwo.name] = {}
				   else
                  matrix[actionone.name][actiontwo.name] = defaultvalue
					end
				end
			end
      end
	else
		error('Actions not populated, reward will not work')
	end
end

-- remember 'action' is actually state in this case

function populateallmatrices(actions)
   populatematrices(R_MATRICES, actions, -1) -- start off with terrible rewards for all
   populatematrices(Q_MATRICES, actions, 100) --start off naively taking any action, assuming they all are good. only works this way cuz how A* works
end

function updaterewardmatrix(goalname, prev_actionname, next_actionname, value, allactions)
	error('UPDATING REWARD')
   -- occurs when Perform is ran
   if prev_actionname == next_actionname then
      -- jus repeatable action so don't worry
      return
   end
   local gmatrix = R_MATRICES[goalname]   
	gmatrix[prev_actionname][next_actionname] = value
	
	if UPDATECOUNT == UPDATE then
		UPDATECOUNT = 0
		updateallqmatrix()
	else
		error('UPDATING UPDATE FOR Q')
		UPDATECOUNT = UPDATECOUNT + 1
	end
end

local function normalise(matrix)
   -- computationally expensive
   local largestvalue = -2
   for k,v in pairs(matrix) do      
      for m,n in pairs(v) do
         if n > largestvalue then
            largestvalue = n
         end
      end
   end

   for k,v in pairs(matrix) do      
      for m,n in pairs(v) do
         local normalised_n = n/largestvalue * 100 --get percentage
         matrix[k][m] = normalised_n
      end
   end
end

local function updateallqmatrix()
	error('UPDATING ALL MATRICES')

	for i=1,10 do
	   for goalname,qmatrix in pairs(Q_MATRICES) do		
		   for actionone,actionmatrix in pairs(matrix) do
		   	for actiontwo,v in pairs(actionmatrix) do
		   		local reward = R_MATRICES[goalname][actionone][actiontwo]
		   		if reward and reward >= 0 then					
		   		   qmatrix[actionone][actiontwo] = reward + GAMMA * math.max(qmatrix[actiontwo])
		   		end
		   	end			
		   end
      end		
	end
	
	for goalname,qmatrix in pairs(Q_MATRICES) do
		normalise(qmatrix)
	end
end

function getcost(goalname, prev_actionname, next_actionname)
   return Q_MATRICES[goalname][prev_actionname][next_actionname]
end