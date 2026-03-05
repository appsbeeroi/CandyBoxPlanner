import SwiftUI
import Combine

class BoxViewModel: ObservableObject {
    @Published var state: ScreenState
    @Published var model: BoxModel
    @Published var selectedCandyCell: Int?

    init(state: ScreenState = .create, boxId: UUID? = nil) {
        self.state = state
        
        if let id = boxId {
            let m = UDManager<BoxModel>(storageKey: "box")
            self.model = m.findOne(\.id, equals: id)!
        } else {
            self.model = BoxModel(boxName: "", purpose: nil, greedShapeY: 3, greedShapeX: 3, candies: [:], candiesNote: [:])
        }
        self.selectedCandyCell = nil
    }
    
    func save() {
        let m = UDManager<BoxModel>(storageKey: "box")
        m.save(model)
    }
}

enum ScreenState: CaseIterable {
    case create, addCandy, edit
}

struct BoxView: View {
    @ObservedObject var viewModel: BoxViewModel

    var body: some View {
        BgView {
            ZStack {
                VStack {
                    switch viewModel.state {
                    case .create:
                        CreateBoxView(viewModel: viewModel)
                    case .edit:
                        EditView(viewModel: viewModel)
                    case .addCandy:
                        if let cell = viewModel.selectedCandyCell {
                            AddCandy(viewModel: viewModel, cellIndex: cell)
                                .transition(.scale)
                                .zIndex(2)
                        }
                    }
                }
                .padding(.top, 50.fitH)
                .padding(.horizontal)
            }
        }
    }
}
