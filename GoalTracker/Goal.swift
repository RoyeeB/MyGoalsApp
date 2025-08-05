import Foundation
import FirebaseFirestore

struct Goal: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var isCompleted: Bool
    var isQuantitative: Bool
    var targetAmount: Int?
    var currentAmount: Int?
    var dueDate: Date
    var userId: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isCompleted
        case isQuantitative
        case targetAmount
        case currentAmount
        case dueDate
        case userId
    }
}
