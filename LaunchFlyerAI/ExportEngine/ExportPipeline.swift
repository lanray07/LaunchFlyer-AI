import SwiftUI
import UIKit

enum ExportPipelineError: LocalizedError {
    case renderFailed

    var errorDescription: String? {
        "The campaign asset could not be rendered."
    }
}

final class ExportPipeline {
    @MainActor
    func exportImage<V: View>(view: V, format: ExportFormat, size: CGSize = CGSize(width: 1080, height: 1350)) throws -> URL {
        switch format {
        case .png:
            return try renderImage(view: view, size: size, fileExtension: "png") { $0.pngData() }
        case .jpg:
            return try renderImage(view: view, size: size, fileExtension: "jpg") { $0.jpegData(compressionQuality: 0.92) }
        case .pdf:
            return try renderPDF(view: view, size: size)
        }
    }

    @MainActor
    private func renderImage<V: View>(
        view: V,
        size: CGSize,
        fileExtension: String,
        encoder: (UIImage) -> Data?
    ) throws -> URL {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        guard let image = renderer.uiImage, let data = encoder(image) else {
            throw ExportPipelineError.renderFailed
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("launchflyer-\(UUID().uuidString).\(fileExtension)")
        try data.write(to: url)
        return url
    }

    @MainActor
    private func renderPDF<V: View>(view: V, size: CGSize) throws -> URL {
        let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
        renderer.scale = UIScreen.main.scale
        guard let image = renderer.uiImage else {
            throw ExportPipelineError.renderFailed
        }

        let bounds = CGRect(origin: .zero, size: size)
        let data = UIGraphicsPDFRenderer(bounds: bounds).pdfData { context in
            context.beginPage()
            image.draw(in: bounds)
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("launchflyer-\(UUID().uuidString).pdf")
        try data.write(to: url)
        return url
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
