//
//  AccountStateViewController.swift
//  ZKSyncSDK_Example
//
//  Created by Eugene Belyakov on 07/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSyncSDK

class AccountStateViewController: UIViewController, WalletConsumer {

    var wallet: Wallet!

    var accountState: AccountState?
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        self.tableView.register(UINib(nibName: "StateSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "StateHeader")
        
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedSectionHeaderHeight = 60;
    }
    
    @IBAction func getAccountState(_ sender: Any) {
        wallet.getAccountInfo { (result) in
            switch result {
            case .success(let state):
                self.update(state: state)
            case .failure(_):
                break
            }
        }
    }
    
    private func update(state: AccountState) {
        self.accountState = state
        self.tableView.reloadData()
        self.addressLabel.text = state.address
        self.idLabel.text = "\(state.id ?? 0)"
    }
}

extension AccountStateViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.accountState?.committed.balances.count ?? 0
        case 1:
            return self.accountState?.verified.balances.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0, 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell") ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "BalanceCell")
            let balances = indexPath.section == 0 ? self.accountState!.committed.balances : self.accountState!.verified.balances
            let key = Array(balances)[indexPath.row].key
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = balances[key]
            return cell
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "StateHeader") as? StateSectionHeaderView
        switch section {
        case 0:
            headerView?.nonceLabel.text = "\(self.accountState?.committed.nonce ?? 0)"
            headerView?.pubKeyHashLabel.text = self.accountState?.committed.pubKeyHash
            headerView?.nameLabel.text = "Committed"
        case 1:
            headerView?.nonceLabel.text = "\(self.accountState?.verified.nonce ?? 0)"
            headerView?.pubKeyHashLabel.text = self.accountState?.verified.pubKeyHash
            headerView?.nameLabel.text = "Verified"
        default:
            break
        }
        return headerView
    }
}
