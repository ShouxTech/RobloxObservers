return function(initialValue: any)
    local value = initialValue;

    local observers = {};

    return {
        Get = function()
            return value;
        end,
        Set = function(newValue: any)
            if newValue == value then return; end;

            value = newValue;

            for observer in observers do
                task.spawn(observer, value);
            end;
        end,
        _observers = observers,
    };
end;