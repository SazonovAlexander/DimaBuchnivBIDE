import UIKit


final class DepartmentViewController: UIViewController {
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
    
    var cellDataSource: [DepartmentResponse] = []
    private let departmentService = DepartmentService()
    private var currentPage = 0
    private let itemsPerPage = 20
    private var inLoad = false
    private var isEnd = false {
        didSet {
            if isEnd == false {
                currentPage = 0
                cellDataSource = []
                getDepartment()
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
private extension DepartmentViewController {
    
    func setupView() {
        view.backgroundColor = .black
        setupTableView()
        addSubviews()
        activateConstraints()
        getDepartment()
        addAction()
    }
    
    func addAction() {
        addButton.addTarget(self, action: #selector(Self.didTapAddButton), for: .touchUpInside)
    }
    
    @objc
    func didTapAddButton() {
        let alert = UIAlertController(title: "Департамент", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Название"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Адрес"
        }
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak alert, weak self] _ in
            if let self,
               let name = alert?.textFields?.first?.text,
               let address = alert?.textFields?.last?.text
            {
                let department = DepartmentRequest(name: name, address: address)
                self.departmentService.addDepartment(department: department, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        updateListDepartment()
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
        self.present(alert, animated: true)
    }
    
    func getDepartment() {
        inLoad.toggle()
        departmentService.fetchAllDepartment(page: currentPage, count: itemsPerPage, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let departments):
                if !departments.isEmpty {
                    currentPage += 1
                }
                else {
                    isEnd = true
                }
                self.cellDataSource.append(contentsOf: departments)
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
    
    func updateDepartment(department: DepartmentResponse) {
        let alert = UIAlertController(title: "Департамент", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Название"
            textField.text = department.name
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Адрес"
            textField.text = department.address
        }
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak alert, weak self] _ in
            if let self,
               let name = alert?.textFields?.first?.text,
               let address = alert?.textFields?.last?.text
            {
                let newDepartment = DepartmentRequest(name: name, address: address)
                self.departmentService.updateDepartment(departmentId: department.id, department: newDepartment, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        updateListDepartment()
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
                self.departmentService.deleteDepartment(departmentId: department.id, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        updateListDepartment()
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
        self.present(alert, animated: true)
    }
    
    func updateListDepartment() {
        isEnd = false
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
    
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        registerCell()
    }
    
    func registerCell() {
        tableView.register(DepartmentViewCell.self, forCellReuseIdentifier: DepartmentViewCell.reuseIdentifier)
    }
    
    func resultDepartment(_ department: DepartmentResponse) {
        inLoad.toggle()
        departmentService.fetchResultDepartment(departmentId: department.id, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let departmentResult):
                let alert = UIAlertController(title: "Статистика департамента",
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
    
}


//MARK: - UITableViewDelegate
extension DepartmentViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height && !inLoad && !isEnd{
            getDepartment()
        }
    }
}

//MARK: - UITableViewDataSource
extension DepartmentViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DepartmentViewCell.reuseIdentifier, for: indexPath) as? DepartmentViewCell else { return UITableViewCell() }
            let department = cellDataSource[indexPath.row]
        cell.setupCell(department: department)
        cell.updateButtonAction = {[weak self] in
            guard let self else { return }
            self.updateDepartment(department: department)
        }
        cell.resultButtonAction = {[weak self] in
            guard let self else { return }
            self.resultDepartment(department)
        }
        return cell
    }
    
}



