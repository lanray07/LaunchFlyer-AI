import Combine
import Foundation

final class FlyerDesignerViewModel: ObservableObject {
    @Published var document: FlyerDesignDocument

    init(document: FlyerDesignDocument = .sample) {
        self.document = document
    }

    func apply(template: TemplateDescriptor) {
        document = TemplateEngine().apply(template: template, to: document)
    }
}
