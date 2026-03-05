import SwiftUI

struct EditView: View {
    @ObservedObject var viewModel: BoxViewModel
    @Environment(\.dismiss) var dismiss
    @State private var pickerCellIndex: Int?
    @State private var showingSystemPicker: Bool = false
    @State private var showDeleteDialog: Bool = false

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(.backBtn)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40.fitH)
                    }
                    Spacer()
                    Button(action: { viewModel.state = .create }) {
                        Image(.editBtn)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40.fitH)
                    }
                    Button(action: { showDeleteDialog = true }) {
                        Image(.delBtn)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40.fitH)
                    }
                }
                .padding(.top)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)

                ScrollView {
                    HStack {
                        Text(viewModel.model.boxName)
                            .font(.system(size: 40, weight: .medium, design: .serif))
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                    HStack {
                        Spacer()
                        if let purp = currentPurpose {
                            HStack(spacing: 8) {
                                if let emoji = purp.image {
                                    Image(emoji).resizable().scaledToFit().frame(height: 30.fitH)
                                }
                                Text(purp.name)
                                    .font(.system(size: 18, weight: .semibold, design: .serif))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                    ZStack {
                        Image(.boxAsset)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 350.fitH, height: 420.fitH)

                        GeometryReader { geo in
                            let rows = max(1, viewModel.model.greedShapeY)
                            let cols = max(1, viewModel.model.greedShapeX)
                            let gridInset: CGFloat = 16
                            let cellW = (geo.size.width - gridInset * 2) / CGFloat(cols)
                            let cellH = (geo.size.height - gridInset * 2) / CGFloat(rows)

                            VStack(spacing: 0) {
                                ForEach(0..<rows, id: \.self) { y in
                                    HStack(spacing: 0) {
                                        ForEach(0..<cols, id: \.self) { x in
                                            let index = y * cols + x
                                            ZStack {
                                                Button(action: {
                                                    viewModel.selectedCandyCell = index
                                                    viewModel.state = .addCandy
                                                }) {
                                                    Color.white
                                                        .border(Color(white: 0.85), width: 0.6)
                                                }
                                                if let candy = viewModel.model.candies[index] {
                                                    ZStack(alignment: .topTrailing) {
                                                        VStack(spacing: 0) {
                                                            Spacer()
                                                            Image(candy.image)
                                                                .resizable()
                                                                .scaledToFit()
                                                                .padding(.horizontal, 12)
                                                                .padding(.top, 10)
                                                            Text(title(for: candy, note: viewModel.model.candiesNote[index]))
                                                                .font(.system(size: 18, weight: .semibold, design: .serif))
                                                                .foregroundColor(.black)
                                                                .padding(.top, 2)
                                                                .padding(.bottom, 8)
                                                        }
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        .contentShape(Rectangle())
                                                        Button(action: {
                                                            pickerCellIndex = index
                                                            showingSystemPicker = true
                                                        }) {
                                                            HStack(spacing: 3) {
                                                                ForEach(0..<3) { _ in
                                                                    Circle()
                                                                        .fill(Color(white: 0.39))
                                                                        .frame(width: 4, height: 4)
                                                                }
                                                            }
                                                            .frame(width: 34, height: 34) // <= увеличенная область
                                                            .contentShape(Rectangle())
                                                        }
                                                        .padding(.top, 2)
                                                        .padding(.trailing, 2)
                                                        .buttonStyle(PlainButtonStyle())
                                                    }
                                                }
                                            }
                                            .frame(width: cellW, height: cellH)
                                        }
                                    }
                                    .frame(maxHeight: .infinity)
                                }
                            }
                            .frame(
                                width: geo.size.width - gridInset * 2,
                                height: geo.size.height - gridInset * 2,
                                alignment: .center
                            )
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        }
                        .padding(32)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.vertical, 12)

                    VStack(spacing: 18) {
                        CellsStatsView(
                            total: totalCells,
                            counts: flavorsStats.counts
                        )
                        FlavorsPercentageView(
                            total: totalCells,
                            counts: flavorsStats.counts
                        )
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 6)
                    
                    Spacer(minLength: 100.fitH)
                }
            }
            
            if showDeleteDialog {
                VStack {
                    Text("Clear")
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundColor(.black)
                        .padding(.top, 18)
                    HStack(spacing: 24) {
                        Button(action: {
                            showDeleteDialog = false
                        }) {
                            Text("Cancel")
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .foregroundColor(.white)
                                .frame(minWidth: 70)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.blue)
                                )
                        }
                        Button(action: {
                            let manager = UDManager<BoxModel>(storageKey: "box")
                            manager.delete(id: viewModel.model.id)
                            showDeleteDialog = false
                            dismiss()
                        }) {
                            Text("Clear")
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .foregroundColor(.white)
                                .frame(minWidth: 70)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.red)
                                )
                        }
                    }
                    .padding(.bottom, 14)
                    .padding(.top, 7)
                }
                .padding(.horizontal, 34)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.09), radius: 14, x: 0, y: 4)
                )
                .padding(.horizontal, 34)
                .transition(.scale)
                .zIndex(22)
            }
        }
        .confirmationDialog(
            "",
            isPresented: $showingSystemPicker,
            titleVisibility: .visible
        ) {
            if let cell = pickerCellIndex {
                Button("Replace the candy in the slot", role: .none) {
                    viewModel.selectedCandyCell = cell
                    viewModel.state = .addCandy
                    showingSystemPicker = false
                }
                Button("Copy to multiple cells", role: .none) {
                    copyCandy(toNeighborFrom: cell)
                    showingSystemPicker = false
                }
                Button("Clear the cell", role: .destructive) {
                    viewModel.model.candies[cell] = nil
                    viewModel.model.candiesNote[cell] = nil
                    viewModel.save()
                    showingSystemPicker = false
                }
            }
        }
    }

    private var currentPurpose: PurposeModel? {
        guard let id = viewModel.model.purpose else { return nil }
        let allPurposes = UDManager<PurposeModel>(storageKey: "purpose").getAll()
        return allPurposes.first(where: { $0.id == id })
    }

    private func title(for candy: Candy, note: String?) -> String {
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

    private struct FlavorsStats {
        var counts: [Candy: Int]
    }

    private var totalCells: Int {
        max(1, viewModel.model.greedShapeX * viewModel.model.greedShapeY)
    }

    private var flavorsStats: FlavorsStats {
        var dict: [Candy: Int] = [:]
        for flavor in Candy.allCases {
            dict[flavor] = 0
        }
        for c in viewModel.model.candies.values {
            dict[c, default: 0] += 1
        }
        return FlavorsStats(counts: dict)
    }

    private func copyCandy(toNeighborFrom cell: Int) {
        let cols = max(1, viewModel.model.greedShapeX)
        let rows = max(1, viewModel.model.greedShapeY)
        let neighbors = [
            cell + 1,
            cell - 1,
            cell + cols,
            cell - cols
        ].filter { idx in
            idx >= 0 && idx < rows * cols && viewModel.model.candies[idx] == nil
        }
        if let pasteCell = neighbors.first, let candy = viewModel.model.candies[cell] {
            viewModel.model.candies[pasteCell] = candy
            viewModel.model.candiesNote[pasteCell] = viewModel.model.candiesNote[cell]
            viewModel.save()
        }
    }
}

