import Foundation

@MainActor
public struct BundleScreenDocumentSource: ScreenDocumentSource {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    public init(bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
    }

    public func loadDocument(named name: String) throws -> ScreenDocument {
        let resourceName = (name as NSString).deletingPathExtension
        let resourceExtension = (name as NSString).pathExtension.isEmpty
            ? "json"
            : (name as NSString).pathExtension

        guard let url = bundle.url(
            forResource: resourceName,
            withExtension: resourceExtension
        ) else {
            throw ScreenDocumentSourceError.resourceNotFound(name)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ScreenDocumentSourceError.unreadableResource(
                name: name,
                detail: String(describing: error)
            )
        }

        do {
            return try decoder.decode(ScreenDocument.self, from: data)
        } catch {
            throw ScreenDocumentSourceError.invalidDocument(
                name: name,
                detail: String(describing: error)
            )
        }
    }
}
