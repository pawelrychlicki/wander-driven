public enum ScreenAction: Equatable, Sendable {
    case document(componentID: ComponentID, action: DocumentAction)
    case startEffect(ScreenEffectRequest)
    case effectCompleted(id: ScreenEffectID, result: ScreenEffectResult)
    case cancelEffect(id: ScreenEffectID)
    case dismissAlert
}
