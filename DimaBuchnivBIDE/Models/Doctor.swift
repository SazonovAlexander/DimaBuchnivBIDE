import Foundation


struct DoctorRequest: Encodable {
    var fio: String
    var specalization: String
    var departmentId: Int
}


struct DoctorResponse: Decodable {
    let id: Int
    var fio: String
    var specalization: String
    var department: DepartmentResponse?
}


struct DoctorResultResponse: Decodable {
    var doctor: DoctorResponse
    var count: Int
    var summa: Int
}


