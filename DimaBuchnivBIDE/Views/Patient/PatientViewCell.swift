import UIKit


final class PatientViewCell: UITableViewCell {
    static let reuseIdentifier: String = "PatientViewCell"
    
    //MARK: - Private Properties
    private let descriptionLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    
    let updateButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let visitsButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "figure.walk"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var updateButtonAction: (() -> Void)?
    
    var visitsButtonAction: (() -> Void)?
    
    @objc
    private func didTapUpdateButton() {
        updateButtonAction?()
    }
    
    @objc
    private func didTapvisitsButton() {
        visitsButtonAction?()
    }
    
    
    
    
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
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(updateButton)
        contentView.addSubview(visitsButton)
        
        updateButton.addTarget(self, action: #selector(didTapUpdateButton), for: .touchUpInside)
        visitsButton.addTarget(self, action: #selector(didTapvisitsButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: updateButton.leadingAnchor, constant: 10),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            updateButton.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor),
            updateButton.trailingAnchor.constraint(equalTo: visitsButton.leadingAnchor, constant: 10),
            updateButton.widthAnchor.constraint(equalToConstant: 44),
            visitsButton.widthAnchor.constraint(equalToConstant: 44),
            visitsButton.centerYAnchor.constraint(equalTo: updateButton.centerYAnchor),
            visitsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
    }
}

