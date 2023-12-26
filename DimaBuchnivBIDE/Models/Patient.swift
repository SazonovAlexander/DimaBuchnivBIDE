import Foundation


struct PatientRequest: Encodable {
    var fio: String
    var phoneNumber: String
    var address: String
}

struct PatientResponse: Decodable {
    let id: Int
    var fio: String
    var phoneNumber: String
    var address: String
}
