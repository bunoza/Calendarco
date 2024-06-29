import SwiftUI

struct QRCodeView: View {
    @Environment(\.dismiss) private var dismiss
    let url: URL

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                }
                .padding()
            }

            Spacer()

            Text("Scan to download the calendar file.")
            Text("File is available for 7 days.")

            if let qrCodeImage = generateQRCode(from: url.absoluteString) {
                Image(uiImage: qrCodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Text("Failed to generate QR code")
                Text("URL: \(url.absoluteString)") // Display the URL for debugging
            }
            Spacer()
        }
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")

            guard let outputImage = filter.outputImage else {
                return nil
            }

            let context = CIContext()
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return nil
    }
}
