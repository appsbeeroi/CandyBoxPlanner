import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var boxes: [BoxModel] = []
    
    func fetch() {
        let m = UDManager<BoxModel>(storageKey: "box")
        self.boxes = m.getAll()
    }
}

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State var isPresentCreate = false
    @State var presentedBoxId: UUID?

    var body: some View {
        BgView {
            VStack {
                Text("List of boxes")
                    .font(.system(size: 35, weight: .medium, design: .serif))
                    .padding(.top)

                ScrollView {
                    if viewModel.boxes.isEmpty {
                        Button(action: {
                            isPresentCreate = true
                        }) {
                            Image(.empty)
                                .resizable().scaledToFit().padding()
                        }
                    } else {
                        ForEach(viewModel.boxes, id: \.id) { box in
                            Button(action: {
                                presentedBoxId = box.id
                            }) {
                                HStack {
                                    Image(.candy)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 68, height: 68)
                                        .padding(.leading, 8)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(box.date.formatted())
                                            .font(.system(size: 19, weight: .semibold, design: .serif))
                                            .foregroundColor(.gray)
                                        Text(box.boxName)
                                            .font(.system(size: 26, weight: .bold, design: .serif))
                                            .foregroundColor(.black)
                                    }
                                    Spacer()
                                    Text("\(max(1, box.greedShapeX * box.greedShapeY))")
                                        .font(.system(size: 38, weight: .semibold, design: .serif))
                                        .foregroundColor(.black)
                                        .padding(.trailing, 24)
                                }
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 26)
                                        .fill(Color.white.opacity(0.93))
                                )
                                .padding(.horizontal, 5)
                            }
                        }
                        
                        Button(action: {
                            isPresentCreate = true
                        }) {
                            Image(.createBtn)
                                .resizable().scaledToFit().padding()
                        }
                    }
                }
            }
            .padding(.top, 50.fitH)
            .padding(.horizontal)
        }
        .onAppear {
            viewModel.fetch()
        }
        .fullScreenCover(isPresented: $isPresentCreate) {
            BoxView(viewModel: BoxViewModel())
                .onDisappear {
                    viewModel.fetch()
                }
        }
        .fullScreenCover(item: $presentedBoxId) { boxId in
            BoxView(viewModel: BoxViewModel(state: .edit, boxId: boxId))
                .onDisappear {
                    viewModel.fetch()
                }
        }
    }
}

extension Date {
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }
}

extension UUID: Identifiable {
    public var id: UUID { self }
}
