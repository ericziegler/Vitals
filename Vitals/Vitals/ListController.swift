//
//  ListController.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/19/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ListController: BaseViewController, UITableViewDataSource, UITableViewDelegate, VitalsControllerDelegate {

    // MARK: - Properties

    @IBOutlet var vitalsTable: UITableView!

    var progressView: ProgressView?
    var refreshControl = UIRefreshControl()

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTable()
        loadVitals()
    }

    private func setupNavBar() {
        self.title = "Vitals"
//        let loadButton = UIBarButtonItem(title: "Load", style: .plain, target: self, action: #selector(loadTapped(_:)))
//        self.navigationItem.leftBarButtonItem = loadButton

        if let addImage = UIImage(named: "Add") {
            let addButton = UIButton(type: .custom)
            addButton.addTarget(self, action: #selector(addTapped(_:)), for: .touchUpInside)
            addButton.setImage(addImage, for: .normal)
            addButton.frame = CGRect(x: 0, y: 0, width: addImage.size.width, height: addImage.size.height)
            let addItem = UIBarButtonItem(customView: addButton)
            self.navigationItem.rightBarButtonItem = addItem
        }
    }

    private func setupTable() {
        vitalsTable.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
        vitalsTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshVitals(_:)), for: .valueChanged)
    }

    private func loadVitals(showProgress: Bool = true) {
        if showProgress == true {
            progressView = ProgressView.createProgressFor(parentController: self.navigationController!, title: "Loading")
            progressView?.showProgress()
        }
        VitalsLog.shared.loadWithCompletion { [unowned self] (error) in
            DispatchQueue.main.async {
                self.progressView?.hideProgress()
                self.refreshControl.endRefreshing()
                if let error = error {
                    let alert = UIAlertController(title: "Error Loading", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.vitalsTable.reloadData()
                }
            }
        }
    }

    // MARK: - Actions

    @IBAction func addTapped(_ sender: AnyObject) {
        showVitalsControllerFor(vitals: nil)
    }

    @IBAction func loadTapped(_ sender: AnyObject) {
        VitalsLog.shared.loadFromFile()
        vitalsTable.reloadData()
    }

    @objc func refreshVitals(_ sender: AnyObject) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.loadVitals(showProgress: false)
        }
    }

    // MARK: - Helpers

    private func showVitalsControllerFor(vitals: Vitals?) {
        let controller = VitalsController.createControllerFor(vitals: vitals, delegate: self)
        let navController = BaseNavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }

    private func showStatusToast(success: Bool, isUpdate: Bool) {
        let bgColor = (success == true) ? UIColor(hex: 0x63cf8f) : UIColor(hex: 0xe75c57)
        let textColor = UIColor.white
        let statusText = (success == true) ? "✓ Vitals Saved!" : "⚠ Vitals Not Saved"
        let toast = StatusToastView.createToastFor(parentViewController: self, status: statusText, backgroundColor: bgColor, foregroundColor: textColor)
        toast.showToast()
    }

    // MARK: - UITableViewDataSource / UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VitalsLog.shared.vitalsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VitalsCellId, for: indexPath) as! VitalsCell
        let vitals = VitalsLog.shared.vitalsAt(index: indexPath.row)
        cell.layoutFor(vitals: vitals)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VitalsCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vitals = VitalsLog.shared.vitalsAt(index: indexPath.row)
        showVitalsControllerFor(vitals: vitals)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let vitals = VitalsLog.shared.vitalsAt(index: indexPath.row)
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] (action, view, completionHandler) in
            VitalsLog.shared.remove(vitals: vitals) { [unowned self] error in
                DispatchQueue.main.async {
                    if let _ = error {
                        let alert = UIAlertController(title: "Uh oh!", message: "We were unable to delete these vitals.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        AudioServicesPlaySystemSound(1519)
                        self.vitalsTable.reloadData()
                    }
                }
            }
            completionHandler(true)
        }
        deleteAction.backgroundColor = UIColor.systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    // MARK: - VitalsControllerDelegate

    func vitalsAdded(success: Bool, controller: VitalsController) {
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1519)
            self.dismiss(animated: true, completion: nil)
            self.showStatusToast(success: success, isUpdate: false)
            self.vitalsTable.reloadData()
        }
    }

    func vitalsUpdated(success: Bool, controller: VitalsController) {
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(1519)
            self.dismiss(animated: true, completion: nil)
            self.showStatusToast(success: success, isUpdate: true)
            self.vitalsTable.reloadData()
        }
    }

}

