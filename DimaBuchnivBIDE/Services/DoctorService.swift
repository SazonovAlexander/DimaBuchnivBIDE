import Foundation


final class DoctorService {
    
    private let urlSession = URLSession.shared
    private var lastTask: URLSessionTask?
    
    func fetchAllDoctor(page: Int, count: Int, fio: String, spec: String, completion: @escaping (Result<[DoctorResponse], Error>) -> Void) {
        lastTask?.cancel()
        let request = allDoctorRequest(page: page, count: count, fio: fio, spec: spec)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<[DoctorResponse], Error>) in
            switch result {
            case .success(let doctors):
                completion(.success(doctors))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func updateDoctor(doctorId: Int, doctor: DoctorRequest, completion: @escaping (Result<DoctorResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = updateDoctorRequest(doctorId: doctorId, doctor: doctor)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<DoctorResponse, Error>) in
            switch result {
            case .success(let doctor):
                completion(.success(doctor))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func addDoctor(doctor: DoctorRequest, completion: @escaping (Result<DoctorResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = addDoctorRequest(doctor: doctor)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<DoctorResponse, Error>) in
            switch result {
            case .success(let doctor):
                completion(.success(doctor))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func deleteDoctor(doctorId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        lastTask?.cancel()
        let request = deleteDoctorRequest(doctorId: doctorId)
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
    
    func fetchResultDoctor(doctorId: Int, completion: @escaping (Result<DoctorResultResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = resultDoctorRequest(doctorId: doctorId)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<DoctorResultResponse, Error>) in
            switch result {
            case .success(let doctorResult):
                completion(.success(doctorResult))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
}

private extension DoctorService {
    
    func allDoctorRequest(page: Int, count: Int, fio: String, spec: String) -> URLRequest {
        var path = "/doctors"
        if fio != "" || spec != "" {
            path += "/find?"
            if fio != "" {
                path += "fio=\(fio)&"
            }
            if spec != "" {
                path += "specialization=\(spec)&"
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
    
    func updateDoctorRequest(doctorId: Int ,doctor: DoctorRequest) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/doctor/\(doctorId)",
            httpMethod: "PUT",
            baseURL: DefaultBaseURL
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData = try? JSONEncoder().encode(doctor) {
            request.httpBody = jsonData
        }
        return request
    }
    
    func addDoctorRequest(doctor: DoctorRequest) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/doctor",
            httpMethod: "POST",
            baseURL: DefaultBaseURL
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData = try? JSONEncoder().encode(doctor) {
            request.httpBody = jsonData
        }
        return request
    }
    
    func deleteDoctorRequest(doctorId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "/doctor/\(doctorId)",
            httpMethod: "DELETE",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    func resultDoctorRequest(doctorId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "/doctor/result/\(doctorId)",
            httpMethod: "GET",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    
}
