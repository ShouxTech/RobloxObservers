local observePlayers = require(script.Parent.observePlayers);

return function(callback: (char: Model, player: Player) -> (() -> ())?)
    local stopObservingPlayers = observePlayers(function(player)
        local cleanFunc: (() -> ())?;

        if player.Character then
            task.spawn(function()
                cleanFunc = callback(player.Character, player);
            end);
        end;

        local characterRemovingConnection = player.CharacterRemoving:Connect(function()
			if cleanFunc then
				cleanFunc();
				cleanFunc = nil;
			end;
		end);
		local characterAddedConnection = player.CharacterAdded:Connect(function(char)
			if cleanFunc then
				cleanFunc();
				cleanFunc = nil;
			end;

			cleanFunc = callback(char, player);
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