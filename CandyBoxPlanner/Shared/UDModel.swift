import Foundation

protocol UDModel: Codable, Equatable, Identifiable {
    var id: UUID { get }
}

final class UDManager<Model: UDModel> {
    private let storageKey: String
    private let userDefaults: UserDefaults

    init(storageKey: String, userDefaults: UserDefaults = .standard) {
        self.storageKey = storageKey
        self.userDefaults = userDefaults
    }

    func getAll() -> [Model] {
        guard let data = userDefaults.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([Model].self, from: data)) ?? []
    }

    func save(_ model: Model) {
        var all = getAll()
        if let idx = all.firstIndex(where: { $0.id == model.id }) {
            all[idx] = model
        } else {
            all.append(model)
        }
        saveAll(all)
    }

    func save(_ models: [Model]) {
        var all = getAll()
        for model in models {
            if let idx = all.firstIndex(where: { $0.id == model.id }) {
                all[idx] = model
            } else {
                all.append(model)
            }
        }
        saveAll(all)
    }

    func delete(id: UUID) {
        var all = getAll()
        all.removeAll { $0.id == id }
        saveAll(all)
    }

    func delete(where isIncluded: (Model) -> Bool) {
        let filtered = getAll().filter { !isIncluded($0) }
        saveAll(filtered)
    }

    func clear() {
        userDefaults.removeObject(forKey: storageKey)
    }

    func find<Value: Equatable>(_ keyPath: KeyPath<Model, Value>, equals value: Value) -> [Model] {
        getAll().filter { $0[keyPath: keyPath] == value }
    }

    func findOne<Value: Equatable>(_ keyPath: KeyPath<Model, Value>, equals value: Value) -> Model? {
        getAll().first { $0[keyPath: keyPath] == value }
    }

    private func saveAll(_ models: [Model]) {
        let encoded = try? JSONEncoder().encode(models)
        userDefaults.set(encoded, forKey: storageKey)
    }
}

