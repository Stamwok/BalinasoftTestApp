//
//  PhotosListViewModel.swift
//  BalinasoftTestApp
//
//  Created by Егор Шуляк on 22.09.23.
//

import Foundation
import Combine
import UIKit

final class PhotosListViewModel {
    
    // MARK: - Private properties
    
    @Published private(set) var state = State()
    private let input = PassthroughSubject<Event, Never>()
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(service: Service) {
        Publishers.system(
            initial: state,
            reduce: Self.reduce,
            scheduler: RunLoop.main,
            feedbacks: [
                Self.whenLoading(service: service),
                Self.userInput(input: input.eraseToAnyPublisher())
            ]
        )
        .assign(to: \.state, weakly: self)
        .store(in: &bag)
    }
    
    // MARK: - Public methods
    
    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Inner types

extension PhotosListViewModel {
    
    struct State: Equatable {
        enum CurrentState: Equatable {
            case idle
            case loading(page: Int)
            case showingCamera
            case sendingPhoto(PostPhotoInput)
            case loaded(items: [PhotosListTableCellModel], isLastPage: Bool, message: String?)
            case error(String)
        }
        var currentState: CurrentState = .idle
        var items: [PhotosListTableCellModel] = []
        var currentPage = 0
        var isLastPage = false
        var postPhotoInput: PostPhotoInput = PostPhotoInput(name: "", photo: Data(), typeId: -1)
    }
    
    enum Event {
        case onAppear
        case onLoadMore
        case onLoaded(PhotoTypesListResponse)
        case onShowCamera(photoTypeId: Int)
        case onPhotoTaked(UIImage?)
        case onPhotoSended(PostPhotoResponse)
        case onError(String)
    }
}

// MARK: - State machine

extension PhotosListViewModel {
    
    private static func reduce(state: State, event: Event) -> State {
        switch (state.currentState, event) {
        case (.idle, .onAppear):
            return State(currentState: .loading(page: state.currentPage))
        case (_, .onLoaded(let response)):
            var newState = state
            let items = response.content.map { PhotosListTableCellModel(photoDTO: $0) }
            newState.items.append(contentsOf: items)
            newState.currentPage = response.page ?? 0
            newState.isLastPage = !(newState.currentPage < response.totalPages ?? 0)
            newState.currentState = .loaded(items: newState.items, isLastPage: newState.isLastPage, message: nil)
            return newState
        case (_, .onLoadMore):
            var newState = state
            newState.currentState = newState.isLastPage ? .loaded(items: newState.items, isLastPage: true, message: nil) : .loading(page: newState.currentPage + 1)
            return newState
        case (_, .onShowCamera(let typeId)):
            var newState = state
            newState.postPhotoInput.typeId = typeId
            newState.currentState = .showingCamera
            return newState
        case (.showingCamera, .onPhotoTaked(let image)):
            var newState = state
            if let imageData = image?.pngData() {
                newState.postPhotoInput.photo = imageData 
                newState.postPhotoInput.name = "Yahor Shuliak"
                newState.currentState = .sendingPhoto(newState.postPhotoInput)
            } else {
                newState.currentState = .loaded(items: newState.items, isLastPage: newState.isLastPage, message: nil)
            }
            return newState
        case (.sendingPhoto, .onPhotoSended(let response)):
            var newState = state
            let message = response.id != nil ? "Photo sended" : nil
            newState.currentState = .loaded(items: newState.items, isLastPage: newState.isLastPage, message: message)
            return newState
        case (_, .onError(let error)):
            return State(currentState: .error(error))
        default:
            return state
        }
    }
    
    private static func whenLoading(service: Service) -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            switch state.currentState {
            case .loading(let page):
                return service.getPhotoTypesList(page: page)
                    .map { Event.onLoaded($0) }
                    .catch { Just(Event.onError($0.localizedDescription)) }
                    .eraseToAnyPublisher()
            case .sendingPhoto(let input):
                return service.postPhoto(input: input)
                    .map { Event.onPhotoSended($0) }
                    .catch { Just(Event.onError($0.localizedDescription)) }
                    .eraseToAnyPublisher()
            default:
                return Empty().eraseToAnyPublisher()
            }
        }
    }
    
    private static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}
