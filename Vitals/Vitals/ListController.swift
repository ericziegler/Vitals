//
//  ListController.swift
//  Vitals
//
//  Created by Eric Ziegler on 5/19/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit

class ListController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

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
        
    }

}

