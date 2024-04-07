local ObservePlayers = require(script.Parent.ObservePlayers);

return function(callback: (char: Model) -> (() -> ()))
    local stopObservingPlayers = ObservePlayers(function(player)
        local cleanFunc: (() -> ())?;

        if player.Character then
            cleanFunc = callback(player.Character);
        end;

        local characterAddedConnection = player.CharacterAdded:Connect(function(char)
            cleanFunc = callback(char);
        end);
        local characterRemovingConnection = player.CharacterRemoving:Connect(function()
            if cleanFunc then
                cleanFunc();
                cleanFunc = nil;
            end;
        end);

        return function()
            if cleanFunc then
                task.spawn(cleanFunc);
            end;
            characterAddedConnection:Disconnect();
            characterRemovingConnection:Disconnect();
        end;
    end);

    return function()
        stopObservingPlayers();
    end;
end;