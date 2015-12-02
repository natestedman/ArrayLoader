// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

/// An info type that can be implicitly constructed.
///
/// This type can be used to create `InfoStrategyArrayLoader` instances without providing explicit initial info values.
///
/// An implementation is provided for `Optional`.
public protocol EmptyInfo
{
    // MARK: - Initialization
    
    /// The implicit constructor.
    init()
}

extension Optional: EmptyInfo
{
}
