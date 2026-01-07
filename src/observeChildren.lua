return function(instance: Instance, callback: (child: Instance) -> (() -> ())?)
    local cleanFuncs: {[Instance]: () -> ()} = {};

    for _, child in instance:GetChildren() do
        task.spawn(function()
            cleanFuncs[child] = callback(child);
        end);
    end;

    local connections: {RBXScriptConnection} = {};
    table.insert(connections, instance.ChildAdded:Connect(function(child)
        cleanFuncs[child] = callback(child);
    end));
    table.insert(connections, instance.ChildRemoved:Connect(function(child)
        local cleanFunc = cleanFuncs[child]
        if cleanFunc then
            cleanFuncs[child] = nil; -- In case cleanFunc yields or errors, remove the table key first.
            cleanFunc();
        end;
    end));

    return function()
        for _, cleanFunc in cleanFuncs do
            task.spawn(cleanFunc);
        end;
        for _, connection in connections do
            connection:Disconnect();
        end;
        connections = {};
        cleanFuncs = {};
    end;
end;