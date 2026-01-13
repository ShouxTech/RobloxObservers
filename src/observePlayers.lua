local Players = game:GetService('Players');

return function(callback: (player: Player) -> (() -> ())?)
    local cleanFuncs: { [Player]: () -> () } = {};

    local function handlePlayer(player: Player)
        local cleanup = callback(player);
        if not cleanup then return; end;

        if not player.Parent then -- Player left while callback was running.
            cleanup(); 
            return;
        end;

        cleanFuncs[player] = cleanup;
    end;

    for _, player in Players:GetPlayers() do
        task.spawn(handlePlayer, player);
    end;

    local connections: { RBXScriptConnection } = {};
    
    table.insert(connections, Players.PlayerAdded:Connect(handlePlayer));
    table.insert(connections, Players.PlayerRemoving:Connect(function(player)
        local cleanFunc = cleanFuncs[player];
        if cleanFunc then
            cleanFuncs[player] = nil;
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