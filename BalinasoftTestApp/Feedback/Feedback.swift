//
//  Feedback.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 22.09.23.
//

import Foundation
import Combine

extension Publisher where Failure == Never {
    
    func assign<Root: AnyObject>(
        to keyPath: WritableKeyPath<Root, Self.Output>, weakly object: Root) -> AnyCancellable {
            return self.sink { [weak object] output in
                object?[keyPath: keyPath] = output
            }
        }
}

struct Feedback<State, Event> {
    
    let run: (AnyPublisher<State, Never>) -> AnyPublisher<Event, Never>
}

extension Feedback {
    init<Effect: Publisher>(effects: @escaping (State) -> Effect) where Effect.Output == Event, Effect.Failure == Never {
        self.run = { state -> AnyPublisher<Event, Never> in
            state
                .map { effects($0) }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
    }
}


