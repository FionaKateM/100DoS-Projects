//
//  ViewController.swift
//  Project1
//
//  Created by Fiona Kate Morgan on 17/02/2019.
//  Copyright © 2019 Fiona Kate Morgan. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [String]()
    var imageCount = [String : Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        performSelector(inBackground: #selector(loadImages), with: nil)
    }
    
    @objc func loadImages() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        loadImageCount()
        
        for item in items {
            if item.hasPrefix("nssl") {
                // this is a picture to load
                pictures.append(item)
                pictures.sort()
                if !imageCount.keys.contains(item) {
                    imageCount.updateValue(0, forKey: item)
                }
            }
        }

        tableView.performSelector(onMainThread: #selector(tableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    func loadImageCount() {
        // load user defaults here
        let defaults = UserDefaults.standard
        
        if let savedImageCount = defaults.object(forKey: "imageCount") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                imageCount = try jsonDecoder.decode([String : Int].self, from: savedImageCount)
            } catch {
                print("failed to load image counts")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        
        cell.textLabel?.text = pictures[indexPath.row]
//        cell.textLabel?.text = "Picture \(indexPath.row + 1) of \(pictures.count)"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            let image = pictures[indexPath.row]
            var title = "Picture \(indexPath.row + 1) of \(pictures.count)"
            vc.selectedImage = image
            if let value = imageCount[image] {
                if value > 0 {
                    title += ", viewed \(value + 1) times"
                } else {
                    title += ", viewed \(value + 1) time"
                }
                imageCount.updateValue(value + 1, forKey: image)
                print("image count: \(value + 1)")
                save()
            } else {
                print("failed to update image count")
            }
            vc.selectedImageTitle = title
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(imageCount) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "imageCount")
        } else {
            print("failed to save image count")
        }
    }
}

