import UIKit


final class SelectDepartmentViewController: UIViewController {
    //MARK: - Private Properties
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
    weak var delegate: SelectDepartmentDelegate?
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
private extension SelectDepartmentViewController {
    
    func setupView() {
        view.backgroundColor = .black
        setupTableView()
        addSubviews()
        activateConstraints()
        getDepartment()
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
    
    
    func updateListDepartment() {
        isEnd = false
    }
    
    func addSubviews(){
        view.addSubview(tableView)
    }
    
    func activateConstraints(){
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        tableView.register(SelectDepartmentViewCell.self, forCellReuseIdentifier: SelectDepartmentViewCell.reuseIdentifier)
    }
    
    
}


//MARK: - UITableViewDelegate
extension SelectDepartmentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.setDepartment(cellDataSource[indexPath.row])
        dismiss(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.height && !inLoad && !isEnd{
            getDepartment()
        }
    }
}

//MARK: - UITableViewDataSource
extension SelectDepartmentViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectDepartmentViewCell.reuseIdentifier, for: indexPath) as? SelectDepartmentViewCell else { return UITableViewCell() }
            let department = cellDataSource[indexPath.row]
        cell.setupCell(department: department)
        return cell
    }
    
}


protocol SelectDepartmentDelegate: AnyObject {
    
    func setDepartment(_ department: DepartmentResponse)
    
}


final class SelectDepartmentViewCell: UITableViewCell {
    static let reuseIdentifier: String = "SelectDepartmentViewCell"
    
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
    func setupCell(department: DepartmentResponse) {
        descriptionLabel.text = "\(department.name)"
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

