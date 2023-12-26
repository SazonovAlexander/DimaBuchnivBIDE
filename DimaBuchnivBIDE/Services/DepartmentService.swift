import Foundation


final class DepartmentService {
    
    private let urlSession = URLSession.shared
    private var lastTask: URLSessionTask?
    
    func fetchAllDepartment(page: Int, count: Int, completion: @escaping (Result<[DepartmentResponse], Error>) -> Void) {
        lastTask?.cancel()
        let request = allDepartmentRequest(page: page, count: count)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<[DepartmentResponse], Error>) in
            switch result {
            case .success(let departments):
                completion(.success(departments))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func updateDepartment(departmentId: Int, department: DepartmentRequest, completion: @escaping (Result<DepartmentResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = updateDepartmentRequest(departmentId: departmentId, department: department)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<DepartmentResponse, Error>) in
            switch result {
            case .success(let department):
                completion(.success(department))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func addDepartment(department: DepartmentRequest, completion: @escaping (Result<DepartmentResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = addDepartmentRequest(department: department)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<DepartmentResponse, Error>) in
            switch result {
            case .success(let department):
                completion(.success(department))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
    
    func deleteDepartment(departmentId: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        lastTask?.cancel()
        let request = deleteDepartmentRequest(departmentId: departmentId)
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
    
    func fetchResultDepartment(departmentId: Int, completion: @escaping (Result<DepartmentResultResponse, Error>) -> Void) {
        lastTask?.cancel()
        let request = resultDepartmentRequest(departmentId: departmentId)
        let task = urlSession.objectTask(for: request, completion: { (result: Result<DepartmentResultResponse, Error>) in
            switch result {
            case .success(let departmentResult):
                completion(.success(departmentResult))
            case .failure(let error):
                completion(.failure(error))
            }
        })
        lastTask = task
        task.resume()
    }
}

private extension DepartmentService {
    
    func allDepartmentRequest(page: Int, count: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "/departments?page=\(page)&size=\(count)",
            httpMethod: "GET",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    func updateDepartmentRequest(departmentId: Int ,department: DepartmentRequest) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/department/\(departmentId)",
            httpMethod: "PUT",
            baseURL: DefaultBaseURL
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData = try? JSONEncoder().encode(department) {
            request.httpBody = jsonData
        }
        return request
    }
    
    func addDepartmentRequest(department: DepartmentRequest) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/departments",
            httpMethod: "POST",
            baseURL: DefaultBaseURL
        )
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonData = try? JSONEncoder().encode(department) {
            request.httpBody = jsonData
        }
        return request
    }
    
    func deleteDepartmentRequest(departmentId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "/department/\(departmentId)",
            httpMethod: "DELETE",
            baseURL: DefaultBaseURL
        )
        return request
    }
    
    func resultDepartmentRequest(departmentId: Int) -> URLRequest {
        let request = URLRequest.makeHTTPRequest(
            path: "/department/result/\(departmentId)",
            httpMethod: "GET",
            baseURL: DefaultBaseURL
        )
        return request
    }
}
