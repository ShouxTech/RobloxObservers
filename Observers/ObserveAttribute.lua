return function(instance: Instance, attribute: string, callback: (value: any) -> ())
    task.spawn(callback, instance:GetAttribute(attribute));

    local connection = instance:GetAttributeChangedSignal(attribute):Connect(function()
        callback(instance:GetAttribute(attribute));
    end);

    return function()
        connection:Disconnect();
    end;
end;