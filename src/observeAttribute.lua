return function(instance: Instance, attribute: string, callback: (value: any) -> (() -> ())?)
    local cleanup: (() -> ())?;

    local function runCallback()
        if cleanup then
            task.spawn(cleanup);
        end;
        cleanup = callback(instance:GetAttribute(attribute));
    end;

    task.spawn(runCallback);

    local connection = instance:GetAttributeChangedSignal(attribute):Connect(runCallback);

    return function()
        if cleanup then
            task.spawn(cleanup);
            cleanup = nil;
        end;
        connection:Disconnect();
    end;
end;
