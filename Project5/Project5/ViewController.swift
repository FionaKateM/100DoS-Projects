//
//  ViewController.swift
//  Project5
//
//  Created by Fiona Kate Morgan on 03/03/2019.
//  Copyright © 2019 Fiona Kate Morgan. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    var currentWord = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        if let savedUsedWords = defaults.object(forKey: "usedWords") as? Data {
            print("loading used words")
            let jsonDecoder = JSONDecoder()
            do {
                print("used words loaded")
                let loadedWords = try jsonDecoder.decode([String: [String]].self, from: savedUsedWords)
                currentWord = loadedWords.keys.first ?? ""
                usedWords = loadedWords[currentWord] ?? []
            } catch {
                print("failed to load used words")
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource:"start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
                if let index = allWords.firstIndex(of: currentWord) {
                    allWords.remove(at: index)
                }
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        if currentWord == "" {
            startGame()
        } else {
            title = currentWord
            tableView.reloadData()
        }
    }
    

    @objc func startGame() {

        currentWord = allWords.randomElement() ?? ""
        usedWords.removeAll(keepingCapacity: true)
        save()
        title = currentWord
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "submit", style: .default) { [weak self, weak ac] _ in
            
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)

    }
    
    func submit(_ answer: String){
        
        let errorTitle: String
        let errorMessage: String
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(lowerAnswer, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    save()
                    return
                } else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up you know"
                }
            } else {
                errorTitle = "Word already used"
                errorMessage = "Be more original"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title!.lowercased())"
        }
        showErrorMessage(title: errorTitle, message: errorMessage)
    }
    
    func isPossible(word:String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        if word == title?.lowercased() || (word.count < 4) {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return mispelledRange.location == NSNotFound
    }
    
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        let toSave =  [currentWord : usedWords]
        
        if let savedWords = try? jsonEncoder.encode(toSave) {
                let defaults = UserDefaults.standard
            print("saved used words: \(toSave)")
                defaults.set(savedWords, forKey: "usedWords")
            } else {
                print("failed to save usedwords")
        }
        
    }

    
}

