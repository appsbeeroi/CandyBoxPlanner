import Foundation

struct BoxModel: UDModel {
    var id = UUID()
    var boxName: String
    var purpose: UUID?
    var greedShapeY: Int
    var greedShapeX: Int
    var candies: [Int: Candy]
    var candiesNote: [Int: String]
    var date = Date()
}

enum Candy: String, CaseIterable, Codable {
    case chocolate, caramel, nutty, withFilling, fruity, jelly, other
    
    var image: String {
        return self.rawValue
    }
}

struct PurposeModel: UDModel {
    var id = UUID()
    var name: String
    var image: String?
}
