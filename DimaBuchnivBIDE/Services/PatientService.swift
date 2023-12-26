import Foundation


final class PatientService {
    
    private let urlSession = URLSession.shared
    private var lastTask: URLSessionTask?
    
    func fetchAllPatient(page: Int, count: Int, fio: String, phone: String, address: String, completion: @escaping (Result<[PatientResponse], Error>) -> Void) {
        lastTask?.cancel()
        let request = allPatientRequest(page: page, count: count, fio: fio, phone: phone, address: address)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<[PatientResponse], Error>) in
            switch result {
            case .success(let patients):
                completion(.success(patients))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func updatePatient(patientId: Int, patient: PatientRequest, completion: @escaping (Result<PatientResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = updatePatientRequest(patientId: patientId, patient: patient)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<PatientResponse, Error>) in
            switch result {
            case .success(let patient):
                completion(.success(patient))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func addPatient(patient: PatientRequest, completion: @escaping (Result<PatientResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = addPatientRequest(patient: patient)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<PatientResponse, Error>) in
            switch result {
            case .success(let patient):
                completion(.success(patient))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func deletePatient(patientId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        lastTask?.cancel()
        let request = deletePatientRequest(patientId: patientId)
        let task = urlSession.completeTask(for: request, completion: { (result: Result<Bool, Error>) in
            switch result {
            case .success(let complete):
                completion(.success(complete))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
}

private extension PatientService {
    
    func allPatientRequest(page: Int, count: Int, fio: String, phone: String, address: String) -> URLRequest {
        var path = "/patients"
        if fio != "" || phone != "" || address != "" {
            path += "/find?"
            if fio != "" {
                path += "fio=\(fio)&"
            }
            if phone != "" {
                path += "phoneNumber=\(phone)&"
            }
            if address != "" {
                path += "address=\(address)&"
            }
        }
        else {
            path += "?"
        }
        path += "page=\(page)&size=\(count)"
        let request = URLRequest.makeHTTPRequest(
            path: path,
            httpMethod: "GET",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    func updatePatientRequest(patientId: Int , patient: PatientRequest) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/patient/\(patientId)",
            httpMethod: "PUT",
            baseURL: DefaultBaseURL
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData = try? JSONEncoder().encode(patient) {
            request.httpBody = jsonData
        }
        return request
    }
    
    func addPatientRequest(patient: PatientRequest) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/patient",
            httpMethod: "POST",
            baseURL: DefaultBaseURL
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData = try? JSONEncoder().encode(patient) {
            request.httpBody = jsonData
        }
        return request
    }
    
    func deletePatientRequest(patientId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "/patient/\(patientId)",
            httpMethod: "DELETE",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
}
