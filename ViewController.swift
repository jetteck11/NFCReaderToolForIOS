import UIKit
import CoreNFC

class ViewController: UIViewController, NFCTagReaderSessionDelegate {
    var session: NFCTagReaderSession?

    // UI
    let scanButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Scanner une puce NFC", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        b.layer.cornerRadius = 10
        b.setTitleColor(.white, for: .normal)
        b.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        return b
    }()

    let infoTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        tv.text = "Appuyez sur « Scanner une puce NFC » pour commencer."
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        navigationItem.title = "NFC Reader Tool"

        view.addSubview(scanButton)
        view.addSubview(infoTextView)

        scanButton.addTarget(self, action: #selector(startSession), for: .touchUpInside)

        NSLayoutConstraint.activate([
            scanButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoTextView.topAnchor.constraint(equalTo: scanButton.bottomAnchor, constant: 20),
            infoTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            infoTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc func startSession() {
        guard NFCTagReaderSession.readingAvailable else {
            showMessage("NFC non disponible sur cet appareil.")
            return
        }
        session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self)
        session?.alertMessage = "Approche une puce NFC ISO 14443/15693"
        session?.begin()
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // session active
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.showMessage("Session invalide: \(error.localizedDescription)")
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let first = tags.first else { return }

        // Connect au tag et récupère l'identifier (Data)
        session.connect(to: first) { err in
            if let err = err {
                session.invalidate(errorMessage: "Erreur de connexion: \(err.localizedDescription)")
                return
            }

            var idData: Data?
            var tagType = "Unknown"
            var extraInfo = [String]()

            switch first {
            case .miFare(let m):
                idData = m.identifier
                tagType = "MiFare / ISO14443"
                // MiFare specific: can read mifare type and capacity via additional commands (not done here)
            case .iso7816(let iso):
                idData = iso.identifier
                tagType = "ISO7816 (APDU)"
                extraInfo.append("AID(s): \(iso.initialSelectedAID ?? "—")")
            case .iso15693(let i15693):
                idData = i15693.identifier
                tagType = "ISO15693"
                extraInfo.append("IC Manufacturer Code: \(i15693.icManufacturerCode)")
            case .feliCa(let f):
                idData = f.currentIDm
                tagType = "FeliCa"
            @unknown default:
                idData = nil
            }

            guard let id = idData else {
                session.invalidate(errorMessage: "Impossible d'obtenir l'identifiant du tag.")
                return
            }

            // Build outputs (safe, reliable info only)
            let hex = id.map { String(format: "%02X", $0) }.joined()
            let length = id.count
            let decimalBE = id.reduce(0) { (acc: UInt64, byte: UInt8) -> UInt64 in
                return (acc << 8) | UInt64(byte)
            }
            let reversed = Data(id.reversed())
            let decimalRev = reversed.reduce(0) { (acc: UInt64, byte: UInt8) -> UInt64 in
                return (acc << 8) | UInt64(byte)
            }

            var info = [String]()
            info.append("Type: \(tagType)")
            info.append("UID (hex): \(hex)")
            info.append("UID longueur (bytes): \(length)")
            info.append("UID decimal (big-endian): \(decimalBE)")
            info.append("UID decimal (reversed bytes): \(decimalRev)")

            if !extraInfo.isEmpty {
                info.append("") // blank line
                info.append(contentsOf: extraInfo)
            }

            DispatchQueue.main.async {
                self.infoTextView.text = info.joined(separator: "\n")
            }

            session.invalidate()
        }
    }

    func showMessage(_ s: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "NFC Reader Tool", message: s, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
}
