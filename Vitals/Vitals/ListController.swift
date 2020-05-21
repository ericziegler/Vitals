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

    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        vitalsTable.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 0)
        setupNavBar()
    }

    private func setupNavBar() {
        self.title = "Vitals"
        if let addImage = UIImage(named: "Add") {
            let addButton = UIButton(type: .custom)
            addButton.addTarget(self, action: #selector(addTapped(_:)), for: .touchUpInside)
            addButton.setImage(addImage, for: .normal)
            addButton.frame = CGRect(x: 0, y: 0, width: addImage.size.width, height: addImage.size.height)
            let addItem = UIBarButtonItem(customView: addButton)
            self.navigationItem.rightBarButtonItem = addItem
        }
    }

    // MARK: - Actions

    @IBAction func addTapped(_ sender: AnyObject) {
        showVitalsControllerFor(vitals: nil)
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

