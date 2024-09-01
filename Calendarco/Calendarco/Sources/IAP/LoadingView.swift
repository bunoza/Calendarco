import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(2.0)
                .padding()

            Text("Checking your subscription...")
                .font(.headline)
                .padding(.top, 20)
        }
    }
}

#Preview {
    LoadingView()
}
