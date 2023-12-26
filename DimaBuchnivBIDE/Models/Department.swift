import Foundation


struct DepartmentRequest: Encodable {
    var name: String
    var address: String
}


struct DepartmentResponse: Decodable {
    var id: Int
    var name: String
    var address: String
    var doctors: [DoctorResponse]?
    var services: [ServiceResponse]?
}


struct DepartmentResultResponse: Decodable {
    var count: Int
    var summa: Int
}
