import UIKit


final class PatientViewController: UIViewController {
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
    
    private let searchAddressTextField: UITextField  = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "Адрес", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.layer.cornerRadius = 10
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clipsToBounds = true
        return textField
    }() 
    
    private let searchPhoneTextField: UITextField  = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "Номер телефона", attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.layer.cornerRadius = 10
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clipsToBounds = true
        return textField
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
    
    var cellDataSource: [PatientResponse] = []
    private let patientService = PatientService()
    private var currentPage = 0
    private let itemsPerPage = 20
    private var inLoad = false
    private var isEnd = false {
        didSet {
            if isEnd == false {
                currentPage = 0
                cellDataSource = []
                getPatient()
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
private extension PatientViewController {
    
    func setupView() {
        view.backgroundColor = .black
        setupTableView()
        addSubviews()
        activateConstraints()
        getPatient()
        addAction()
    }
    
    func addAction() {
        addButton.addTarget(self, action: #selector(Self.didTapAddButton), for: .touchUpInside)
        seaerchButton.addTarget(self, action: #selector(Self.didChangeFilter), for: .touchUpInside)
    }
    
    @objc
    func didChangeFilter() {
        updateListPatient()
    }
    
    @objc
    func didTapAddButton() {
        let alert = UIAlertController(title: "Пациент", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "ФИО"
            textField.text = ""
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Номер телефона"
            textField.text = ""
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Адрес"
            textField.text = ""
        }
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak alert, weak self] _ in
            if let self,
               let fio = alert?.textFields?[0].text,
               let number = alert?.textFields?[1].text,
               let address = alert?.textFields?[2].text
            {
               let patient = PatientRequest(fio: fio, phoneNumber: number, address: address)
                self.patientService.addPatient(patient: patient, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        updateListPatient()
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
    
    func getPatient() {
        inLoad.toggle()
        patientService.fetchAllPatient(page: currentPage, count: itemsPerPage, fio: searchFioTextField.text ?? "", phone: searchPhoneTextField.text ?? "", address: searchAddressTextField.text ?? "", completion: { [weak self] result in
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
    
    func updatePatient(patient: PatientResponse) {
        let alert = UIAlertController(title: "Пациент", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "ФИО"
            textField.text = patient.fio
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Номер телефона"
            textField.text = patient.phoneNumber
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Адрес"
            textField.text = patient.address
        }
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak alert, weak self] _ in
            if let self,
               let fio = alert?.textFields?[0].text,
               let number = alert?.textFields?[1].text,
               let address = alert?.textFields?[2].text
            {
               let newPatient = PatientRequest(fio: fio, phoneNumber: number, address: address)
                self.patientService.updatePatient(patientId: patient.id, patient: newPatient, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        updateListPatient()
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
                self.patientService.deletePatient(patientId: patient.id, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        updateListPatient()
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
    
    func updateListPatient() {
        isEnd = false
    }
    
    func addSubviews(){
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(seaerchButton)
        view.addSubview(searchFioTextField)
        view.addSubview(searchPhoneTextField)
        view.addSubview(searchAddressTextField)
    }
    
    func activateConstraints(){
        NSLayoutConstraint.activate([
            searchFioTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchFioTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchFioTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            searchPhoneTextField.topAnchor.constraint(equalTo: searchFioTextField.bottomAnchor, constant: 10),
            searchPhoneTextField.leadingAnchor.constraint(equalTo: searchFioTextField.leadingAnchor),
            searchPhoneTextField.trailingAnchor.constraint(equalTo: searchFioTextField.trailingAnchor),
            searchAddressTextField.topAnchor.constraint(equalTo: searchPhoneTextField.bottomAnchor, constant: 10),
            searchAddressTextField.leadingAnchor.constraint(equalTo: searchPhoneTextField.leadingAnchor),
            searchAddressTextField.trailingAnchor.constraint(equalTo: searchPhoneTextField.trailingAnchor),
            seaerchButton.topAnchor.constraint(equalTo: searchAddressTextField.bottomAnchor, constant: 10),
            seaerchButton.leadingAnchor.constraint(equalTo: searchFioTextField.leadingAnchor),
            seaerchButton.trailingAnchor.constraint(equalTo: searchFioTextField.trailingAnchor),
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
        tableView.register(PatientViewCell.self, forCellReuseIdentifier: PatientViewCell.reuseIdentifier)
    }
    
    
}


//MARK: - UITableViewDelegate
extension PatientViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height && !inLoad && !isEnd{
            getPatient()
        }
    }
}

//MARK: - UITableViewDataSource
extension PatientViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PatientViewCell.reuseIdentifier, for: indexPath) as? PatientViewCell else { return UITableViewCell() }
            let patient = cellDataSource[indexPath.row]
        cell.setupCell(patient: patient)
        cell.updateButtonAction = {[weak self] in
            guard let self else { return }
            self.updatePatient(patient: patient)
        }
        cell.visitsButtonAction = { [weak self] in
            guard let self else { return }
            let vc = PatientVisitViewController()
            vc.patient = patient
            self.present(vc, animated: true)
        }
        return cell
    }
    
}

