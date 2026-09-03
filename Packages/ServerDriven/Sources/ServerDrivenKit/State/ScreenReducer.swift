public struct ScreenReducer: Sendable {
    public init() {}

    public func reduce(
        _ state: inout ScreenState,
        _ action: ScreenAction
    ) -> [ScreenEffect] {
        switch action {
        case let .document(componentID, documentAction):
            return reduce(documentAction, from: componentID, into: &state)
        case let .startEffect(request):
            state.activeEffectIDs.insert(request.id)
            return [.run(id: request.id, request: request)]
        case let .effectCompleted(id, result):
            state.activeEffectIDs.remove(id)
            state.lastEffectResult = result
            return []
        case let .cancelEffect(id):
            state.activeEffectIDs.remove(id)
            return [.cancel(id: id)]
        case .dismissAlert:
            state.presentedAlert = nil
            return []
        }
    }

    private func reduce(
        _ action: DocumentAction,
        from componentID: ComponentID,
        into state: inout ScreenState
    ) -> [ScreenEffect] {
        switch action.type {
        case "toggleFavorite":
            guard let targetID = destinationID(in: action.payload) ??
                (state.componentStates[componentID] == nil ? nil : componentID),
                state.componentStates[targetID] != nil
            else {
                return []
            }

            state.componentStates[targetID, default: ComponentState()].isFavorite.toggle()
            return []
        case "showAlert":
            guard let values = action.payload?.objectValue,
                  let title = values["title"]?.stringValue,
                  let message = values["message"]?.stringValue,
                  !title.isEmpty,
                  !message.isEmpty
            else {
                return []
            }

            state.presentedAlert = AlertState(title: title, message: message)
            return []
        case "navigate":
            guard let destinationID = destinationID(in: action.payload) else {
                return []
            }
            return [.forward(.navigate(destinationID: destinationID))]
        default:
            return []
        }
    }

    private func destinationID(in payload: JSONValue?) -> ComponentID? {
        guard let value = payload?.objectValue?["destinationID"]?.stringValue else {
            return nil
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : ComponentID(trimmed)
    }
}

private extension JSONValue {
    var objectValue: [String: JSONValue]? {
        guard case let .object(values) = self else {
            return nil
        }
        return values
    }

    var stringValue: String? {
        guard case let .string(value) = self else {
            return nil
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
