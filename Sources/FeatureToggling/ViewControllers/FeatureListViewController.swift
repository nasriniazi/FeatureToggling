//
//  FeatureListViewController.swift
//  
//
//  Created by nasrin niazi on 2023-02-01.
//

import UIKit
import Theme

///This VC get an local json file url from the consumer,
///- provides a simple features list to select or deselect
///- and Then with Done button performs an update on features file
/// provider inject a local json features to LocalProvider calss of the package, and with sending this object to FeaturesService(featureManager) access to all needed methods working with feature toggles
public class FeatureListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    var featuresList: [FeaturesWithState] = []
    var provider: FeatureToggleProvider!
    var featureManager:FeatureToggleService!
    var editedFlag = false
    
    @IBOutlet weak var doneButton: UIButton!
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        editedFlag = false
        self.updateFeatureSource()
    }
    public static func getInstance(featureManager:FeatureToggleService?) -> FeatureListViewController {
        guard let vc : FeatureListViewController = FeatureListViewController.loadFromNib()  else {
            fatalError("\(FeatureListViewController.description())'s xib not found")
        }
        vc.featureManager = featureManager
        return vc
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setupUI()
        getData()
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let orientation = self.view.window?.windowScene?.interfaceOrientation {
            let landscape = orientation == .landscapeLeft || orientation == .landscapeRight
            updateTableView(landscape:landscape)
        }
    }
    
    // on rotation
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let landscape = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
        updateTableView(landscape:landscape)
        
    }
    func updateTableView(landscape:Bool){
        guard let tableView = self.tableView else {return}
        if landscape   {
            tableView.isScrollEnabled = true
            tableView.estimatedRowHeight = 50
            
        }
        else{
            tableView.estimatedRowHeight = 60
            
        }
        tableView.reloadData()
    }
    //    override public func viewDidLayoutSubviews(){
    //        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
    //        tableView.reloadData()
    //    }
    func setupTable(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = .zero
        tableView.layer.cornerRadius = 15
        tableView.separatorColor = .lightGray
        tableView.register(UINib(nibName: "ItemTableViewCell", bundle: Bundle.module), forCellReuseIdentifier: "ItemTableViewCell")
        
    }
    func setupUI(){
        self.doneButton.layer.cornerRadius = 10
    }
    public  func setTitle(title:String){
        self.titleLabel.text = title
    }
    public static func loadFromNib() -> FeatureListViewController? {
        // Loads nib file from the module
        FeatureListViewController(nibName: "FeatureListViewController",
                                  bundle: Bundle.module)
    }
    
    func getData(){
        guard let featureManager = self.featureManager else {return}
        do {
            try featureManager.loadToggles() { features in
                self.featuresList = features
            }
        }catch let error as FeatureTogglingErrors{
            MessageDisplay.displaySimpleMessage(titleStr: Constants.errorTitle, txtMessage:error.description , owner: self)
        }catch {
            MessageDisplay.displaySimpleMessage(titleStr: Constants.errorTitle, txtMessage:FeatureTogglingErrors.unknownError.description , owner: self)
        }
    }
    func updateFeatureSource(){
        do{
            try featureManager.updateFeaturesList(features: self.featuresList)
        }catch let error as FeatureTogglingErrors{
            MessageDisplay.displaySimpleMessage(titleStr: Constants.errorTitle, txtMessage:error.description , owner: self)
        }catch {
            MessageDisplay.displaySimpleMessage(titleStr: Constants.errorTitle, txtMessage:FeatureTogglingErrors.unknownError.description , owner: self)
        }
    }
    
}
extension FeatureListViewController:UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return featuresList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath)
        cell.textLabel?.text = featuresList[indexPath.row].feature
        cell.selectionStyle = .none
        cell.accessoryType = featuresList[indexPath.row].enabled ? .checkmark : .none
        cell.textLabel?.textColor = .lightGray
        cell.textLabel?.font =  UIFont.preferredFont(forTextStyle: .largeTitle)
        return cell
    }
}
extension FeatureListViewController:UITableViewDelegate{
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        featuresList[indexPath.row].enabled = !featuresList[indexPath.row].enabled
        selectedCell?.accessoryType = featuresList[indexPath.row].enabled ? .checkmark :.none
        editedFlag = true
    }
    
}
