import UIKit


final class SelectServiceViewController: UIViewController {
    //MARK: - Private Properties
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
    weak var delegate: SelectServiceDelegate?
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
private extension SelectServiceViewController {
    
    func setupView() {
        view.backgroundColor = .black
        setupTableView()
        addSubviews()
        activateConstraints()
        getService()
        addAction()
    }
    
    func addAction() {
        seaerchButton.addTarget(self, action: #selector(Self.didChangeFilter), for: .touchUpInside)
    }
    
    @objc
    func didChangeFilter() {
        updateListService()
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
    
    
    func updateListService() {
        isEnd = false
    }
    
    func addSubviews(){
        view.addSubview(tableView)
        view.addSubview(seaerchButton)
        view.addSubview(searchNameTextField)
      
    }
    
    func activateConstraints(){
        NSLayoutConstraint.activate([
            searchNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            searchNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            seaerchButton.topAnchor.constraint(equalTo: searchNameTextField.bottomAnchor, constant: 10),
            seaerchButton.leadingAnchor.constraint(equalTo: searchNameTextField.leadingAnchor),
            seaerchButton.trailingAnchor.constraint(equalTo: searchNameTextField.trailingAnchor),
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
        tableView.register(SelectServiceViewCell.self, forCellReuseIdentifier: SelectServiceViewCell.reuseIdentifier)
    }
    
}


//MARK: - UITableViewDelegate
extension SelectServiceViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.setService(cellDataSource[indexPath.row])
        dismiss(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height && !inLoad && !isEnd{
            getService()
        }
    }
}

//MARK: - UITableViewDataSource
extension SelectServiceViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectServiceViewCell.reuseIdentifier, for: indexPath) as? SelectServiceViewCell else { return UITableViewCell() }
            let service = cellDataSource[indexPath.row]
        cell.setupCell(service: service)
        return cell
    }
    
}


protocol SelectServiceDelegate: AnyObject {
    
    func setService(_ service: ServiceResponse)
    
}


final class SelectServiceViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "SelectServiceViewCell"
    
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
    func setupCell(service: ServiceResponse) {
        descriptionLabel.text = "\(service.name)\n\(service.description)\nЦена: \(service.price)"
    }
    
    
    //MARK: - Private Methods
    private func setupViews(){
        
        selectionStyle = .none
        backgroundColor = .black
        contentView.addSubview(descriptionLabel)
    
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
        
    }
}

