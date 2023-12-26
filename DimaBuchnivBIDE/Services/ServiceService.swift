import Foundation


final class ServiceService {
    
    private let urlSession = URLSession.shared
    private var lastTask: URLSessionTask?
    
    func fetchAllService(page: Int, count: Int, name: String, completion: @escaping (Result<[ServiceResponse], Error>) -> Void) {
        lastTask?.cancel()
        let request = allServiceRequest(page: page, count: count, name: name)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<[ServiceResponse], Error>) in
            switch result {
            case .success(let services):
                completion(.success(services))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func updateService(serviceId: Int, service: ServiceRequest, completion: @escaping (Result<ServiceResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = updateServiceRequest(serviceId: serviceId, service: service)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<ServiceResponse, Error>) in
            switch result {
            case .success(let service):
                completion(.success(service))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func addService(service: ServiceRequest, completion: @escaping (Result<ServiceResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = addServiceRequest(service: service)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<ServiceResponse, Error>) in
            switch result {
            case .success(let service):
                completion(.success(service))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func deleteService(serviceId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        lastTask?.cancel()
        let request = deleteServiceRequest(serviceId: serviceId)
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
    
    func fetchResultService(completion: @escaping (Result<ServiceResultResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = resultServiceRequest()
        let task = urlSession.objectTask(for: request, completion: { (result: Result<ServiceResultResponse, Error>) in
            switch result {
            case .success(let serviceResult):
                completion(.success(serviceResult))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
}

private extension ServiceService {
    
    func allServiceRequest(page: Int, count: Int, name: String) -> URLRequest {
        var path = "/services"
        if name != "" {
            path += "/find?name=\(name)&"
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
    
    func updateServiceRequest(serviceId: Int , service: ServiceRequest) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/service/\(serviceId)",
            httpMethod: "PUT",
            baseURL: DefaultBaseURL
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData = try? JSONEncoder().encode(service) {
            request.httpBody = jsonData
        }
        return request
    }
    
    func addServiceRequest(service: ServiceRequest) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/service",
            httpMethod: "POST",
            baseURL: DefaultBaseURL
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData = try? JSONEncoder().encode(service) {
            request.httpBody = jsonData
        }
        return request
    }
    
    func deleteServiceRequest(serviceId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "/service/\(serviceId)",
            httpMethod: "DELETE",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    func resultServiceRequest() -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "/service/result",
            httpMethod: "GET",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    
}
