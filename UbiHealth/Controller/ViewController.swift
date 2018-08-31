//
//  ViewController.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2018/08/29.
//  Copyright © 2018 Jose Paolo Talusan. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        //Check if user is currently logged in
        if Auth.auth().currentUser?.uid == nil {
//            performSelector(#selector(handleLogout), with: nil, afterDelay: 0)
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
        }
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(titleLabel)
        
        [diaryButton, suggestionButton, checkFriendsButton, personalReportButton, profileImageView].forEach { view.addSubview($0) }
        
        setupTitleLabel()
        
        setupDiaryButton()
        setupSuggestionButton()
        setupCheckFriendsButton()
        setupPersonalReportButton()
        setupProfileImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    @objc
    func handleLogout() {
        do {
            try Auth.auth().signOut()
//            self.dismiss(animated: true, completion: nil)
        } catch (let error) {
            print("Auth sign out failed: \(error)")
        }
        
        print("Logout pressed")
        let loginController = LoginController()
        self.navigationController?.pushViewController(loginController, animated: false)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "4827060")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
//        label.backgroundColor = UIColor(r: 80, g: 101, b:161)
        label.text = "UBIHEALTH"
//        label.text = "+"
        label.textAlignment = .center
        label.font = label.font.withSize(30)
        label.font = .boldSystemFont(ofSize: 20.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    lazy var diaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        button.setTitle("Diary", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleDiary), for: .touchUpInside)
        return button
    }()
    
    lazy var suggestionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        button.setTitle("Suggestion", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleSuggestion), for: .touchUpInside)
        return button
    }()
    
    lazy var checkFriendsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        button.setTitle("Check Friends", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleCheckFriends), for: .touchUpInside)
        return button
    }()
    
    lazy var personalReportButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        button.setTitle("Personal Report", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handlePersonalReport), for: .touchUpInside)
        return button
    }()
    
    @objc
    func handleSuggestion() {
        let suggestionController = SuggestionController()
        self.navigationController?.pushViewController(suggestionController, animated: true)
    }
    
    @objc
    func handleCheckFriends() {
        let checkFriendsController = CheckFriendsController()
        self.navigationController?.pushViewController(checkFriendsController, animated: true)
    }
    
    @objc
    func handlePersonalReport() {
        let personalReportController = PersonalReportController()
        self.navigationController?.pushViewController(personalReportController, animated: true)
    }
    
    func setupDiaryButton() {
        //need x, y, width, height constraints
        diaryButton.anchor(top: titleLabel.bottomAnchor, leading: view.leadingAnchor,
                           bottom: nil, trailing: view.centerXAnchor,
                           padding: .init(top: 50, left: 12, bottom: 0, right: -6),
                           size: .init(width: 0, height: 100))
    }
    
    func setupSuggestionButton() {
        //need x, y, width, height constraints
        suggestionButton.anchor(top: diaryButton.bottomAnchor, leading: view.leadingAnchor,
                                bottom: nil, trailing: view.centerXAnchor,
                                padding: .init(top: 12, left: 12, bottom: 0, right: -6))
        suggestionButton.anchorSize(to: diaryButton)
    }
    
    func setupCheckFriendsButton() {
        //need x, y, width, height constraints
        checkFriendsButton.anchor(top: titleLabel.bottomAnchor, leading: view.centerXAnchor,
                                bottom: nil, trailing: view.trailingAnchor,
                                padding: .init(top: 50, left: 6, bottom: 0, right: -12))
        checkFriendsButton.anchorSize(to: diaryButton)
    }
    
    func setupPersonalReportButton() {
        //need x, y, width, height constraints
        personalReportButton.anchor(top: checkFriendsButton.bottomAnchor, leading: view.centerXAnchor,
                                  bottom: nil, trailing: view.trailingAnchor,
                                  padding: .init(top: 12, left: 6, bottom: 0, right: -12))
        personalReportButton.anchorSize(to: diaryButton)
    }
    
    func setupTitleLabel() {
        //need x, y, width, height constraints
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor,
                          bottom: nil, trailing: view.trailingAnchor,
                          padding: .init(top: 200, left: 0, bottom: 0, right: 0),
                          size: .init(width: 0, height: 100))
    }
    
    func setupProfileImageView() {
        //need x, y, width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil,
                          bottom: titleLabel.topAnchor, trailing: nil,
                          padding: .init(top: 20, left: 0, bottom: 0, right: 0),
                          size: .init(width: 0, height: 0))
    }
    
    @objc
    func handleDiary() {
        let diaryController = DiaryController()
        self.navigationController?.pushViewController(diaryController, animated: true)
//        let alert = UIAlertController(title: "Diary pressed",
//                                      message: "HELLO",
//                                      preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        self.present(alert, animated: true, completion: nil)
    }
}

extension UIView {
    func anchorSize(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?,
                bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?,
                padding: UIEdgeInsets = .zero,
                size: CGSize = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: padding.bottom).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: padding.right).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    
}
