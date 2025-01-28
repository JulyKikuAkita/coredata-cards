//
//  FlashCardDragDropView.swift
//  FlashCards

import SwiftUI
import CoreData

struct FlashCardDragDropDemoView: View {
    @StateObject private var dragProperties: DragProperties = .init()
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("Flash Cards")
                .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .topLeading) {
            if let previewImage = dragProperties.previewImage, dragProperties.show {
                Image(uiImage: previewImage)
                    .opacity(0.8)
                    .offset(
                        x: dragProperties.initialViewLocation.x,
                        y: dragProperties.initialViewLocation.y
                    )
                    .offset(dragProperties.offset)
                    .ignoresSafeArea()
            }
        }
    }
}

struct FlashCardDragDropView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    FlashCardDragDropDemoView()
}
