import SwiftUI
import UIKit

// MARK: - Receive View

struct ReceiveView: View {
    @StateObject private var walletManager = WalletManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showCopiedAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: AppConstants.UI.padding) {
                // QR Code
                qrCodeSection

                // Address Section
                addressSection

                // Copy Button
                copyButton

                // Share Button
                shareButton

                Spacer()
            }
            .padding()
            .navigationTitle("Receive SOL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Address copied to clipboard")
            }
        }
    }

    // MARK: - QR Code Section

    private var qrCodeSection: some View {
        VStack(spacing: 16) {
            if let address = walletManager.currentWallet?.publicKey {
                // Generate QR Code
                QRCodeView(url: "solana:\(address)")
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius))
                    .overlay(
                        Text("No wallet")
                            .foregroundColor(.secondary)
                    )
            }
        }
    }

    // MARK: - Address Section

    private var addressSection: some View {
        VStack(spacing: 8) {
            Text("Your Solana Address")
                .font(.headline)

            if let address = walletManager.currentWallet?.publicKey {
                Text(address)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius))
            }
        }
    }

    // MARK: - Copy Button

    private var copyButton: some View {
        Button(action: copyAddress) {
            HStack {
                Image(systemName: "doc.on.doc")
                Text("Copy Address")
            }
            .primaryButtonStyle()
        }
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button(action: shareAddress) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share Address")
            }
            .secondaryButtonStyle()
        }
    }

    // MARK: - Actions

    private func copyAddress() {
        guard let address = walletManager.currentWallet?.publicKey else { return }
        UIPasteboard.general.string = address
        showCopiedAlert = true
    }

    private func shareAddress() {
        guard let address = walletManager.currentWallet?.publicKey else { return }
        let activityVC = UIActivityViewController(
            activityItems: [address],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

// MARK: - QR Code View

struct QRCodeView: UIViewRepresentable {
    let url: String

    func makeUIView(context: Context) -> QRCodeUIView {
        let view = QRCodeUIView()
        view.generateQRCode(from: url)
        return view
    }

    func updateUIView(_ uiView: QRCodeUIView, context: Context) {
        uiView.generateQRCode(from: url)
    }
}

// MARK: - QR Code UIView

class QRCodeUIView: UIView {
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func generateQRCode(from string: String) {
        let data = Data(string.utf8)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")

            if let image = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledImage = image.transformed(by: transform)

                imageView.image = UIImage(ciImage: scaledImage)
            }
        }
    }
}

// MARK: - Preview

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView()
    }
}
