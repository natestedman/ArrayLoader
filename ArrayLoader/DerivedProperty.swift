// ArrayLoader
// Written in 2015 by Nate Stedman <nate@natestedman.com>
//
// To the extent possible under law, the author(s) have dedicated all copyright and
// related and neighboring rights to this software to the public domain worldwide.
// This software is distributed without any warranty.
//
// You should have received a copy of the CC0 Public Domain Dedication along with
// this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

import ReactiveCocoa
import Result

/// The property type used for `ArrayLoader` extensions.
public final class DerivedProperty<Value>: PropertyType
{
    // MARK: - Initialization
    
    /**
    Initializes a derived property.
    
    - parameter wrapped: The property to wrap.
    */
    init(wrapped: AnyProperty<Value>)
    {
        self.wrapped = wrapped
    }
    
    // MARK: - Wrapped Property
    
    /// The wrapped property.
    let wrapped: AnyProperty<Value>
    
    // MARK: - Value
    
    /// The current value of the property.
    public var value: Value
    {
        return wrapped.value
    }
    
    // MARK: - Signal Producer
    
    /// A signal producer for the property's values.
    public var producer: SignalProducer<Value, NoError>
    {
        // strongly reference self until the property is disposed
        return wrapped.producer.on(disposed: { self })
    }

    /// A signal for the property's values.
    public var signal: Signal<Value, NoError>
    {
        return wrapped.signal.on(disposed: { self })
    }
}
