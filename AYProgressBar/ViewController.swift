//
//  ViewController.swift
//  AYProgressBar
//
//  Created by Abdorahman Youssef on 12/22/18.
//  Copyright © 2018 Abdorahman Youssef. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    @IBOutlet weak var progressBar: AYProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupProgressBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupProgressBar(){
        progressBar.progressLabelType = ProgressLabelFormat.full.rawValue
        progressBar.startProgress(withValue: 0.1)
    }
}
