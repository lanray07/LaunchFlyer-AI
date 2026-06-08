import Combine
import Foundation
import StoreKit

final class SubscriptionService: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var currentPlan: SubscriptionPlan = .free
    @Published private(set) var isActive = false
    @Published var errorMessage: String?

    private let productIDs = [
        "launchflyer.creator.monthly",
        "launchflyer.creator.yearly",
        "launchflyer.business.monthly",
        "launchflyer.agency.monthly"
    ]

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
        do {
            products = try await Product.products(for: productIDs)
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    func purchase(_ product: Product) async {
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
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let transaction) = entitlement {
                activePlan = plan(for: transaction.productID)
            }
        }
        currentPlan = activePlan
        isActive = activePlan != .free
    }

    @MainActor
    private func handle(transactionResult: VerificationResult<Transaction>) async {
        switch transactionResult {
        case .verified(let transaction):
            currentPlan = plan(for: transaction.productID)
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
}
