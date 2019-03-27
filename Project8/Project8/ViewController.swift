//
//  ViewController.swift
//  Project8
//
//  Created by Fiona Kate Morgan on 10/03/2019.
//  Copyright © 2019 Fiona Kate Morgan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var cluesLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons = [UIButton]()
    
    var clueString = ""
    var solutionString = ""
    var letterBits = [String]()
    
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var guessed = 0 {
        didSet {
            if guessed == 7 {
                levelUp()
            }
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "Clues"
        cluesLabel.numberOfLines = 0
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(cluesLabel)
        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.text = "Answers"
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false
        view.addSubview(currentAnswer)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        // challenge 1 - set thin grey border around buttons view
        buttonsView.layer.borderColor = UIColor.gray.cgColor
        buttonsView.layer.borderWidth = 1
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            // pin the top of the score label to the top margin
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            
            // pin the edge of the score label to the trailing margin
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            
            // pin the top of the clues label to the bottom of the score label
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            // pin the clues label to 100 points in from the leading layout margin
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            
            // make the clues label 60% of the width between the layout margins, reduced by 100
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            // pin the top of the answers label to the bottom of the score label
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            
            // make the answers label in 100 from the trailing margin
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            
            // make the answers label take up 40% of the space between side margins, minus 100
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            
            // make the answers label match the height of the clues label
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            // center the current answer textbox
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // make the current answer textbox half the width between the side margins
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            // pin the current answer textbox to the bottom of the clues label
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            
            // pin the top of submit button to the bottom of the current answer button
            submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            
            // place submit button 100 points to the left of centre
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            
            // make the submit button 44 points high
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            // pin the clear button 100 points to the right of centre
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            
            // vertically align clear button to submit
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            
            // make clear button 44 points high
            clear.heightAnchor.constraint(equalToConstant: 44),
            
            // make the view containing all the buttons 750 wide and 320 high
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            
            // make buttonsview centred horizontally
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // pin buttons view 20 points below submit button
            buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            
            // pin buttons view 20 points above the bottom margin of the main view
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
            ])
        
        // height and width of each button
        let width = 150
        let height = 80
        
        // create 20 buttons as a 4x5 grid
        for row in 0..<4 {
            for column in 0..<5 {
                
                // create a new button and change font size
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                
                // give the button text so we can see it
                letterButton.setTitle("WWW", for: .normal)
                
                // add target so letter tapped is called when any letter button is tapped
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                // do all the position calculations
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                buttonsView.addSubview(letterButton)
                
                // add to letterButtons array
                letterButtons.append(letterButton)
            }
        }
        
//        cluesLabel.backgroundColor = .red
//        answersLabel.backgroundColor = .blue
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else {return}
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        sender.isHidden = true
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        guard let answerText = currentAnswer.text else { return }
        
        // look to see if the solution exists in solutions, and if so return the index
        if let solutionPosition = solutions.firstIndex(of: answerText) {
            activatedButtons.removeAll()
            
            var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
            splitAnswers?[solutionPosition] = answerText
            answersLabel.text = splitAnswers?.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            guessed += 1
            // if they've got all 7 then move to next level - tutorial code
//            if score % 7 == 0 {
//                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
//                present(ac, animated: true)
//            }
            
        } else {
            // challenge 3 - deduct 1 from score if incorrect (also involves having to change the check on whether it's time to go up a level as that currently relies on score)
            score -= 1
            // challenge 2 - if answer is incorrect, show the user an alert
            let ac = UIAlertController(title: "Wrong", message: "That's not correct", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok", style: .default, handler: clearTapped))
            present(ac, animated: true)
        }
    }
    
    func levelUp(action: UIAlertAction! = nil) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for button in letterButtons {
            button.isHidden = false
        }
    }
    
    @objc func clearTapped(action: UIAlertAction! = nil) {
        currentAnswer.text = ""
        for button in activatedButtons {
            button.isHidden = false
        }
        activatedButtons.removeAll()
    }
    
    func loadLevel() {
        performSelector(inBackground: #selector(parseJSON), with: nil)
//        print(letterBits)
    }
    
    @objc func parseJSON(){
        
        // check if level file for current level exists
        if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: levelFileURL) {
                // separates everything by line break
                var lines = levelContents.components(separatedBy: "\n")
                // mix them up
                lines.shuffle()
                
                // enumerated returns index and line
                for (index, line) in lines.enumerated() {
                    // first part is answer, then second is clue string
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    // makes a word out of the bits, replacing the pipe with nothing and adds to solutions
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.count) letters\n"
                    solutions.append(solutionWord)
                    
                    // takes all the bits of words and adds them to the letter bits array
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits
                }
                
                performSelector(onMainThread: #selector(updateUI), with: nil, waitUntilDone: false)
                
            }
        }
    }
    
    @objc func updateUI() {
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        letterButtons.shuffle()
        if letterButtons.count == letterBits.count {
            for i in 0 ..< letterButtons.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadLevel()
    }
}

