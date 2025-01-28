//
//  DragPropertiesModel.swift
//  FlashCards

import SwiftUI
import CoreData

class DragProperties: ObservableObject {
    /// Drag Preview Properties
    @Published var show: Bool = false
    @Published var previewImage: UIImage?
    @Published var initialViewLocation: CGPoint = .zero
    @Published var updatedViewLocation: CGPoint = .zero
    
    /// Gesture Properties
    @Published var offset: CGSize = .zero
    @Published var location: CGPoint = .zero
    
    /// Group and section reordering
    @Published var sourceCard: FlashCard?
    @Published var sourceCategory: Category?
    @Published var destinationCategory: Category?
    @Published var isCardSwapped: Bool = false
    
    func changeGroup(_ context: NSManagedObjectContext) {
        guard let sourceCard, let destinationCategory else { return }
        /// insert card at the bottom
        sourceCard.order = destinationCategory.nextOrder
        sourceCard.category = destinationCategory
        try? context.save()
        resetAllProperties()
    }
    
    func swapCardsInSameGroup(_ destinationCard: FlashCard) {
        guard let sourceCard else { return }
        
        let sourceIndex = sourceCard.order
        let destinationIndex = destinationCard.order
        
        /// Swapping orders
        sourceCard.order = destinationIndex
        destinationCard.order = sourceIndex
        
        isCardSwapped = true
    }
    
    func resetAllProperties() {
        self.show = false
        self.previewImage = nil
        self.initialViewLocation = .zero
        self.updatedViewLocation = .zero
        self.offset = .zero
        self.location = .zero
        self.sourceCard = nil
        self.sourceCategory = nil
        self.destinationCategory = nil
        self.isCardSwapped = false
    }
}

extension Category {
    var nextOrder: Int32 {
        let allCards = cards?.allObjects as? [FlashCard] ?? []
        let lastOrderValue = allCards.max(by: { $0.order < $1.order })?.order ?? 0
        return lastOrderValue + 1
    }
}
