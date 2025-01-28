//
//  Home.swift
//  FlashCards
//
import SwiftUI
import CoreData

struct Home: View {
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [.init(keyPath: \Category.dateCreated, ascending: true)]
    ) private var categories: FetchedResults<Category>
    
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var properties: DragProperties
    
    /// Scroll Properties
    @State private var scrollPosition: ScrollPosition = .init()
    @State private var currentScrollOffset: CGFloat = .zero
    @State private var dragScrollOffset: CGFloat = .zero
    @GestureState private var isActive: Bool = false
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 15) {
                ForEach(categories) { category in
                    CustomDisclosureGroup(category: category)
                }
            }
            .padding(15)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "plus.circle.fill") {
                    for index in 1...5 {
                        let category = Category(context: context)
                        category.dateCreated = .init()
                        
                        let card = FlashCard(context: context)
                        card.title = "Card \(index)"
                        card.category = category
                        
                        try? context.save()
                    }
                }
            }
        }
        .scrollPosition($scrollPosition)
        .onScrollGeometryChange(
            for: CGFloat.self,
            of: { $0.contentOffset.y + $0.contentInsets.top },
            action: { oldValue, newValue in
            currentScrollOffset = newValue
        })
        .allowsTightening(!properties.show) /// disable scrolling when view is dragging
        .contentShape(.rect)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($isActive, body: { _, out, _ in
                        out = true
                })
                .onChanged { value in
                    if dragScrollOffset == 0 {
                        dragScrollOffset = currentScrollOffset
                    }
                    
                    scrollPosition.scrollTo(y: dragScrollOffset + (-value.translation.height))
                },
            /// only enable when drag preview is active
            isEnabled: properties.show
        )
        .onChange(of: isActive) { oldValue, newValue in
            /// Resetting data when the gesture ends
            if !newValue {
                dragScrollOffset = 0
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
