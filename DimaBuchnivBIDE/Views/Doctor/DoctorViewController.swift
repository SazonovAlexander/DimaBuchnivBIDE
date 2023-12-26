import UIKit


final class DoctorViewController: UIViewController {
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
    
    private let searchFioTextField: UITextField  = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "ФИО", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.layer.cornerRadius = 10
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clipsToBounds = true
        return textField
    }()
    
    private let searchSpecTextField: UITextField  = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "Специализация", attributes: [
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
    
    var cellDataSource: [DoctorResponse] = []
    private let doctorService = DoctorService()
    private var selectedDepartment: Int?
    private var currentAlert: UIAlertController?
    private var currentPage = 0
    private let itemsPerPage = 20
    private var inLoad = false
    private var isEnd = false {
        didSet {
            if isEnd == false {
                currentPage = 0
                cellDataSource = []
                getDoctor()
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
private extension DoctorViewController {
    
    func setupView() {
        view.backgroundColor = .black
        setupTableView()
        addSubviews()
        activateConstraints()
        getDoctor()
        addAction()
    }
    
    func addAction() {
        addButton.addTarget(self, action: #selector(Self.didTapAddButton), for: .touchUpInside)
        seaerchButton.addTarget(self, action: #selector(Self.didChangeFilter), for: .touchUpInside)
    }
    
    @objc
    func didChangeFilter() {
        updateListDoctor()
    }
    
    @objc
    func didSelectRepartment() {
        let selectDepartmentViewController = SelectDepartmentViewController()
        selectDepartmentViewController.delegate = self
        selectDepartmentViewController.modalPresentationStyle = .pageSheet
        currentAlert?.present(selectDepartmentViewController, animated: true)
    }
    
    @objc
    func didTapAddButton() {
        let alert = UIAlertController(title: "Доктор", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "ФИО"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Специализация"
        } 
        alert.addTextField { (textField) in
            textField.placeholder = "Департамент"
            textField.addTarget(self, action: #selector(Self.didSelectRepartment), for: .editingDidBegin)
        }
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak alert, weak self] _ in
            if let self,
               let fio = alert?.textFields?.first?.text,
               let specalization = alert?.textFields?[1].text,
                let department = selectedDepartment
            {
                let doctor = DoctorRequest(fio: fio, specalization: specalization, departmentId: department)
                self.doctorService.addDoctor(doctor: doctor, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        selectedDepartment = nil
                        updateListDoctor()
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
    
    func getDoctor() {
        inLoad.toggle()
        doctorService.fetchAllDoctor(page: currentPage, count: itemsPerPage, fio: searchFioTextField.text ?? "", spec: searchSpecTextField.text ?? "", completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let doctors):
                if !doctors.isEmpty {
                    currentPage += 1
                }
                else {
                    isEnd = true
                }
                self.cellDataSource.append(contentsOf: doctors)
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
    
    
    func updateDoctor(doctor: DoctorResponse) {
        selectedDepartment = doctor.department?.id
        let alert = UIAlertController(title: "Доктор", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "ФИО"
            textField.text = doctor.fio
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Специализация"
            textField.text = doctor.specalization
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Департамент"
            textField.addTarget(self, action: #selector(Self.didSelectRepartment), for: .editingDidBegin)
            textField.text = doctor.department?.name
        }
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak alert, weak self] _ in
            if let self,
               let fio = alert?.textFields?.first?.text,
               let specalization = alert?.textFields?[1].text,
                let department = selectedDepartment
            {
                let newDoctor = DoctorRequest(fio: fio, specalization: specalization, departmentId: department)
                self.doctorService.updateDoctor(doctorId: doctor.id, doctor: newDoctor, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        selectedDepartment = nil
                        updateListDoctor()
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
                self.doctorService.deleteDoctor(doctorId: doctor.id, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        selectedDepartment = nil
                        updateListDoctor()
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
    
    func updateListDoctor() {
        isEnd = false
    }
    
    func addSubviews(){
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(searchFioTextField)
        view.addSubview(searchSpecTextField)
        view.addSubview(seaerchButton)
    }
    
    func activateConstraints(){
        NSLayoutConstraint.activate([
            searchFioTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchFioTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchFioTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchSpecTextField.topAnchor.constraint(equalTo: searchFioTextField.bottomAnchor, constant: 10),
            searchSpecTextField.leadingAnchor.constraint(equalTo: searchFioTextField.leadingAnchor),
            searchSpecTextField.trailingAnchor.constraint(equalTo: searchFioTextField.trailingAnchor),
            seaerchButton.topAnchor.constraint(equalTo: searchSpecTextField.bottomAnchor, constant: 10),
            seaerchButton.leadingAnchor.constraint(equalTo: searchFioTextField.leadingAnchor),
            seaerchButton.trailingAnchor.constraint(equalTo: searchFioTextField.trailingAnchor),
            addButton.topAnchor.constraint(equalTo: seaerchButton.bottomAnchor, constant:  10),
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
        tableView.register(DoctorViewCell.self, forCellReuseIdentifier: DoctorViewCell.reuseIdentifier)
    }
    
    func resultDoctor(_ doctor: DoctorResponse) {
        inLoad.toggle()
        doctorService.fetchResultDoctor(doctorId: doctor.id, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let departmentResult):
                let alert = UIAlertController(title: "Статистика доктора",
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
extension DoctorViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height && !inLoad && !isEnd{
            getDoctor()
        }
    }
}

//MARK: - UITableViewDataSource
extension DoctorViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DoctorViewCell.reuseIdentifier, for: indexPath) as? DoctorViewCell else { return UITableViewCell() }
            let doctor = cellDataSource[indexPath.row]
        cell.setupCell(doctor: doctor)
        cell.updateButtonAction = {[weak self] in
            guard let self else { return }
            self.updateDoctor(doctor: doctor)
        }
        cell.resultButtonAction = {[weak self] in
            guard let self else { return }
            self.resultDoctor(doctor)
        }
        return cell
    }
    
}


extension DoctorViewController: SelectDepartmentDelegate {
    
    func setDepartment(_ department: DepartmentResponse) {
        selectedDepartment = department.id
        currentAlert?.textFields?.last?.text = department.name
    }
    
}


