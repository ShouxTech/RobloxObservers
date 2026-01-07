interface State<T> {
    get(): T;
    set(newValue: T): void;
}

declare namespace Observers {
    function state<T>(initialValue: T): State<T>;
    function state<T>(): State<T | undefined>;

    function observeAttribute<T extends AttributeValue>(instance: Instance, attribute: string, callback: (value: T | undefined) => (() => void) | void): () => void;
    function observeState<T>(state: State<T>, callback: (value: T) => void): () => void;
    function observePlayers(callback: (player: Player) => (() => void) | void): () => void;
    function observeCharacters(callback: (char: Model, player: Player) => (() => void) | void): () => void;
    function observeAttribute<T extends AttributeValue>(instance: Instance, attribute: string, callback: (value: T | undefined) => (() => void) | void): () => void;
    function observeChildren(instance: Instance, callback: (child: Instance) => (() => void) | void): () => void;
    function observeTag<T extends Instance>(tag: string, callback: (instance: T) => (() => void) | void, ancestors?: Instance[]): () => void;
    function observeProperty<P extends Instance, K extends InstancePropertyNames<P>>(instance: P, property: K, callback: (value: P[K]) => (() => void) | void): () => void;
}

export = Observers;