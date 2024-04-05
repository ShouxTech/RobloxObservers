return function(state, callback: (value: any) -> ())
    task.spawn(callback, state.Get());

    state._observers[callback] = true;

    return function()
        state._observers[callback] = nil;
    end;
end;