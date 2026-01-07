return function(instance: Instance, property: string, callback: (value: any) -> (() -> ())?)
    local cleanup: (() -> ())?;

    local function runCallback()
        if cleanup then
            task.spawn(cleanup);
        end;
        cleanup = callback(instance[property]);
    end;

    task.spawn(runCallback);

    local connection = instance:GetPropertyChangedSignal(property):Connect(runCallback);

    return function()
        if cleanup then
            task.spawn(cleanup);
            cleanup = nil;
        end;
        connection:Disconnect();
    end;
end;
