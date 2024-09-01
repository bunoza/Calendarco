import Foundation
import StoreKit

@MainActor
class StoreViewModel: NSObject, ObservableObject, SKPaymentTransactionObserver {
    @Published var products: [Product] = []
    @Published var purchasedProductIdentifiers: Set<String> = []
    @Published var isProductPurchased: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showPurchaseConfirmation: Bool = false
    @Published var introductoryOfferEligibility: [String: Bool] = [:]
    @Published var isCheckingSubscription: Bool = true

    private var transactionListener: Task<Void, Never>? = nil

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        transactionListener = observeTransactions()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
        transactionListener?.cancel()
    }

    func fetchProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let productIds = [
                IAPConstants.PREMIUM_MONTH_PRODUCT_ID,
                IAPConstants.PREMIUM_YEAR_PRODUCT_ID,
            ]
            products = try await Product.products(for: productIds)
            await checkIntroductoryOffersEligibility(for: products)
        } catch {
            errorMessage = "Failed to fetch products: \(error.localizedDescription)"
        }
    }

    func checkSubscriptionStatus() async {
        isCheckingSubscription = true
        await restorePurchases()
        await fetchProducts()
        await checkPurchaseStatus()
        isCheckingSubscription = false
    }

    private func checkIntroductoryOffersEligibility(for products: [Product]) async {
        for product in products {
            if let subscription = product.subscription {
                let eligibility = await subscription.isEligibleForIntroOffer
                introductoryOfferEligibility[product.id] = eligibility
            }
        }
    }

    func purchase(product: Product) async {
        do {
            let result = try await product.purchase()
            await handlePurchaseResult(result)
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }

    private func handlePurchaseResult(_ result: Product.PurchaseResult) async {
        switch result {
        case let .success(verification):
            switch verification {
            case let .verified(transaction):
                await completePurchase(transaction)
            case let .unverified(transaction, error):
                print("Transaction unverified: \(transaction), error: \(error.localizedDescription)")
            }
        case .userCancelled:
            print("User cancelled the purchase")
        case .pending:
            print("Purchase is pending")
        @unknown default:
            print("Unknown purchase result")
        }
    }

    private func completePurchase(_ transaction: Transaction) async {
        purchasedProductIdentifiers.insert(transaction.productID)
        isProductPurchased = true
        showPurchaseConfirmation = true
        await transaction.finish()
    }

    private func observeTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                switch result {
                case let .verified(transaction):
                    await completePurchase(transaction)
                case let .unverified(_, error):
                    print("Transaction unverified: \(error.localizedDescription)")
                }
            }
        }
    }

    func checkPurchaseStatus() async {
        isProductPurchased = purchasedProductIdentifiers.contains(IAPConstants.PREMIUM_MONTH_PRODUCT_ID) ||
            purchasedProductIdentifiers.contains(IAPConstants.PREMIUM_YEAR_PRODUCT_ID)
    }

    func restorePurchases() async {
        do {
            for await result in Transaction.currentEntitlements {
                switch result {
                case let .verified(transaction):
                    await completePurchase(transaction)
                case let .unverified(_, error):
                    errorMessage = "Restore unverified: \(error.localizedDescription)"
                }
            }
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    // MARK: - SKPaymentTransactionObserver Methods

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                completeTransaction(transaction)
            case .failed:
                if let error = transaction.error as? SKError {
                    errorMessage = "Transaction failed: \(error.localizedDescription)"
                }
                queue.finishTransaction(transaction)
            default:
                break
            }
        }
    }

    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        purchasedProductIdentifiers.insert(transaction.payment.productIdentifier)
        isProductPurchased = true
        SKPaymentQueue.default().finishTransaction(transaction)
        showPurchaseConfirmation = true
    }
}
