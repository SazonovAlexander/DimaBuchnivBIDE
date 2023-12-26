import Foundation


struct ServiceRequest: Encodable {
    var name: String
    var description: String
    var price: Int
    var departmentId: Int
}


struct ServiceResponse: Decodable {
    var id: Int
    var name: String
    var description: String
    var price: Int
    var department: DepartmentResponse?
}


struct ServiceResultResponse: Decodable {
    var count: Int
    var summa: Int
}
