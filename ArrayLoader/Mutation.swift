// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

/// Enumerates the mutations that can be triggered on stateful data when a `LoadResult` or `InfoLoadResult` is processed
/// by `StrategyArrayLoader` or `InfoStrategyArrayLoader`.
public enum Mutation<Value>
{
    // MARK: - Cases
    
    /// Replaces the old value with a new value.
    case Replace(Value)
    
    /// Does not replace the old value with a new value.
    case DoNotReplace
    
    // MARK: - Value
    
    /// The value of the mutation, if of case `.Replace`. Otherwise, `nil`.
    var value: Value?
    {
        switch self
        {
        case .Replace(let value):
            return value
        case .DoNotReplace:
            return nil
        }
    }
}
