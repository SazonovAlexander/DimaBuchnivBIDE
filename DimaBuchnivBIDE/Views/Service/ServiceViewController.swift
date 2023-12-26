import UIKit


final class ServiceViewController: UIViewController {
    //MARK: - Private Properties
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let resultButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black
        return tableView
    }()
    
    private let searchNameTextField: UITextField  = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "Название", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.layer.cornerRadius = 10
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clipsToBounds = true
        return textField
    }()
    
    private let seaerchButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Найти", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()
    
    var cellDataSource: [ServiceResponse] = []
    private let serviceService = ServiceService()
    private var selectedDepartment: DepartmentResponse?
    private var currentAlert: UIAlertController?
    private var currentPage = 0
    private let itemsPerPage = 20
    private var inLoad = false
    private var isEnd = false {
        didSet {
            if isEnd == false {
                currentPage = 0
                cellDataSource = []
                getService()
            }
        }
    }
    //MARK: - Override methods
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
}


//MARK: - Private Methods
private extension ServiceViewController {
    
    func setupView() {
        view.backgroundColor = .black
        setupTableView()
        addSubviews()
        activateConstraints()
        getService()
        addAction()
    }
    
    func addAction() {
        addButton.addTarget(self, action: #selector(Self.didTapAddButton), for: .touchUpInside)
        seaerchButton.addTarget(self, action: #selector(Self.didChangeFilter), for: .touchUpInside)
        resultButton.addTarget(self, action: #selector(Self.resultService), for: .touchUpInside)
    }
    
    @objc
    func didChangeFilter() {
        updateListService()
    }
    
    @objc
    func didTapAddButton() {
        let alert = UIAlertController(title: "Услгуа", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Название"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Описание"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Цена"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Департамент"
            textField.addTarget(self, action: #selector(Self.didSelectRepartment), for: .editingDidBegin)
        }
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak alert, weak self] _ in
            if let self,
               let name = alert?.textFields?[0].text,
               let desc = alert?.textFields?[1].text,
               let price = Int(alert?.textFields?[2].text ?? "0"),
               let department = selectedDepartment
            {
                let service = ServiceRequest(name: name, description: desc, price: price, departmentId: department.id)
                self.serviceService.addService(service: service, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        selectedDepartment = nil
                        updateListService()
                    case .failure(let error):
                        print(error.localizedDescription)
                        let alert = UIAlertController(title: "Что-то пошло не так(", message: error.localizedDescription, preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(alertAction)
                        self.present(alert, animated: true)
                    }
                })
            }
        }
        alert.addAction(save)
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(cancel)
        currentAlert = alert
        self.present(alert, animated: true)
    }
    
    func getService() {
        inLoad.toggle()
        serviceService.fetchAllService(page: currentPage, count: itemsPerPage, name: searchNameTextField.text ?? "", completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let services):
                if !services.isEmpty {
                    currentPage += 1
                }
                else {
                    isEnd = true
                }
                self.cellDataSource.append(contentsOf: services)
                inLoad.toggle()
                self.tableView.reloadData()
            case .failure(let error):
                inLoad.toggle()
                let alert = UIAlertController(title: "Что-то пошло не так(", message: error.localizedDescription, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(alertAction)
                self.present(alert, animated: true)
            }
        })
    }
    
    func updateService(service: ServiceResponse) {
        selectedDepartment = service.department
        let alert = UIAlertController(title: "Услгуа", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Название"
            textField.text = service.name
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Описание"
            textField.text = service.description
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Цена"
            textField.text = "\(service.price)"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Департамент"
            textField.text = service.department?.name ?? ""
            textField.addTarget(self, action: #selector(Self.didSelectRepartment), for: .editingDidBegin)
        }
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak alert, weak self] _ in
            if let self,
               let name = alert?.textFields?[0].text,
               let desc = alert?.textFields?[1].text,
               let price = Int(alert?.textFields?[2].text ?? "0"),
               let department = selectedDepartment
            {
                let newService = ServiceRequest(name: name, description: desc, price: price, departmentId: department.id)
                self.serviceService.updateService(serviceId: service.id, service: newService, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        selectedDepartment = nil
                        updateListService()
                    case .failure(let error):
                        print(error.localizedDescription)
                        let alert = UIAlertController(title: "Что-то пошло не так(", message: error.localizedDescription, preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(alertAction)
                        self.present(alert, animated: true)
                    }
                })
            }
        }
        alert.addAction(save)
        let delete = UIAlertAction(title: "Удалить", style: .default) { [weak self] _ in
            if let self
            {
                self.serviceService.deleteService(serviceId: service.id, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        selectedDepartment = nil
                        updateListService()
                    case .failure(let error):
                        print(error.localizedDescription)
                        let alert = UIAlertController(title: "Что-то пошло не так(", message: error.localizedDescription, preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(alertAction)
                        self.present(alert, animated: true)
                    }
                })
            }
        }
        alert.addAction(delete)
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(cancel)
        currentAlert = alert
        self.present(alert, animated: true)
    }
    
    func updateListService() {
        isEnd = false
    }
    
    func addSubviews(){
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(seaerchButton)
        view.addSubview(searchNameTextField)
        view.addSubview(resultButton)
    }
    
    func activateConstraints(){
        NSLayoutConstraint.activate([
            searchNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            seaerchButton.topAnchor.constraint(equalTo: searchNameTextField.bottomAnchor, constant: 10),
            seaerchButton.leadingAnchor.constraint(equalTo: searchNameTextField.leadingAnchor),
            seaerchButton.trailingAnchor.constraint(equalTo: searchNameTextField.trailingAnchor),
            resultButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            resultButton.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: 20),
            resultButton.widthAnchor.constraint(equalToConstant: 44),
            addButton.topAnchor.constraint(equalTo: seaerchButton.bottomAnchor, constant: 10),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            tableView.topAnchor.constraint(equalTo: addButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        registerCell()
    }
    
    func registerCell() {
        tableView.register(ServiceViewCell.self, forCellReuseIdentifier: ServiceViewCell.reuseIdentifier)
    }
    
    @objc
    func resultService() {
        inLoad.toggle()
        serviceService.fetchResultService(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let departmentResult):
                let alert = UIAlertController(title: "Статистика услуг",
                                              message: "Количество: \(departmentResult.count)\nСумма: \(departmentResult.summa)",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ОК", style: .cancel))
                self.present(alert, animated: true)
                inLoad.toggle()
            case .failure(let error):
                inLoad.toggle()
                let alert = UIAlertController(title: "Что-то пошло не так(", message: error.localizedDescription, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(alertAction)
                self.present(alert, animated: true)
            }
        })
    }
    
    @objc
    func didSelectRepartment() {
        let selectDepartmentViewController = SelectDepartmentViewController()
        selectDepartmentViewController.delegate = self
        selectDepartmentViewController.modalPresentationStyle = .pageSheet
        currentAlert?.present(selectDepartmentViewController, animated: true)
    }
}


//MARK: - UITableViewDelegate
extension ServiceViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height && !inLoad && !isEnd{
            getService()
        }
    }
}

//MARK: - UITableViewDataSource
extension ServiceViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServiceViewCell.reuseIdentifier, for: indexPath) as? ServiceViewCell else { return UITableViewCell() }
            let service = cellDataSource[indexPath.row]
        cell.setupCell(service: service)
        cell.updateButtonAction = {[weak self] in
            guard let self else { return }
            self.updateService(service: service)
        }
        return cell
    }
    
}


extension ServiceViewController: SelectDepartmentDelegate {
    
    func setDepartment(_ department: DepartmentResponse) {
        selectedDepartment = department
        currentAlert?.textFields?[3].text = department.name
    }
    
}
