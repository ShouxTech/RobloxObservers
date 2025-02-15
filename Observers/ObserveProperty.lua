return function(instance: Instance, property: string, callback: (value: any) -> ())
	task.spawn(callback, instance[property]);

	local connection = instance:GetPropertyChangedSignal(property):Connect(function()
		callback(instance[property]);
	end);

	return function()
		connection:Disconnect();
	end;
end;
