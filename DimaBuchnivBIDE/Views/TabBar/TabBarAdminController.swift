import UIKit


final class TabBarAdminController: UITabBarController {
    
//    let examTableViewController = ExamTableViewController()
//    let scheduleTableViewController = ScheduleTableViewController()
//    let teacherTableViewController = TeacherTableViewController()
//    let studentTableViewController = StudentTableViewController()
//    let groupTableViewController = PartyTableViewController()
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
        
//        studentTableViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person.3.sequence"), selectedImage: nil)
//        scheduleTableViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "calendar"), selectedImage: nil)
//        examTableViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "rublesign.circle.fill"), selectedImage: nil)
//        teacherTableViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person.wave.2"), selectedImage: nil)
//        groupTableViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "rectangle.stack.badge.person.crop"), selectedImage: nil)
//        
//        let examNavController = UINavigationController(rootViewController: examTableViewController)
//        setViewControllers([scheduleTableViewController, examNavController, teacherTableViewController, studentTableViewController, groupTableViewController], animated: true)
    }
    
    private func setApperance() {
                
    
        
        
    }
    
}
