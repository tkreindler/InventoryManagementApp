//
//  ImagePicker.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/28/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI

struct ImagePickerAndUploader: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var imageURL: String
    var sourceType: UIImagePickerController.SourceType
    static private let imgur = ImgurUploader(clientID: DebugLoginInfo.imgurClientId)

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerAndUploader>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = self.sourceType
        picker.mediaTypes = ["public.image"]
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerAndUploader>) {

    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerAndUploader
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            
            imgur.upload(info) {
                result in
                switch result {
                    case .success(let response):
                        self.parent.imageURL = response.link.absoluteString
                    case .failure(let error):
                        print("Upload failed: \(error)")
                }
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        init(_ parent: ImagePickerAndUploader) {
            self.parent = parent
        }
    }
}
