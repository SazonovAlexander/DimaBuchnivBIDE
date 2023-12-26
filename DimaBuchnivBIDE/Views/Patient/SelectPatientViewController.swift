import UIKit


final class SelectPatientViewController: UIViewController {
    //MARK: - Private Properties
    
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
    weak var delegate: SelectPatientDelegate?
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
private extension SelectPatientViewController {
    
    func setupView() {
        view.backgroundColor = .black
        setupTableView()
        addSubviews()
        activateConstraints()
        getPatient()
        addAction()
    }
    
    func addAction() {
        seaerchButton.addTarget(self, action: #selector(Self.didChangeFilter), for: .touchUpInside)
    }
    
    @objc
    func didChangeFilter() {
        updateListPatient()
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
    
    
    func updateListPatient() {
        isEnd = false
    }
    
    func addSubviews(){
        view.addSubview(tableView)
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
            tableView.topAnchor.constraint(equalTo: seaerchButton.bottomAnchor, constant: 10),
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
        tableView.register(SelectPatientViewCell.self, forCellReuseIdentifier: SelectPatientViewCell.reuseIdentifier)
    }
    
    
}


//MARK: - UITableViewDelegate
extension SelectPatientViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.setPatient(cellDataSource[indexPath.row])
        dismiss(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height && !inLoad && !isEnd{
            getPatient()
        }
    }
}

//MARK: - UITableViewDataSource
extension SelectPatientViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectPatientViewCell.reuseIdentifier, for: indexPath) as? SelectPatientViewCell else { return UITableViewCell() }
        let patient = cellDataSource[indexPath.row]
        cell.setupCell(patient: patient)
        return cell
    }
    
}


protocol SelectPatientDelegate: AnyObject {
    
    func setPatient(_ patient: PatientResponse)
    
}


final class SelectPatientViewCell: UITableViewCell {
    static let reuseIdentifier: String = "SelectPatientViewCell"
    
    //MARK: - Private Properties
    private let descriptionLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    
    //MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Public Methods
    func setupCell(patient: PatientResponse) {
        descriptionLabel.text = "\(patient.fio)\n\(patient.address)\n\(patient.phoneNumber)"
    }
    
    
    //MARK: - Private Methods
    private func setupViews(){
        
        selectionStyle = .none
        backgroundColor = .black
        
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
        
    }
}

