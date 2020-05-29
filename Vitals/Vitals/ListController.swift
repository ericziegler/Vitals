//
//  ListController.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/19/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit

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

    // MARK: - VitalsControllerDelegate

    func vitalsUpdatedFor(controller: VitalsController) {
        vitalsTable.reloadData()
    }

}

