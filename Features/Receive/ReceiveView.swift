import SwiftUI
import UIKit

// MARK: - Receive View

struct ReceiveView: View {
    @StateObject private var walletManager = WalletManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showCopiedAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Theme.bg.ignoresSafeArea()

                // Ambient glow
                RadialGradient(
                    colors: [Theme.accent.opacity(0.05), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 250
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // QR Code
                        qrCodeSection

                        // Address Section
                        addressSection

                        // Buttons
                        VStack(spacing: 10) {
                            copyButton
                            shareButton
                        }

                        Spacer()
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Receive SOL")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.textSecondary)
                }
            }
            .alert("Copied!", isPresented: $showCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Address copied to clipboard")
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - QR Code Section

    private var qrCodeSection: some View {
        VStack(spacing: 16) {
            if let address = walletManager.currentWallet?.publicKey {
                // QR Code container
                QRCodeView(url: "solana:\(address)")
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Theme.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: Theme.accent.opacity(0.1), radius: 20, y: 10)
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Theme.card)
                    .frame(width: 200, height: 200)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 32))
                                .foregroundColor(Theme.textTertiary)
                            Text("No wallet")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.textSecondary)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Theme.cardBorder, lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Address Section

    private var addressSection: some View {
        VStack(spacing: 12) {
            Text("Your Solana Address")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            if let address = walletManager.currentWallet?.publicKey {
                Text(address)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.cardBorder, lineWidth: 1)
                    )
            }
        }
    }

    // MARK: - Copy Button

    private var copyButton: some View {
        Button(action: copyAddress) {
            HStack {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14, weight: .semibold))
                Text("Copy Address")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(Theme.bg)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.accent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button(action: shareAddress) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .semibold))
                Text("Share Address")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(Theme.text)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
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
        imageView.contentMode = .scaleAspectFit
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
            .preferredColorScheme(.dark)
    }
}
