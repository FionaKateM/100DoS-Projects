//
//  ViewController.swift
//  Project7
//
//  Created by Fiona Kate Morgan on 10/03/2019.
//  Copyright © 2019 Fiona Kate Morgan. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [Petition]()
    var refinedPetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credit", style: .plain, target: self, action: #selector(creditTapped))
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        let leftButtons = [searchButton, refreshButton]
        
        navigationItem.leftBarButtonItems = leftButtons
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            // actualurlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // actualUrlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                refinedPetitions = petitions
                return
            }
        }
        
        showError()
        
    }
    
    @objc func refresh() {
        refinedPetitions = petitions
        tableView.reloadData()
    }
    
    @objc func search() {
        let ac = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let searchAction = UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] action in
            guard let keyword = ac?.textFields?[0].text else { return }
            self?.searchSubmit(keyword)
        }
        ac.addAction(searchAction)
        present(ac, animated: true)
    }
    
    func searchSubmit(_ keyword: String) {
        refinedPetitions.removeAll()
        for petition in petitions {
            if petition.title.lowercased().contains(keyword.lowercased()) || petition.body.lowercased().contains(keyword.lowercased()) {
                refinedPetitions.append(petition)
            }
        }
        
//        if refinedPetitions.count == 0 {
//            refinedPetitions = petitions
//        }
        
        tableView.reloadData()
    }
    
    @objc func creditTapped(){
        let ac = UIAlertController(title: "Data Source", message: "We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return refinedPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = refinedPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = refinedPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

