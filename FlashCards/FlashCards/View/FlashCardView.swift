//
//  FlashCardView.swift
//  FlashCards
//
// When longPress gesture is finished, create a preview image on top of root view
// for an illusion effect that the view is being dragged

import SwiftUI

struct FlashCardView: View {
    var card: FlashCard
    var category: Category
    @EnvironmentObject private var properties: DragProperties
    @Environment(\.managedObjectContext) private var context
    /// View properties
    @GestureState private var isActive: Bool = false
    @State private var haptics: Bool = false
    var body: some View {
        GeometryReader {
            let rect = $0.frame(in: .global)
            let isSwappingInSameGroup = rect.contains(
                properties.location
            ) && properties.sourceCard != card && properties.destinationCategory == nil
            
            Text(card.title ?? "")
                .padding(.horizontal, 15)
                .frame(width: rect.width, height: rect.height, alignment: .leading)
                .background(Color("Background"), in: .rect(cornerRadius: 10))
                .gesture(customGesture(rect: rect))
                .onChange(of: isSwappingInSameGroup) { oldValue, newValue in
                    if newValue {
                        properties.swapCardsInSameGroup(card)
                    }
                }
        }
        .frame(height: 60)
        /// hiding the active dragging view
        .opacity(properties.sourceCard == card ? 0 : 1)
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                haptics.toggle()
            } else {
                handleGestureEnd()
            }
        }
        .sensoryFeedback(.impact, trigger: haptics)
    }
                         
    private func customGesture(rect: CGRect) -> some Gesture {
        LongPressGesture(minimumDuration: 0.3)
            .sequenced(before: DragGesture(coordinateSpace: .global))
            .updating($isActive, body: { _, out, _ in
                    out = true
            })
            .onChanged { value in
                /// when long-press gesture had been completed and drag gesture has been initiated
                if case .second(_, let gesture) = value {
                    handleGestureChange(gesture, rect: rect)
                }
            }
    }
    
    private func handleGestureChange(_ gesture: DragGesture.Value?, rect: CGRect) {
        /// Step 1: create a preview image of the draggin view
        if properties.previewImage == nil {
            properties.show = true
            properties.previewImage = createPreviewImage(rect)
            
            /// Storing source properties
            properties.sourceCard = card
            properties.sourceCategory = category
            properties.initialViewLocation = rect.origin
        }
        
        /// Updating gesture properties
        guard let gesture else { return }
        properties.offset = gesture.translation
        properties.location = gesture.location
        properties.updatedViewLocation = rect.origin
    }
    
    private func handleGestureEnd() {
        withAnimation(.easeInOut(duration: 0.25), completionCriteria: .logicallyComplete) {
            if properties.destinationCategory != nil {
                properties.changeGroup(context)
            } else {
                /// updating view changes
                if properties.updatedViewLocation != .zero {
                    properties.initialViewLocation = properties.updatedViewLocation
                }
                properties.offset = .zero
            }
        } completion: {
            /// saving changes
            if properties.isCardSwapped {
                try? context.save()
            }
            
            properties.resetAllProperties()
        }
    }
    
    private func createPreviewImage(_ rect: CGRect) -> UIImage? {
        let view = HStack {
            Text(card.title ?? "")
                .padding(.horizontal, 15)
                .foregroundStyle(.white)
                .frame(width: rect.width, height: rect.height, alignment: .leading)
                .background(Color("Background"), in: .rect(cornerRadius: 10))
        }
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        
        return renderer.uiImage
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
