import SwiftUI

struct AddCandy: View {
    @ObservedObject var viewModel: BoxViewModel
    var cellIndex: Int
    @State private var selected: Candy?
    @State private var note: String = ""

    var body: some View {
        VStack {
            HStack {
                Button(action: { viewModel.state = .edit }) {
                    Image(.backBtn)
                        .resizable()
                        .scaledToFit()
                }
                Spacer()
                Text("Add candy")
                    .font(.system(size: 32, weight: .medium, design: .serif))
                    .padding(.top, 7)
                Spacer()
                Button(action: {
                    if let selected = selected {
                        viewModel.model.candies[cellIndex] = selected
                        viewModel.model.candiesNote[cellIndex] = note
                        viewModel.save()
                        viewModel.state = .edit
                    }
                }) {
                    Image(.confirmBtn)
                        .resizable()
                        .scaledToFit()
                }
                .disabled(selected == nil)
            }
            .aspectRatio(9, contentMode: .fit)
            
            Spacer(minLength: 18)
            
            let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(Candy.allCases, id: \.self) { candy in
                    Button(action: { selected = candy }) {
                        VStack(spacing: 5) {
                            Image(candy.image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 54)
                            Text(candyTitle(candy))
                                .font(.system(size: 18, weight: .semibold, design: .serif))
                                .foregroundColor(.black)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(candy == selected ? Color.orange : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 22)
            
            Spacer(minLength: 10)
            
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .overlay(
                    TextField("Note", text: $note)
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .foregroundColor(.black)
                )
                .frame(height: 54)
                .padding(.horizontal, 8)
            
            Spacer()
        }
        .onAppear {
            if let candy = viewModel.model.candies[cellIndex] {
                selected = candy
                note = viewModel.model.candiesNote[cellIndex] ?? ""
            } else {
                selected = nil
                note = ""
            }
        }
        .padding(.vertical, 18)
        .background(Color.clear)
    }
    
    private func candyTitle(_ candy: Candy) -> String {
        switch candy {
        case .chocolate: return "Chocolate"
        case .caramel: return "Caramel"
        case .nutty: return "Nutty"
        case .withFilling: return "With filling"
        case .fruity: return "Fruity"
        case .jelly: return "Jelly"
        case .other: return "Other"
        }
    }
}
