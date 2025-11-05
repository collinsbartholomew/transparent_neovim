import Array "mo:base/Array";

actor Counter {
    var count : Nat = 0;

    public func increment() : async Nat {
        count += 1;
        return count;
    }

    public func getCount() : async Nat {
        return count;
    }
}