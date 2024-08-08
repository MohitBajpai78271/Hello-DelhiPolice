//
//  Admin View Controller.swift
//  ConstableOnPatrol
//
//  Created by Mac on 11/07/24.
//

import UIKit
import Alamofire

class AdminViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var searchUserNameTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var tableView: CustomTableView!
    
    var activeUsers: [ActiveUser] = []
    var filteredActiveUsers : [ActiveUser] = []
    let session = Alamofire.Session.default
    
    let adminLabel: UILabel = {
        let label = UILabel()
        label.text = "Admin"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField()
    
        view.addSubview(adminLabel)
        view.addSubview(searchButton)
        view.addSubview(searchUserNameTextField)
        
        filteredActiveUsers = activeUsers
    
        setupTableView()
        fetchActiveUsers()
        setupConstraints()
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMyKeyboaed))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register( MessageCell.self ,forCellReuseIdentifier: K.messageCell )
        tableView.allowsSelection = true
        tableView.delaysContentTouches = false
        tableView.bounces = false
        
    }
    
    func setupTextField(){
        searchUserNameTextField.rightView = searchButton
        searchUserNameTextField.rightViewMode = .always
        searchUserNameTextField.font = UIFont.preferredFont(forTextStyle: .title2)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchUserNameTextField.layer.borderColor = UIColor.black.cgColor
        searchUserNameTextField.layer.borderWidth = 2.0
        searchUserNameTextField.layer.cornerRadius = 5.0
        searchUserNameTextField.autocorrectionType = .no
        searchUserNameTextField.delegate = self
    }
    
    @objc func dismissMyKeyboaed() {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchUserNameTextField.endEditing(true)
        print()
    }
    
    //MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            adminLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            adminLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
        
        NSLayoutConstraint.activate([
            searchUserNameTextField.topAnchor.constraint(equalTo: adminLabel.bottomAnchor, constant: 20),
            searchUserNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchUserNameTextField.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -10),
            searchUserNameTextField.heightAnchor.constraint(equalToConstant: 60)
        ])
        
 
        
        NSLayoutConstraint.activate([
            searchButton.widthAnchor.constraint(equalToConstant: 40),  // Adjust the width as needed
            searchButton.heightAnchor.constraint(equalToConstant: 40), // Adjust the height as needed
        ])
    }
    
    //MARK: - Fetch ActiveUsersData
    
    func fetchActiveUsers() {
        
        fetchActiveUserData { [weak self] result in
            guard let self = self else{return}
            
            DispatchQueue.main.async {
                switch result {
                case .success(let activeUsers):
                    print("Received active users data: \(activeUsers)")
                    self.activeUsers = activeUsers
                    self.filteredActiveUsers = activeUsers
                    print("Active users count: \(self.activeUsers.count)")
                    
                    if self.activeUsers.isEmpty {
                        print("show  runs")
                            let message = "This user currently has no Followers 😔."
                            self.showEmptyStateView(with: message, in: self.view)
                        return
                        }
                    
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print("Failed to fetch active users: \(error)")
                    // Handle error, show alert, etc.
                }
            }
     
        }
    }
}
func fetchActiveUserData(completion: @escaping (Result<[ActiveUser], Error>) -> Void) {
    let url = "http://93.127.172.217:5000/api/activeUser"
    print(UserData.shared.userRole ?? "No role present")
    
    AF.request(url, method: .get).responseData { response in
        if let data = response.data {
            print("Raw response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
        }
        
        switch response.result {
        case .success(let data):
            do {
                let activeUsers = try JSONDecoder().decode([ActiveUser].self, from: data)
                completion(.success(activeUsers))
            } catch {
                print("JSON decoding failed: \(error)")
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

    //MARK: - TableView

extension AdminViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("filteredActiveUsers count: \(filteredActiveUsers.count)")
        return filteredActiveUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.messageCell, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .default
        let activeUser = filteredActiveUsers[indexPath.row]
        cell.nameLabel.text = activeUser.name
        cell.phoneNumberLabel.text = activeUser.mobileNumber
        cell.placeLabel.text = "Area: \(activeUser.areas.joined(separator: ", "))"
        cell.startTimeLabel.text = "Start Time: \(activeUser.dutyStartTime)"
        cell.endTimeLabel.text = "End Time: \(activeUser.dutyEndTime)"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    @objc func cellTapped(_ gesture: UITapGestureRecognizer) {
        let indexPath = tableView.indexPath(for: gesture.view as! MessageCell)!
        let selectedUser = activeUsers[indexPath.row]
        self.performSegue(withIdentifier: K.segueToLocation, sender: selectedUser.mobileNumber)
    }
    //MARK: - Filter Active USers
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == searchUserNameTextField {
            filterActiveUsers(with: textField.text ?? "")
        }
    }
    
    func filterActiveUsers(with searchText: String) {
        if searchText.isEmpty {
            filteredActiveUsers = activeUsers
        } else {
            filteredActiveUsers = activeUsers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        print("filteredActiveUsers count after filtering: \(filteredActiveUsers.count)")
        tableView.reloadData()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segueToLocation {
              if let destinationVC = segue.destination as? LocationViewController,
                 let phoneNumber = sender as? String {
                  destinationVC.phoneNumber = phoneNumber
              }
          }
      }}


class CustomTableView: UITableView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isDragging || self.isDecelerating {
            return nil
        }
        return super.hitTest(point, with: event)
    }
}
