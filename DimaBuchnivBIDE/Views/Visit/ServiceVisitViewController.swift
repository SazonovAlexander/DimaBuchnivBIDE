import UIKit


final class ServiceVisitViewController: UIViewController {
    //MARK: - Private Properties
    private let addButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black
        return tableView
    }()

    var cellDataSource: [ServiceResponse] = []
    private let visitService = VisitService()
    private var selectedService: ServiceResponse?
    var visit: VisitResponse?
    private var currentAlert: UIAlertController?
    //MARK: - Override methods
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
}


//MARK: - Private Methods
private extension ServiceVisitViewController {
    
    func setupView() {
        view.backgroundColor = .black
        setupTableView()
        addSubviews()
        activateConstraints()
        getService()
        addAction()
    }
    
    func addSubviews(){
        view.addSubview(tableView)
        view.addSubview(addButton)
    }
    
    func activateConstraints(){
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 44),
            addButton.widthAnchor.constraint(equalToConstant: 44),
            tableView.topAnchor.constraint(equalTo: addButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func addAction() {
        addButton.addTarget(self, action: #selector(Self.didTapAddButton), for: .touchUpInside)
    }
    
    @objc
    func didChangeFilter() {
        updateListService()
    }
    
    func updateListService() {
        cellDataSource = []
        getService()
    }
    
    func deleteService(service: ServiceResponse) {
        visitService.deleteServiceFromVisit(serviceId: service.id, visitId: visit!.id, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success( _):
                selectedService = nil
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
    
    @objc
    func didTapAddButton() {
        let alert = UIAlertController(title: "Услуга", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Услуга"
            textField.addTarget(self, action: #selector(Self.didSelectService), for: .editingDidBegin)
        }
        let save = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            if let self,
                let service = selectedService
            {
                self.visitService.addServiceToVisit(serviceId: service.id, visitId: visit!.id, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        selectedService = nil
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
        visitService.fetchVisit(visitId: visit!.id, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let visit):
                print(visit)
                self.cellDataSource = visit.services ?? []
                self.tableView.reloadData()
            case .failure(let error):
                let alert = UIAlertController(title: "Что-то пошло не так(", message: error.localizedDescription, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(alertAction)
                self.present(alert, animated: true)
            }
        })
    }
    
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        registerCell()
    }
    
    func registerCell() {
        tableView.register(ServiceVisitViewCell.self, forCellReuseIdentifier: ServiceVisitViewCell.reuseIdentifier)
    }
    
    
    @objc
    func didSelectService() {
        let selectServiceViewController = SelectServiceViewController()
        selectServiceViewController.delegate = self
        selectServiceViewController.modalPresentationStyle = .pageSheet
        currentAlert?.present(selectServiceViewController, animated: true)
    }
}


//MARK: - UITableViewDelegate
extension ServiceVisitViewController: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension ServiceVisitViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServiceVisitViewCell.reuseIdentifier, for: indexPath) as? ServiceVisitViewCell else { return UITableViewCell() }
            let service = cellDataSource[indexPath.row]
        cell.setupCell(service: service)
        cell.deleteButtonAction = {[weak self] in
            guard let self else { return }
            self.deleteService(service: service)
        }
    
        return cell
    }
    
}


extension ServiceVisitViewController: SelectServiceDelegate {
    
    func setService(_ service: ServiceResponse) {
        selectedService = service
        currentAlert?.textFields?.first?.text = service.name
    }
    
}
