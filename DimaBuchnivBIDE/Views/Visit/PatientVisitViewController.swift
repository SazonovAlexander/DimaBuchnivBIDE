import UIKit


final class PatientVisitViewController: UINavigationController {
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
    
    private let searchDateTextField: UITextField  = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.attributedPlaceholder = NSAttributedString(string: "Дата", attributes: [
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
    
    
    var cellDataSource: [VisitResponse] = []
    let visitService = VisitService()
    private var selectedDoctor: DoctorResponse?
    var patient: PatientResponse?
    private var currentAlert: UIAlertController?
    private var currentPage = 0
    private let itemsPerPage = 20
    private var inLoad = false
    private var isEnd = false {
        didSet {
            if isEnd == false {
                currentPage = 0
                cellDataSource = []
                getVisit()
            }
        }
    }
    //MARK: - Override methods
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func getVisit() {
        inLoad.toggle()
        visitService.fetchVisitPatient(patientId: patient!.id, completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let visits):
                self.cellDataSource = visits
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
    
    @objc
    func didTapAddButton() {
        let alert = UIAlertController(title: "Посещение", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Дата"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Врач"
            textField.addTarget(self, action: #selector(Self.didSelectDoctor), for: .editingDidBegin)
        }
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak alert, weak self] _ in
            if let self,
               let date = alert?.textFields?.first?.text,
               let doctor = selectedDoctor
            {
                let visit = VisitRequest(dateVisit: date, doctorId: doctor.id, patientId: patient!.id)
                self.visitService.addVisit(visit: visit, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        print(date)
                        selectedDoctor = nil
                        updateListVisit()
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
}


//MARK: - Private Methods
private extension PatientVisitViewController {
    
    func setupView() {
        view.backgroundColor = .black
        setupTableView()
        addSubviews()
        activateConstraints()
        getVisit()
        addAction()
    }
    
    func addAction() {
        addButton.addTarget(self, action: #selector(Self.didTapAddButton), for: .touchUpInside)
        seaerchButton.addTarget(self, action: #selector(Self.didChangeFilter), for: .touchUpInside)
    }
    
    @objc
    func didChangeFilter() {
        updateListVisit()
    }
    
    
    
    
    func updateVisit(visit: VisitResponse) {
        selectedDoctor = visit.doctor
        let alert = UIAlertController(title: "Посещение", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Дата"
            textField.text = visit.dateVisit.description
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Врач"
            textField.text = visit.doctor.fio
            textField.addTarget(self, action: #selector(Self.didSelectDoctor), for: .editingDidBegin)
        }
        let save = UIAlertAction(title: "Сохранить", style: .default) { [weak alert, weak self] _ in
            if let self,
               let date = alert?.textFields?.first?.text,
               let doctor = selectedDoctor
            {
                let newVisit = VisitRequest(dateVisit: date, doctorId: doctor.id, patientId: patient!.id)
                self.visitService.updateVisit(visitId: visit.id ,visit: newVisit, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        selectedDoctor = nil
                        updateListVisit()
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
                self.visitService.deleteVisit(visitId: visit.id, completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success( _):
                        selectedDoctor = nil
                        updateListVisit()
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
    
    func updateListVisit() {
        isEnd = false
    }
    
    func addSubviews(){
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(seaerchButton)
        view.addSubview(searchDateTextField)
    }
    
    func activateConstraints(){
        NSLayoutConstraint.activate([
            searchDateTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchDateTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchDateTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            seaerchButton.topAnchor.constraint(equalTo: searchDateTextField.bottomAnchor, constant: 10),
            seaerchButton.leadingAnchor.constraint(equalTo: searchDateTextField.leadingAnchor),
            seaerchButton.trailingAnchor.constraint(equalTo: searchDateTextField.trailingAnchor),
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
        tableView.register(VisitViewCell.self, forCellReuseIdentifier: VisitViewCell.reuseIdentifier)
    }
    
    @objc
    func didSelectDoctor() {
        let selectDoctorViewController = SelectDoctorViewController()
        selectDoctorViewController.delegate = self
        selectDoctorViewController.modalPresentationStyle = .pageSheet
        currentAlert?.present(selectDoctorViewController, animated: true)
    }
    
}


//MARK: - UITableViewDelegate
extension PatientVisitViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height && !inLoad && !isEnd{
            getVisit()
        }
    }
}

//MARK: - UITableViewDataSource
extension PatientVisitViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VisitViewCell.reuseIdentifier, for: indexPath) as? VisitViewCell else { return UITableViewCell() }
            let visit = cellDataSource[indexPath.row]
        cell.setupCell(visit: visit)
        cell.updateButtonAction = {[weak self] in
            guard let self else { return }
            self.updateVisit(visit: visit)
        }
        cell.resultButtonAction = {[weak self] in
            guard let self else { return }
            print(012321312)
            let serviceVisitVC = ServiceVisitViewController()
            serviceVisitVC.visit = visit
            self.present(serviceVisitVC, animated: true)
        }
        return cell
    }
    
}


extension PatientVisitViewController: SelectDoctorDelegate {
    
    func setDoctor(_ doctor: DoctorResponse) {
        selectedDoctor = doctor
        currentAlert?.textFields?[1].text = doctor.fio
    }
    
}
