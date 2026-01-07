local Players = game:GetService('Players');

return function(callback: (player: Player) -> (() -> ())?)
    local cleanFuncs: {[Player]: () -> ()} = {};

    for _, player in Players:GetPlayers() do
        task.spawn(function()
            cleanFuncs[player] = callback(player);
        end);
    end;

    local connections: {RBXScriptConnection} = {};
    table.insert(connections, Players.PlayerAdded:Connect(function(player)
        cleanFuncs[player] = callback(player);
    end));
    table.insert(connections, Players.PlayerRemoving:Connect(function(player)
        local cleanFunc = cleanFuncs[player]
        if cleanFunc then
            cleanFuncs[player] = nil; -- In case cleanFunc yields or errors, remove the table key first.
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