//
//  ViewController.swift
//  Parker
//
//  Created by Matt O'Connell on 4/29/17.
//  Copyright © 2017 Matt O'Connell. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK - Local Variables
    let NextDay = "nextDay"

    // MARK - Helper Functions
    func updateNextDay(day: String) {
        nextDay.text = "Next move day: " + day
    }
    
    
    // MARK - Outlets
    @IBOutlet weak var nextDay: UILabel!
    
    
    // MARK - Actions
    @IBAction func parkButtonClick(_ sender: Any) {
        let alertController = UIAlertController(title: "", message: "When do you need to move your car?", preferredStyle: .actionSheet)
        
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        var alertActions = [UIAlertAction]()
        
        for day in days {
            let action = UIAlertAction(title: day, style: .default, handler: { (action) -> Void in
                UserDefaults.standard.set(day, forKey: self.NextDay)
                self.updateNextDay(day: day)
            })
            alertActions.append(action)
        }
        
        for action in alertActions {
            alertController.addAction(action)
        }

        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let day = UserDefaults.standard.string(forKey: NextDay) {
            self.updateNextDay(day: day)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

