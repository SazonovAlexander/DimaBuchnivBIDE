import UIKit


final class DoctorViewCell: UITableViewCell {
    static let reuseIdentifier: String = "DoctorViewCell"
    
    //MARK: - Private Properties
    private let descriptionLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    let resultButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let updateButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var updateButtonAction: (() -> Void)?
    
    var resultButtonAction: (() -> Void)?
    
    @objc
    private func didTapUpdateButton() {
        updateButtonAction?()
    }
    
    @objc
    private func didTapResultButton() {
        resultButtonAction?()
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
    func setupCell(doctor: DoctorResponse) {
        descriptionLabel.text = "\(doctor.fio)\n\(doctor.specalization)\n\(doctor.department?.name ?? "")"
    }
    
    
    //MARK: - Private Methods
    private func setupViews(){
        
        selectionStyle = .none
        backgroundColor = .black
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(updateButton)
        contentView.addSubview(resultButton)
        
        updateButton.addTarget(self, action: #selector(didTapUpdateButton), for: .touchUpInside)
        resultButton.addTarget(self, action: #selector(didTapResultButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: updateButton.leadingAnchor, constant: 10),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            updateButton.centerYAnchor.constraint(equalTo: descriptionLabel.centerYAnchor),
            updateButton.trailingAnchor.constraint(equalTo: resultButton.leadingAnchor, constant: 10),
            updateButton.widthAnchor.constraint(equalToConstant: 44),
            resultButton.widthAnchor.constraint(equalToConstant: 44),
            resultButton.centerYAnchor.constraint(equalTo: updateButton.centerYAnchor),
            resultButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
        
    }
}

