//
//  OtherView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 8/2/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI
import PDFKit
import SwiftKeychainWrapper

struct OtherView: View {
    @ObservedObject var httpManager: HttpManager
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button(action: {
                    // remove saved stuff from keychain
                    if !KeychainWrapper.standard.removeObject(forKey: "com.tristankreindler.InventoryManagement.username") {
                        print("Failed removing username in keychain")
                    }
                    if !KeychainWrapper.standard.removeObject(forKey: "com.tristankreindler.InventoryManagement.password") {
                        print("Failed removing password in keychain")
                    }
                    self.httpManager.loginStatus = .NotAttempted
                }) {
                    Text("Logout")
                }
                Spacer()
                Button(action: {
                    let printInfo = UIPrintInfo(dictionary:nil)
                    printInfo.outputType = UIPrintInfo.OutputType.general
                    printInfo.jobName = "My Print Job"

                    // Set up print controller
                    let printController = UIPrintInteractionController.shared
                    printController.printInfo = printInfo

                    // Assign a UIImage version of my UIView as a printing iten
                    printController.printingItem = OtherView.makePDF()
                    
                    // Do it
                    printController.present(animated: true, completionHandler: nil)
                }) {
                    Text("Create QR Codes")
                }
                Spacer()
            }
        }
    }
    
    static private func makePDF() -> URL {
        let format = UIGraphicsPDFRendererFormat()

        let pageWidth: CGFloat = 8.5 * 72.0
        let pageHeight: CGFloat = 11 * 72.0
        
        // allow for 0.2 inch margin
        let marginAmount: CGFloat = 0.2 * 72.0;
        
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        // randomly generate all of the qr codes
        let images: [(UIImage, String)] = (0..<49).map { _ in
            let uuid = UUID()
            
            let data = uuid.uuidString.data(using: String.Encoding.utf8)
            
            let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
            
            qrFilter.setValue(data, forKey: "inputMessage")
            // set high error resilience
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")
            let transform = CGAffineTransform(scaleX: 2, y: 2)

            let output = qrFilter.outputImage!.transformed(by: transform)
            
            let indented = NSMutableString(string: uuid.uuidString)
            indented.insert("\n", at: 18)
            
            return (UIImage(ciImage: output), indented as String)
        }

        // 3
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        // 4
        let data = renderer.pdfData { (context) in
            // start the first page
            context.beginPage()
            
            var drawingPoint = CGPoint(x: marginAmount, y: marginAmount)
            
            for (index, (qrImage, label)) in images.enumerated() {
                qrImage.draw(at: drawingPoint)
                
                let caption = NSAttributedString(string: label, attributes: [
                    NSAttributedString.Key.font: UIFont.monospacedSystemFont(ofSize: 6, weight: .regular)
                ])
                
                caption.draw(at : CGPoint(x: drawingPoint.x, y: drawingPoint.y + qrImage.size.height))
                
                if (index + 1) % 7 != 0 {
                    drawingPoint.x += qrImage.size.width + 15
                } else {
                    drawingPoint.y += qrImage.size.height + 42
                    drawingPoint.x = marginAmount
                }
            }
        }
        
        var tempFileURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                            isDirectory: true)
        tempFileURL.appendPathComponent("\(UUID().uuidString).pdf", isDirectory: false)
        
        try! data.write(to: tempFileURL)
        
        return tempFileURL
    }
}


struct PrintingView: View {
    var body: some View {
        VStack {
            Text("Test")
        }
        .onAppear() {
            
        }
    }
}

struct RandomQRCodePDFView: UIViewRepresentable {
    

    // make a ui out of a random pdf
    func makeUIView(context: UIViewRepresentableContext<RandomQRCodePDFView>) -> RandomQRCodePDFView.UIViewType {
        // Create a `PDFView` and set its `PDFDocument`.
        let pdfView = PDFView()
        //pdfView.document = RandomQRCodePDFView.makePDF()
        return pdfView
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<RandomQRCodePDFView>) {
        // Update the view.
    }
}
