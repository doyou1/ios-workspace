//
//  TaskViewController.swift
//  Tasks
//
//  Created by simjh on 2023/07/16.
//
import UIKit

class TaskViewController: UIViewController {
  
    @IBOutlet var label: UILabel!
    var task: String?
    var taskIdx: Int?
    var update: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "task: \(task ?? ""), idx: \(taskIdx ?? 0)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteTask))
    }

    @objc func deleteTask() {
        UserDefaults().set(nil, forKey: "task_\(taskIdx ?? -1)")
        update?()
        navigationController?.popViewController(animated: true)
    }
}
