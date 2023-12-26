import Foundation


struct VisitRequest: Encodable {
    var dateVisit: String
    var doctorId: Int
    var patientId: Int
}


struct VisitResponse: Decodable {
    let id: Int
    var dateVisit: String
    var doctor: DoctorResponse
    var patient: PatientResponse
    var services: [ServiceResponse]?
}
