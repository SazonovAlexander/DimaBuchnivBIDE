import UIKit


final class TabBarAdminController: UITabBarController {
    
    let departmentViewController = DepartmentViewController()
    let doctorViewController = DoctorViewController()
    let patientViewController = PatientViewController()
    let serviceViewController = ServiceViewController()
    let visitViewController = VisitViewController()
    //MARK: - Initializers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Private methods
    private func setup() {
        setApperance()
        setVC()
    }
    
    private func setVC() {
        
        departmentViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "cross.case.circle"), selectedImage: nil)
        doctorViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "syringe"), selectedImage: nil)
        patientViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "heart.circle"), selectedImage: nil)
        serviceViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "banknote"), selectedImage: nil)
        visitViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "figure.walk"), selectedImage: nil)
        let visitNavController = UINavigationController(rootViewController: visitViewController)
        let patientNavControlelr = UINavigationController(rootViewController: patientViewController)
        setViewControllers([departmentViewController, doctorViewController, patientNavControlelr, serviceViewController, visitNavController], animated: true)
    }
    
    private func setApperance() {
                
        tabBar.tintColor = .white
        tabBar.barTintColor = .black
        tabBar.backgroundColor = .black
        
    }
    
}
