return function(instance: Instance, attribute: string, callback: (value: any) -> ())
    task.spawn(callback, instance:GetAttribute(attribute));

    local connections: {RBXScriptConnection} = {};
    table.insert(connections, instance:GetAttributeChangedSignal(attribute):Connect(function()
        callback(instance:GetAttribute(attribute));
    end));

    return function()
        for _, connection in connections do
            connection:Disconnect();
        end;
        connections = {};
    end;
end;