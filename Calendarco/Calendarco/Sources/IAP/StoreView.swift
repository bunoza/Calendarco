import SwiftUI

struct StoreView: View {
    @StateObject private var viewModel: StoreViewModel

    init(viewModel: @escaping @autoclosure () -> StoreViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(spacing: 20) {
            // Display the app icon
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                .padding(.top, 50)

            Text("Unlock access to Calendarco!")
                .font(.system(size: 28, weight: .bold))
                .padding()

            if viewModel.isLoading {
                ProgressView("Loading...")
                    .padding()
            } else {
                // Product list with custom background
                List(viewModel.products) { product in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(product.displayName)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)

                            Text(product.description)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)

                            // Show introductory offer only for the monthly plan
                            if product.id == IAPConstants.PREMIUM_MONTH_PRODUCT_ID,
                               let introductoryOfferEligible = viewModel.introductoryOfferEligibility[product.id],
                               introductoryOfferEligible
                            {
                                Text("Get a 3-day free trial!")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.orange)
                            }

                            Text("\(product.displayPrice)")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.green)
                        }

                        Spacer()

                        // Display purchase button or "Purchased" text
                        if viewModel.purchasedProductIdentifiers.contains(product.id) {
                            Text("Purchased")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.gray)
                        } else {
                            Button(action: {
                                Task {
                                    await viewModel.purchase(product: product)
                                }
                            }) {
                                Text("Buy")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding()
                                    .frame(minWidth: 80)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)

                // Restore purchases button
                Button(action: {
                    Task {
                        await viewModel.restorePurchases()
                    }
                }) {
                    Text("Restore Purchases")
                        .font(.system(size: 18, weight: .bold))
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)

                Spacer()
            }
        }
        .alert(item: $viewModel.errorMessage) { error in
            Alert(title: Text("Error"), message: Text(error), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $viewModel.showPurchaseConfirmation) {
            VStack {
                Text("Thank you for your purchase!")
                    .font(.largeTitle)
                    .padding()
                Text("You've successfully unlocked Calendarco features.")
                    .font(.title2)
                    .padding()
                Button("OK") {
                    viewModel.showPurchaseConfirmation = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

#Preview {
    StoreView(viewModel: StoreViewModel())
}
