//
//  ViewController.swift
//  Project2
//
//  Created by Fiona Kate Morgan on 20/02/2019.
//  Copyright © 2019 Fiona Kate Morgan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var played = 0
    var correctAnswer = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideScore()
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named:countries[0]), for: .normal)
        button2.setImage(UIImage(named:countries[1]), for: .normal)
        button3.setImage(UIImage(named:countries[2]), for: .normal)
        
        title = countries[correctAnswer].uppercased() + " | Score: \(score)/\(played + 1)"
    }
    
    func resetScore(action: UIAlertAction! = nil) {
        score = 0
        played = 0
        countries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        askQuestion()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        hideScore()
        
        var title: String
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            played += 1
            countries.remove(at: correctAnswer)
        } else {
            title = "Wrong, that's the flag of \(countries[sender.tag])"
            score -= 1
            played += 1
            countries.remove(at: correctAnswer)
        }
        
        let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        
        let finalac = UIAlertController(title: title, message: "Thank you for playing, you scored \(score)", preferredStyle: .alert)
        finalac.addAction(UIAlertAction(title: "End game", style: .default, handler: resetScore))
        
        if played == 10 {
            present(finalac, animated: true)
        }else{
            present(ac, animated: true)
        }
    }
    
    @objc func showScore() {
        let button = UIBarButtonItem.init(title: "\(score)", style: .plain, target: self, action: #selector(hideScore))
        navigationItem.rightBarButtonItem = button
    }
    @objc func hideScore() {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showScore))
        navigationItem.rightBarButtonItem = button
    }
}

