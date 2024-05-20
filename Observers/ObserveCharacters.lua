local ObservePlayers = require(script.Parent.ObservePlayers);

return function(callback: (char: Model, player: Player) -> (() -> ())?)
    local stopObservingPlayers = ObservePlayers(function(player)
        local cleanFunc: (() -> ())?;

        if player.Character then
            task.spawn(function()
                cleanFunc = callback(player.Character, player);
            end);
        end;

        local characterRemovingConnection;
        local characterAddedConnection = player.CharacterAdded:Connect(function(char)
            characterRemovingConnection = char.AncestryChanged:Connect(function(_, parent)
                if parent then return; end;

                characterRemovingConnection:Disconnect();
                characterRemovingConnection = nil;

                if cleanFunc then
                    cleanFunc();
                    cleanFunc = nil;
                end;
            end);

            cleanFunc = callback(char, player);
        end);

        return function()
            if cleanFunc then
                task.spawn(cleanFunc);
            end;
            characterAddedConnection:Disconnect();
            if characterRemovingConnection then
                characterRemovingConnection:Disconnect();
            end;
        end;
    end);

    return function()
        stopObservingPlayers();
    end;
end;