import Foundation


final class VisitService {
    
    private let urlSession = URLSession.shared
    private var lastTask: URLSessionTask?
    
    
    func fetchVisitPatient(patientId: Int, completion: @escaping (Result<[VisitResponse], Error>) -> Void) {
        lastTask?.cancel()
        let request = visitPatientRequest(patientId: patientId)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<[VisitResponse], Error>) in
            switch result {
            case .success(let visit):
                completion(.success(visit))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    
    func addServiceToVisit(serviceId: Int, visitId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        lastTask?.cancel()
        let request = addServiceToVisitRequest(serviceId: serviceId, visitId: visitId)
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
    
    
    func deleteServiceFromVisit(serviceId: Int, visitId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        lastTask?.cancel()
        let request = deleteServiceFromVisitRequest(serviceId: serviceId, visitId: visitId)
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
    
    func fetchVisit(visitId: Int, completion: @escaping (Result<VisitResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = visitRequest(visitId: visitId)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<VisitResponse, Error>) in
            switch result {
            case .success(let visit):
                completion(.success(visit))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    
    func fetchAllVisit(page: Int, count: Int, date: String, completion: @escaping (Result<[VisitResponse], Error>) -> Void) {
        lastTask?.cancel()
        let request = allVisitRequest(page: page, count: count, date: date)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<[VisitResponse], Error>) in
            switch result {
            case .success(let visits):
                completion(.success(visits))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func updateVisit(visitId: Int, visit: VisitRequest, completion: @escaping (Result<VisitResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = updateVisitRequest(visitId: visitId, visit: visit)
        print(visit)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<VisitResponse, Error>) in
            switch result {
            case .success(let visit):
                completion(.success(visit))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func addVisit(visit: VisitRequest, completion: @escaping (Result<VisitResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = addVisitRequest(visit: visit)
        print(visit)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<VisitResponse, Error>) in
            switch result {
            case .success(let visit):
                completion(.success(visit))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func deleteVisit(visitId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        lastTask?.cancel()
        let request = deleteVisitRequest(visitId: visitId)
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

private extension VisitService {
    
    func visitPatientRequest(patientId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "visit/patient/\(patientId)",
            httpMethod: "GET",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    func addServiceToVisitRequest(serviceId: Int, visitId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "visit/\(visitId)/add/service/\(serviceId)",
            httpMethod: "POST",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    func deleteServiceFromVisitRequest(serviceId: Int, visitId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "visit/\(visitId)/delete/service/\(serviceId)",
            httpMethod: "DELETE",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    func visitRequest(visitId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "visit/\(visitId)",
            httpMethod: "GET",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    func allVisitRequest(page: Int, count: Int, date: String) -> URLRequest {
        var path = "/visits"
        if date != "" {
            path += "/find?date=\(date)&"
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
    
    func updateVisitRequest(visitId: Int , visit: VisitRequest) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/visit/\(visitId)",
            httpMethod: "PUT",
            baseURL: DefaultBaseURL
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData = try? JSONEncoder().encode(visit) {
            request.httpBody = jsonData
        }
        return request
    }
    
    func addVisitRequest(visit: VisitRequest) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/visit",
            httpMethod: "POST",
            baseURL: DefaultBaseURL
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData = try? JSONEncoder().encode(visit) {
            request.httpBody = jsonData
        }
        return request
    }
    
    func deleteVisitRequest(visitId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "/visit/\(visitId)",
            httpMethod: "DELETE",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
}

