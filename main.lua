--[[
--      EXAMPLE TABLES
]]

--     {task_id → number_of_hours_required_to_complete_task}

local tasks = {
	["A"] = 0.7;
	["B"] = 0.4;
	["C"] = 0.6;
	["D"] = 1.3;
	["E"] = 4.2;
	["F"] = 3.2;
	["G"] = 0.9;
	["H"] = 2;
}

--     Batterycapacity is given in hours. 
--
--     publisher_id → info_about_publisher

local publishers = {
	[1] = {
		BatteryCapacity = 5;
		ExecutableTasks = {"A", "B", "E"}
	},
	[2] = {
		BatteryCapacity = 4;
		ExecutableTasks = {"A", "C", "G"}
	},
	[3] = {
		BatteryCapacity = 19;
		ExecutableTasks = {"F", "G", "H"}
	},
}

--[[
--      HELPER FUNCTIONS (Not specifically relevant to the problem)
]]
local function getIndex(table, element)
  for i, x in ipairs(table) do
    if x == element then
      return i
    end
  end
end

local function getKeys_sorted(dictionary)
  local keys = {}
  for k, _ in pairs(dictionary) do
    table.insert(keys, k)
  end
  table.sort(keys, function(a, b)
    return (a < b)
  end)
  return keys
end
local function tableToString(table, depth)
  if depth == nil then depth = 1 end
  
  local isArray = (table[1] ~= nil)
  
  local surroundingBrackets_indentation = string.rep(" ", (depth - 1) * 2)
  local entries_indentation = string.rep(" ", depth * 2)
  
  local result = "{\n"
  
  if isArray then
    local arrayOnlyHasOneElement = (table[2] == nil)
    if arrayOnlyHasOneElement then
      local onlyElement = table[1]
      if type(onlyElement) ~= "table" then
        return "{" .. tostring(onlyElement) .. "}"
      else
        return "{" .. tableToString(onlyElement, depth + 1) .. "}"
      end
    end
    for i, x in ipairs(table) do
      if type(x) ~= "table" then
        result = result .. entries_indentation .. tostring(x) .. ",\n"
      else
        result = result .. entries_indentation .. tableToString(x, depth + 1) .. ",\n"
      end
    end
  else
    local numEntriesInDictionary = 0
    local keys_sorted = getKeys_sorted(table)
    for _, _ in ipairs(keys_sorted) do
      numEntriesInDictionary = numEntriesInDictionary + 1
    end
    if numEntriesInDictionary == 0 then
      return "{}"
    elseif numEntriesInDictionary == 1 then
      local theOnlyKey = keys_sorted[1]
      local theOnlyValue = table[theOnlyKey]
      if type(theOnlyValue) ~= "table" then
        return "{" .. theOnlyKey .. ": " .. tostring(theOnlyValue) .. "}"
      else
        return "{" .. theOnlyKey .. ": " .. tableToString(theOnlyValue, depth + 1) .. "}"
      end
    end
    
    for _, k in ipairs(keys_sorted) do
      local v = table[k]
      if type(v) ~= "table" then
        result = result .. entries_indentation .. k .. ": " .. tostring(v) .. ",\n"
      else
        result = result .. entries_indentation .. k .. ": " .. tableToString(v, depth + 1) .. ",\n"
      end
    end
  end
  result = string.sub(result, 1, -2)
  result = result .. "\n" .. surroundingBrackets_indentation .. "}"
  return result
end

local function numberToLetter(i)
  return string.char(64 + i)
end

local function finerRandom(a, b)
  return (math.random(a * 100, b * 100) / 100)
end

local function round(n)
  local s = tostring(n)
  for i = 1, string.len(s) do
    if s:sub(i, i) == "." then
      return s:sub(1, i + 2)
    end
  end
  return s
end

--[[
--      GENERATION OF MORE REALISTIC(?) SCENARIOS
]]
local NUM_TASKS = 5
local NUM_PUBLISHERS = 3

local MAX_TASKS_PUBLISHER_CAN_DO = NUM_TASKS

local MINIMUM_POSSIBLE_BATTERY_HOURS_REQUIRED_FOR_A_TASK = 0.1
local MAXIMUM_POSSIBLE_BATTERY_HOURS_REQUIRED_FOR_A_TASK = 5

