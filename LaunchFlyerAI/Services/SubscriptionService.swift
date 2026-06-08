import Combine
import Foundation
import StoreKit

final class SubscriptionService: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var currentPlan: SubscriptionPlan = .free
    @Published private(set) var currentProductID: String?
    @Published private(set) var isActive = false
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var purchasingProductID: String?
    @Published var errorMessage: String?

    private let productIDs = SubscriptionSKU.allCases.map(\.rawValue)

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                await self.handle(transactionResult: update)
            }
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    @MainActor
    func loadProducts() async {
        isLoadingProducts = true
        errorMessage = nil
        do {
            products = try await Product.products(for: productIDs)
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingProducts = false
    }

    @MainActor
    func purchase(_ product: Product) async {
        purchasingProductID = product.id
        errorMessage = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handle(transactionResult: verification)
            case .pending:
                errorMessage = "Purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                errorMessage = "StoreKit returned an unknown purchase state."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        purchasingProductID = nil
    }

    @MainActor
    func purchase(_ sku: SubscriptionSKU) async {
        guard let product = product(for: sku) else {
            errorMessage = "StoreKit product \(sku.rawValue) is not loaded. Check the StoreKit configuration or App Store Connect product setup."
            return
        }
        await purchase(product)
    }

    @MainActor
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func refreshEntitlements() async {
        var activePlan: SubscriptionPlan = .free
        var activeProductID: String?
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement {
                activePlan = plan(for: transaction.productID)
                activeProductID = transaction.productID
            }
        }
        currentPlan = activePlan
        currentProductID = activeProductID
        isActive = activePlan != .free
    }

    @MainActor
    private func handle(transactionResult: VerificationResult<Transaction>) async {
        switch transactionResult {
        case .verified(let transaction):
            currentPlan = plan(for: transaction.productID)
            currentProductID = transaction.productID
            isActive = currentPlan != .free
            await transaction.finish()
        case .unverified:
            errorMessage = "Unable to verify the transaction."
        }
    }

    private func plan(for productID: String) -> SubscriptionPlan {
        if productID.contains("agency") { return .agency }
        if productID.contains("business") { return .business }
        if productID.contains("creator") { return .creator }
        return .free
    }

    func product(for sku: SubscriptionSKU) -> Product? {
        products.first { $0.id == sku.rawValue }
    }

    func displayPrice(for sku: SubscriptionSKU) -> String {
        product(for: sku)?.displayPrice ?? sku.fallbackPrice
    }
}
