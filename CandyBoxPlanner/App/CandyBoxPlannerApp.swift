import SwiftUI

@main
struct CandyBoxPlannerApp: App {
    init() {
        let m = UDManager<PurposeModel>(storageKey: "purpose")
        if m.getAll().isEmpty {
            let m1 = PurposeModel(name: "Gift", image: "gift")
            let m2 = PurposeModel(name: "Personal assortment", image: "personal")
            let m3 = PurposeModel(name: "Holiday box", image: "holiday")
            m.save(m1); m.save(m2); m.save(m3)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LoadingScreen()
        }
    }
}