local MINIMUM_POSSIBLE_BATTERY_HOURS_PUBLISHER_CAN_POSSESS = 0.5
local MAXIMUM_POSSIBLE_BATTERY_HOURS_PUBLISHER_CAN_POSSESS = 10

local RANDOM_NUMBER_GENERATOR_SEED = nil
----------------------------------------

if RANDOM_NUMBER_GENERATOR_SEED ~= nil then
  math.randomseed(RANDOM_NUMBER_GENERATOR_SEED)
end

print(string.rep("~", 10))
print("Parameters\n")
print("NUM_TASKS: " .. NUM_TASKS)
print("NUM_PUBLISHERS: " .. NUM_PUBLISHERS)
print("MAX_TASKS_PUBLISHER_CAN_DO: " .. MAX_TASKS_PUBLISHER_CAN_DO .. "\n")

print("MINIMUM_POSSIBLE_BATTERY_HOURS_REQUIRED_FOR_A_TASK: " .. MINIMUM_POSSIBLE_BATTERY_HOURS_REQUIRED_FOR_A_TASK)
print("MAXIMUM_POSSIBLE_BATTERY_HOURS_REQUIRED_FOR_A_TASK: " .. MAXIMUM_POSSIBLE_BATTERY_HOURS_REQUIRED_FOR_A_TASK .. "\n")

print("MINIMUM_POSSIBLE_BATTERY_HOURS_PUBLISHER_CAN_POSSESS: " .. MINIMUM_POSSIBLE_BATTERY_HOURS_PUBLISHER_CAN_POSSESS)
print("MAXIMUM_POSSIBLE_BATTERY_HOURS_PUBLISHER_CAN_POSSESS: " .. MAXIMUM_POSSIBLE_BATTERY_HOURS_PUBLISHER_CAN_POSSESS .. "\n")

if RANDOM_NUMBER_GENERATOR_SEED == nil then
  print("RANDOM_NUMBER_GENERATOR_SEED: not set")
else
  print("RANDOM_NUMBER_GENERATOR_SEED: " .. RANDOM_NUMBER_GENERATOR_SEED)
end

print(string.rep("~", 10) .. "\n")

local publishersBatteryCapacitiesSum = 0

local function GenerateNewScenario()
	tasks = {}
	publishers = {}

	-- Create random tasks
	for i = 1, NUM_TASKS do
	  local taskId = numberToLetter(i)
		local number_of_battery_hours = finerRandom(MINIMUM_POSSIBLE_BATTERY_HOURS_REQUIRED_FOR_A_TASK, MAXIMUM_POSSIBLE_BATTERY_HOURS_REQUIRED_FOR_A_TASK)
		tasks[taskId] = number_of_battery_hours
	end

	-- Create random publishers
	for publisherId = 1, NUM_PUBLISHERS do
		local battery_capacity = finerRandom(MINIMUM_POSSIBLE_BATTERY_HOURS_PUBLISHER_CAN_POSSESS, MAXIMUM_POSSIBLE_BATTERY_HOURS_PUBLISHER_CAN_POSSESS)

		local number_of_executables = math.random(1, MAX_TASKS_PUBLISHER_CAN_DO)
		local executable_taskids = {} -- list of taskIds
		for _ = 1, number_of_executables do
		  while true do
		    local task_id = numberToLetter(math.random(1, NUM_TASKS))
		    if getIndex(executable_taskids, task_id) ~= nil then goto continue end
			  table.insert(executable_taskids, task_id)
			  break
			  
			  ::continue::
		  end
			
		end

		publishers[publisherId] = {
			BatteryCapacity = battery_capacity;
			ExecutableTasks = executable_taskids;
		}
		publishersBatteryCapacitiesSum = publishersBatteryCapacitiesSum + battery_capacity
	end
end

GenerateNewScenario()

print("tasks: " .. tableToString(tasks))
print("publishers: " .. tableToString(publishers))
print(string.rep("-", 10))


--[[
--      THE PROBLEM
--
--      How to decide which tasks to assign to which publishers?
--
--      An example table to showcase assignments:
--      Simplying assigning the first three tasks to the first publisher,
--      and assigning the next three following tasks to the second publisher
]]
local publisherAssignments = {
	[1] = {"A", "B", "C"};
	[2] = {"D", "E", "F"}
}

