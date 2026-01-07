local CollectionService = game:GetService('CollectionService');

type InstanceStatus = '__inflight__' | '__dead__';

return function<T>(tag: string, callback: (instance: T) -> (() -> ())?, ancestors: {Instance}?): () -> ()
	local instances: {[Instance]: InstanceStatus | () -> ()} = {}
	local ancestryConn: {[Instance]: RBXScriptConnection} = {}

	local onInstanceAddedConnection: RBXScriptConnection;
	local onInstanceRemovedConnection: RBXScriptConnection;

	local function isGoodAncestor(instance: Instance)
		if not ancestors then return true; end;

		for _, ancestor in ancestors do
			if instance:IsDescendantOf(ancestor) then
				return true;
			end;
		end;

		return false;
	end;

	local function attemptStartup(instance: Instance)
		-- Mark instance as starting up:
		instances[instance] = '__inflight__';

		-- Attempt to run the callback:
		task.defer(function()
			if instances[instance] ~= '__inflight__' then return; end;

			-- Run the callback in protected mode:
			local success, cleanup = xpcall(function(inst: T)
				local clean = callback(inst)
				if clean ~= nil then
					assert(typeof(clean) == 'function', 'callback must return a function or nil')
				end;
				return clean;
			end, debug.traceback, instance :: any)
			if not success then
				local err = '';
				local firstLine = string.split(cleanup :: any, '\n')[1];
				local lastColon = string.find(firstLine, ': ');
				if lastColon then
					err = firstLine:sub(lastColon + 1);
				end;
				warn(`error while calling observeTag('{tag}') callback:{err}\n{cleanup}`);
				return;
			end;

			if instances[instance] ~= '__inflight__' then
				-- Instance lost its tag or was destroyed before callback completed. Call cleanup immediately.
				if cleanup ~= nil then
					task.spawn(cleanup :: any);
				end;
			else
				-- Good startup. Mark the instance with the associated cleanup function.
				instances[instance] = cleanup :: any;
			end;
		end);
	end;

	local function attemptCleanup(instance: Instance)
		local cleanup = instances[instance];
		instances[instance] = '__dead__';

		if typeof(cleanup) == 'function' then
			task.spawn(cleanup);
		end;
	end;

	local function onAncestryChanged(instance: Instance)
		if isGoodAncestor(instance) then
			if instances[instance] == '__dead__' then
				attemptStartup(instance);
			end;
		else
			attemptCleanup(instance);
		end;
	end;

	local function onInstanceAdded(instance: Instance)
		if not onInstanceAddedConnection.Connected then return; end;
		if instances[instance] ~= nil then return; end;

		instances[instance] = '__dead__';

		onAncestryChanged(instance);
		ancestryConn[instance] = instance.AncestryChanged:Connect(function()
			onAncestryChanged(instance);
		end);
	end;

	local function onInstanceRemoved(instance: Instance)
		attemptCleanup(instance)

		local ancestry = ancestryConn[instance]
		if ancestry then
			ancestry:Disconnect();
			ancestryConn[instance] = nil;
		end;

		instances[instance] = nil;
	end;

	task.defer(function()
		if not onInstanceAddedConnection.Connected then return end

		for _, instance in CollectionService:GetTagged(tag) do
			task.spawn(onInstanceAdded, instance);
		end;
	end);

	onInstanceAddedConnection = CollectionService:GetInstanceAddedSignal(tag):Connect(onInstanceAdded);
	onInstanceRemovedConnection = CollectionService:GetInstanceRemovedSignal(tag):Connect(onInstanceRemoved);

	return function()
		onInstanceAddedConnection:Disconnect();
		onInstanceRemovedConnection:Disconnect();

		local instance = next(instances);
		while instance do
			onInstanceRemoved(instance);
			instance = next(instances);
		end;
	end;
end;
