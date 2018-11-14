//
//  DiaryController.swift
//  UbiHealth
//
//  Created by Jose Paolo Talusan on 2018/08/30.
//  Copyright © 2018 Jose Paolo Talusan. All rights reserved.
//

import UIKit
import Firebase

class DiaryController: UIViewController {

    let ref = Database.database().reference(withPath: "users")
    
    
    lazy var breakfastButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        
        let borderAlpha : CGFloat = 0.7
        let cornerRadius : CGFloat = 5.0
        
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 0.4)
        
        button.setTitle("Breakfast", for: .normal)
//        button.setBackgroundImage(UIImage (named: "bk"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleBreakfast), for: .touchUpInside)
        return button
    }()
    
    @objc
    func handleBreakfast() {
        let diaryEntryController = DiaryEntryController()
        PassClass.myInstance.string1 = "Breakfast"
        self.navigationController?.pushViewController(diaryEntryController, animated: true)
    }
    
    lazy var lunchButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        let borderAlpha : CGFloat = 0.7
        let cornerRadius : CGFloat = 5.0
        
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 0.4)
        
//        button.setBackgroundImage(UIImage (named: "diet"), for: .normal)
        button.setTitle("Lunch", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleLunch), for: .touchUpInside)
        return button
    }()
    
    @objc
    func handleLunch() {
        let diaryEntryController = DiaryEntryController()
        PassClass.myInstance.string1 = "Lunch"
        self.navigationController?.pushViewController(diaryEntryController, animated: true)
    }
    
    lazy var snacksButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        
        let borderAlpha : CGFloat = 0.7
        let cornerRadius : CGFloat = 5.0
        
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 0.4)
        
        button.setTitle("Snacks", for: .normal)
//        button.setBackgroundImage(UIImage (named: "diet"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleSnacks), for: .touchUpInside)
        return button
    }()
    
    @objc
    func handleSnacks() {
        let diaryEntryController = DiaryEntryController()
        PassClass.myInstance.string1 = "Snacks"
        self.navigationController?.pushViewController(diaryEntryController, animated: true)
    }
    
    lazy var dinnerButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        
        let borderAlpha : CGFloat = 0.7
        let cornerRadius : CGFloat = 5.0
        
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 0.4)
        
        button.setTitle("Dinner", for: .normal)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleDinner), for: .touchUpInside)
        return button
    }()
    
    @objc
    func handleDinner() {
        let diaryEntryController = DiaryEntryController()
        PassClass.myInstance.string1 = "Dinner"
        self.navigationController?.pushViewController(diaryEntryController, animated: true)
    }
    
    lazy var exerciseButton: UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor(r: 80, g: 101, b:161)
        
        let borderAlpha : CGFloat = 0.7
        let cornerRadius : CGFloat = 5.0
        
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = UIColor(red: 80/255, green: 101/255, blue: 161/255, alpha: 0.4)
        
        button.setTitle("Exercise", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleExercise), for: .touchUpInside)
        return button
    }()
    
    @objc
    func handleExercise() {
        let diaryEntryController = DiaryEntryController()
        PassClass.myInstance.string1 = "Exercise"
        self.navigationController?.pushViewController(diaryEntryController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = Auth.auth().currentUser!.uid

        ref.child(userID).observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            print(snapshot.value as Any)
            guard let userDict = snapshot.value as? [String: Any],
                let _ = userDict["email"] as? String,
                let name = userDict["name"] as? String else {
                    return
            }
            self.navigationItem.title = "\(name)'s Diary"
        })
    
//        navigationController?.navigationBar.prefersLargeTitles = true
        
//        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)

        //Setting of background image
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "marsh")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        [breakfastButton, lunchButton, snacksButton, dinnerButton, exerciseButton].forEach { view.addSubview($0) }
        setupBreakfastButton()
        setupLunchButton()
        setupSnacksButton()
        setupDinnerButton()
        setupExerciseButton()
    }
    
    //------
    
    func setupBreakfastButton() {
        breakfastButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.centerXAnchor,
                           bottom: nil, trailing: view.trailingAnchor,
                           padding: .init(top: 50, left: 6, bottom: 12, right: -12),
                           size: .init(width: 0, height: 150))
    }
    
    func setupSnacksButton() {
        snacksButton.anchor(top: breakfastButton.bottomAnchor, leading: view.centerXAnchor,
                            bottom: nil, trailing: view.trailingAnchor,
                            padding: .init(top: 12, left: 6, bottom: 12, right: -12))
        snacksButton.anchorSize(to: breakfastButton)
    }
    
    func setupExerciseButton() {
        exerciseButton.anchor(top: snacksButton.bottomAnchor, leading: view.centerXAnchor,
                              bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor,
                              padding: .init(top: 12, left: 6, bottom: -50, right: -12))
        exerciseButton.anchorSize(to: breakfastButton)
    }
    
    //------
    
    
    func setupLunchButton() {
        lunchButton.anchor(top: breakfastButton.centerYAnchor, leading: view.leadingAnchor,
                               bottom: nil, trailing: view.centerXAnchor,
                               padding: .init(top: 0, left: 12, bottom: 12, right: -6))
        lunchButton.anchorSize(to: breakfastButton)
    }
    

    
    func setupDinnerButton() {
        dinnerButton.anchor(top: lunchButton.bottomAnchor, leading: view.leadingAnchor,
                           bottom: nil, trailing: view.centerXAnchor,
                           padding: .init(top: 12, left: 12, bottom: 0, right: -6))
        dinnerButton.anchorSize(to: breakfastButton)
    }
}

