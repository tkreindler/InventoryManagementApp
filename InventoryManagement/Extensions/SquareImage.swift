//
//  SquareImageView.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/22/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct SquareImage: View {
    @State var url: String?
    var size: CGFloat
    
    var body: some View {
        HStack() {
            if url != nil {
                WebImage(url: URL(string: url.unsafelyUnwrapped))
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: size, height: size, alignment: .center)
    }
}
