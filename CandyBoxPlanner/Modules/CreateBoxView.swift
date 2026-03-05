import SwiftUI

struct CreateBoxView: View {
    @ObservedObject var viewModel: BoxViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showPurposePicker = false
    @State private var showCustomPurpose = false
    @State private var purposes: [PurposeModel] = []

    var body: some View {
        BgView {
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
                        Text("Create Box")
                            .font(.system(size: 26, weight: .medium, design: .serif))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer()
                        Button(action: {
                            viewModel.save()
                            viewModel.state = .edit
                        }) {
                            Image(.confirmBtn)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40.fitH)
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            Image(.candy)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 40)
                                .padding(.top, 4)

                            card {
                                HStack {
                                    Text("Purpose")
                                        .font(.system(size: 20, weight: .semibold, design: .serif))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    Spacer(minLength: 8)
                                    Button(action: {
                                        reloadPurposes()
                                        showPurposePicker = true
                                    }) {
                                        Text(purposeName ?? "Choose")
                                            .font(.system(size: 18, weight: .bold, design: .serif))
                                            .foregroundStyle(.black)
                                            .padding(.vertical, 7)
                                            .padding(.horizontal, 16)
                                            .background(
                                                Capsule().fill(Color(red: 1.0, green: 0.0, blue: 0.85))
                                            )
                                    }
                                }
                            }

                            card {
                                TextField("Box Name", text: $viewModel.model.boxName)
                                    .font(.system(size: 22, weight: .semibold, design: .serif))
                                    .foregroundStyle(Color.black.opacity(0.85))
                                    .textInputAutocapitalization(.words)
                                    .disableAutocorrection(true)
                            }

                            card {
                                VStack(spacing: 6) {
                                    Text("Number of cells")
                                        .font(.system(size: 14, weight: .semibold, design: .serif))
                                        .foregroundStyle(.gray.opacity(0.55))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)

                                    Text("\(max(1, viewModel.model.greedShapeX * viewModel.model.greedShapeY))")
                                        .font(.system(size: 38, weight: .semibold, design: .serif))
                                        .foregroundStyle(Color.black.opacity(0.85))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                }
                                .frame(maxWidth: .infinity)
                            }

                            card {
                                VStack(spacing: 8) {
                                    Text("Grid Shape")
                                        .font(.system(size: 14, weight: .semibold, design: .serif))
                                        .foregroundStyle(.gray.opacity(0.55))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    HStack {
                                        stepper(value: $viewModel.model.greedShapeY)
                                        Divider()
                                            .overlay(Color.black.opacity(0.2))
                                        stepper(value: $viewModel.model.greedShapeX)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }

                if showPurposePicker {
                    Color.clear
                        .ignoresSafeArea()
                        .onTapGesture { showPurposePicker = false }
                    PurposePickerOverlay(
                        allPurposes: purposes,
                        selectedPurposeId: viewModel.model.purpose,
                        onSelect: { m in
                            viewModel.model.purpose = m.id
                            showPurposePicker = false
                        },
                        onOther: {
                            showCustomPurpose = true
                        },
                        onClose: {
                            showPurposePicker = false
                        }
                    )
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut, value: showPurposePicker)
                }

                if showCustomPurpose {
                    CreateCustomPurposeOverlay(
                        onCancel: { showCustomPurpose = false },
                        onSave: { m in
                            let um = UDManager<PurposeModel>(storageKey: "purpose")
                            um.save(m)
                            viewModel.model.purpose = m.id
                            reloadPurposes()
                            showCustomPurpose = false
                            showPurposePicker = true
                        }
                    )
                    .shadow(radius: 20)
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut, value: showCustomPurpose)
                }
            }
        }
        .onAppear(perform: reloadPurposes)
    }

    private var purposeName: String? {
        guard let id = viewModel.model.purpose else { return nil }
        return purposes.first(where: { $0.id == id })?.name
    }

    private func reloadPurposes() {
        let um = UDManager<PurposeModel>(storageKey: "purpose")
        purposes = um.getAll()
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
    }

    private func stepper(value: Binding<Int>) -> some View {
        HStack(spacing: 10) {
            Button(action: { value.wrappedValue = max(1, value.wrappedValue - 1) }) {
                Text("−")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .padding(2)
            }
            Text("\(value.wrappedValue)")
                .font(.system(size: 36, weight: .semibold, design: .serif))
                .foregroundStyle(Color.black.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(minWidth: 30)
            Button(action: { value.wrappedValue = min(20, value.wrappedValue + 1) }) {
                Text("+")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .padding(2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PurposePickerOverlay: View {
    let allPurposes: [PurposeModel]
    let selectedPurposeId: UUID?
    let onSelect: (PurposeModel) -> Void
    let onOther: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Purpose")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                Spacer()
                Spacer().frame(width: 22)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)

            ScrollView {
                VStack(spacing: 1) {
                    ForEach(allPurposes, id: \.id) { m in
                        Button(action: {
                            onSelect(m)
                        }) {
                            HStack(spacing: 16) {
                                if let img = m.image {
                                    Image(img)
                                        .resizable().scaledToFit().frame(height: 30.fitH)
                                }
                                Text(m.name)
                                    .font(.system(size: 22, weight: .semibold, design: .serif))
                                    .foregroundColor(.black)
                                Spacer()
                                if selectedPurposeId == m.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.pink)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                        }
                        .background(Color.clear)
                        Divider()
                    }
                    Button(action: onOther) {
                        HStack(spacing: 16) {
                            Text("⋯")
                                .font(.system(size: 22))
                            Text("Other")
                                .font(.system(size: 22, weight: .semibold, design: .serif))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.97))
                )
                .padding(10)
            }
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white)
                .shadow(radius: 30, y: 18)
        )
        .padding(.horizontal, 22)
        .padding(.vertical, 60)
    }
}

struct CreateCustomPurposeOverlay: View {
    @State private var text: String = ""
    var onCancel: () -> Void
    var onSave: (PurposeModel) -> Void

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Button(action: { onCancel() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Purpose")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    let model = PurposeModel(name: text.isEmpty ? "Purpose" : text, image: nil)
                    onSave(model)
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 16)
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.18), lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.94)))
                .overlay(
                    TextField("Purpose", text: $text)
                        .font(.system(size: 21, weight: .medium, design: .serif))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .foregroundColor(.gray.opacity(0.7)),
                    alignment: .leading
                )
                .frame(height: 44)
                .padding(.horizontal, 16)
        }
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.97))
        )
        .padding(42)
    }
}