struct CellsStatsView: View {
    var total: Int
    var counts: [Candy: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Total number of cells")
                    .font(.system(size: 19, weight: .medium, design: .serif))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(total)")
                    .font(.system(size: 38, weight: .semibold, design: .serif))
                    .foregroundColor(.black)
            }
            GridLayout(labelSize: 19, valueSize: 22, data: counts.map { ($0.value, $0.key) })
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct FlavorsPercentageView: View {
    var total: Int
    var counts: [Candy: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Percentage of flavors")
                .font(.system(size: 19, weight: .medium, design: .serif))
                .foregroundColor(.gray)
            GridLayout(
                labelSize: 19,
                valueSize: 22,
                data: counts.map {
                    let percent = total != 0 ? Double($0.value) / Double(total) : 0
                    return (String(format: "%.1f%%", percent * 100), $0.key)
                }
            )
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
    }
}

struct GridLayout<T>: View {
    var labelSize: CGFloat
    var valueSize: CGFloat
    var data: [(T, Candy)]

    var body: some View {
        let columns = [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 7) {
            ForEach(Array(Candy.allCases.enumerated()), id: \.element) { i, candy in
                VStack(spacing: 1) {
                    if let value = data.first(where: { $0.1 == candy })?.0 {
                        if let label = value as? Int {
                            Text("\(label)")
                                .font(.system(size: valueSize, weight: .semibold, design: .serif))
                                .foregroundColor(.black)
                        } else if let label = value as? String {
                            Text(label)
                                .font(.system(size: valueSize, weight: .semibold, design: .serif))
                                .foregroundColor(.black)
                        }
                    }
                    Text(candyTitle(candy))
                        .font(.system(size: labelSize, weight: .medium, design: .serif))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func candyTitle(_ candy: Candy) -> String {
        switch candy {
        case .chocolate: return "Chocolate"
        case .caramel: return "Caramel"
        case .nutty: return "Nutty"
        case .withFilling: return "With filling"
        case .fruity: return "Fruity"
        case .jelly: return "Jelly"
        case .other: return "Vanilla"
        }
    }
}
