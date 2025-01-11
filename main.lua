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
--      GENERATION OF MORE REALISTIC(?) SCENARIOS
]]
local NUM_TASKS = 5
local NUM_PUBLISHERS = 3

local function GenerateNewScenario()
	tasks = {}
	publishers = {}

	-- Create random tasks
	for i = 1, NUM_TASKS do
		local number_of_battery_hours = math.random(10, 500)/100 -- A random number between 0.1 and 5 
		
		local taskId = string.char(64 + i) -- 65 => A, 66 -> B, …
		
		tasks[taskId] = number_of_battery_hours
	end

	-- Create random publishers
	for publisherId = 1, NUM_PUBLISHERS do
		local battery_capacity = math.random(50, 1000)/100 -- A random number between 0.5 and 10

		local number_of_executables = math.random(1, NUM_TASKS)
		local executable_taskids = {} -- list of taskIds
		for _ = 1, number_of_executables do
			local task_id = string.char(64 + math.random(1, NUM_TASKS))
			table.insert(executable_taskids, task_id)
		end

		publishers[publisherId] = {
			BatteryCapacity = battery_capacity;
			ExecutableTasks = executable_taskids;
		}
	end
end

GenerateNewScenario()

print("tasks:", tasks)
print("publishers:", publishers)


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
for taskId, numHoursToCompleteTask in tasks do
	table.insert(sortedTasks, taskId)
end

-- [1] Sort tasks based on their battery expenditure
--     Prioritize tasks that use less battery; put them first in the list
table.sort(sortedTasks, function(taskId1, taskId2)
	local numHoursToCompleteTask1 = tasks[taskId1]
	local numHoursToCompleteTask2 = tasks[taskId2]
	return (numHoursToCompleteTask1 < numHoursToCompleteTask2)
end)

print("sortedTasks:", sortedTasks)

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
	
	local taskId = string.char(64 + i)

	for publisherId = 1, NUM_PUBLISHERS do
		if table.find(publishers[publisherId].ExecutableTasks, taskId) then
			number_of_publishers_that_can_do_this_task += 1
		end
	end

	commonalityScores[taskId] = number_of_publishers_that_can_do_this_task
end

print("commonalityScores:", commonalityScores)

-- [3] Now sort tasks based on commonness
--     We want tasks that are least common in the front
table.sort(sortedTasks, function(taskId1, taskId2)
	local task1_commonness = commonalityScores[taskId1]
	local task2_commonness = commonalityScores[taskId2]
	return (task1_commonness < task2_commonness)
end)

print("sortedTasks:", sortedTasks)

-- [4] Final step: play Tetris
local publisherAssignments = {}
for publisherId = 1, NUM_PUBLISHERS do
	publisherAssignments[publisherId] = {}
end

local unassignedTasks = {}

for _, taskId in sortedTasks do
	local hoursToCompleteTask = tasks[taskId]
	
	local assignedTaskToPublisher = false
	
	for publisherId, publisherData in publishers do
		local publisherCannotDoThisTask = (table.find(publisherData.ExecutableTasks, taskId) == nil)
		if publisherCannotDoThisTask then continue end
		
		local batteryCapacity = publisherData.BatteryCapacity
		if batteryCapacity < hoursToCompleteTask then continue end
		
		publisherAssignments[publisherId] = taskId
		publisherData.BatteryCapacity -= hoursToCompleteTask
		assignedTaskToPublisher = true
		break
	end
	
	if not assignedTaskToPublisher then
		table.insert(unassignedTasks, taskId)
	end
end

print("---------------")
print("publisherAssignments:", publisherAssignments)
print("unassignedTasks:", unassignedTasks)