--[[
--      An example procedure for how one might approach
--      writing an algorithm for making these assignments
--
]]

-- [0] Create some preparatory tables
local sortedTasks = {}
for taskId, numHoursToCompleteTask in pairs(tasks) do
	table.insert(sortedTasks, taskId)
end

-- [1] Sort tasks based on their battery expenditure
--     Prioritize tasks that use less battery; put them first in the list
table.sort(sortedTasks, function(taskId1, taskId2)
	local numHoursToCompleteTask1 = tasks[taskId1]
	local numHoursToCompleteTask2 = tasks[taskId2]
	return (numHoursToCompleteTask1 < numHoursToCompleteTask2)
end)

print("Sorted tasks based on battery expenditure.")
print("sortedTasks: " .. tableToString(sortedTasks) .. "\n")

-- [2] Figure out what tasks are more "specialized" than other tasks. In
--     other words, what tasks can be done by a very few publishers
--     while others may be done by many.
--
--     Or, figure out what tasks are more "common". If they can be done
--     by a lot of publishers, they are pretty common
--
--     Assign a "commonness" score to each task
--
local commonalityScores = {}

for i = 1, NUM_TASKS do
	local number_of_publishers_that_can_do_this_task = 0
	
	local taskId = numberToLetter(i)

	for publisherId = 1, NUM_PUBLISHERS do
		if getIndex(publishers[publisherId].ExecutableTasks, taskId) then
			number_of_publishers_that_can_do_this_task = number_of_publishers_that_can_do_this_task + 1
		end
	end

	commonalityScores[taskId] = number_of_publishers_that_can_do_this_task
end

print("commonalityScores: " .. tableToString(commonalityScores) .. "\n")

-- [3] Now sort tasks based on commonness
--     We want tasks that are least common in the front
table.sort(sortedTasks, function(taskId1, taskId2)
	local task1_commonness = commonalityScores[taskId1]
	local task2_commonness = commonalityScores[taskId2]
	return (task1_commonness < task2_commonness)
end)

print("Sorted tasks based on commonality scores.")
print("sortedTasks:" .. tableToString(sortedTasks) .. "\n")

-- [4] Final step: play Tetris
local publisherAssignments = {}
for publisherId = 1, NUM_PUBLISHERS do
	publisherAssignments[publisherId] = {}
end

local unassignedTasks = {}
local batteryCapacityUtilized = 0

for _, taskId in ipairs(sortedTasks) do
	local hoursToCompleteTask = tasks[taskId]
	
	local assignedTaskToPublisher = false
	
	for publisherId, publisherData in pairs(publishers) do
		local publisherCannotDoThisTask = (getIndex(publisherData.ExecutableTasks, taskId) == nil)
		if publisherCannotDoThisTask then goto continue end
		
		local batteryCapacity = publisherData.BatteryCapacity
		if batteryCapacity < hoursToCompleteTask then goto continue end
		
		table.insert(publisherAssignments[publisherId], taskId)
		publisherData.BatteryCapacity = publisherData.BatteryCapacity - hoursToCompleteTask
		batteryCapacityUtilized = batteryCapacityUtilized + hoursToCompleteTask
		assignedTaskToPublisher = true
		break
		
		::continue::
	end
	
	if not assignedTaskToPublisher then
		table.insert(unassignedTasks, taskId)
	end
end

print(string.rep("-", 10))
print("Program finished\n")
print("publisherAssignments: " .. tableToString(publisherAssignments))
print("unassignedTasks: " .. tableToString(unassignedTasks) .. "\n")

-- Print publishers table as well
print("The publishers table was modified during the process.")
for publisherId, publisherData in pairs(publishers) do
  publisherData.ExecutableTasks = nil -- Don't want to print this field
end


print("publishers: " .. tableToString(publishers) .. "\n")
print(string.rep("-", 10))

print("batteryCapacityUtilized: " .. batteryCapacityUtilized)
print("sum of battery capacities among all publishers: " .. publishersBatteryCapacitiesSum)

local batteryCapacityUtilizationRatio = (batteryCapacityUtilized / publishersBatteryCapacitiesSum)
print("batteryCapacityUtilizationRatio: " .. round(batteryCapacityUtilizationRatio))
