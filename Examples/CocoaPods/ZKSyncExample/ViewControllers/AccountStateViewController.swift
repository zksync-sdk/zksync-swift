//
//  AccountStateViewController.swift
//  ZKSyncExample
//
//  Created by Eugene Belyakov on 07/01/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import ZKSync
import ZKSyncCrypto

class AccountStateViewController: UIViewController, WalletConsumer {

    var wallet: Wallet!

    var accountState: AccountState?

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addressLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44
        self.tableView.register(UINib(nibName: "StateSectionHeaderView", bundle: nil),
                                forHeaderFooterViewReuseIdentifier: "StateHeader")

        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 60
    }

    @IBAction func getAccountState(_ sender: Any) {
        wallet.getAccountState { (result) in
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
        self.addressLabel.text = "Address: " + state.address
        self.idLabel.text = "ID: \(state.id ?? 0)"
    }
}

extension AccountStateViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return accountState != nil ? 3 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.accountState?.committed.balances.count ?? 0
        case 1:
            return self.accountState?.verified.balances.count ?? 0
        case 2:
            return self.accountState?.depositing.balances.count ?? 0
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0, 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BalanceCell")
                ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: "BalanceCell")
            let balances = indexPath.section == 0
                ? self.accountState!.committed.balances
                : self.accountState!.verified.balances
            let key = Array(balances)[indexPath.row].key
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = balances[key]
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Depositing",
                                                           for: indexPath) as? DepositingBalanceTableViewCell else {
                return UITableViewCell()
            }
            let balances = self.accountState!.depositing.balances
            let key = Array(balances)[indexPath.row].key
            let balance = balances[key]!
            cell.titleLabel.text = key
            cell.amountLabel.text = "Amount: " + balance.amount
            cell.blockNumber.text = "Block number: \(balance.expectedAcceptBlock)"
            return cell
        default:
            break
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0, 1:
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "StateHeader")
                as? StateSectionHeaderView
            let state = section == 0 ? self.accountState?.committed : accountState?.verified
            headerView?.nonceLabel.text = "\(state?.nonce ?? 0)"
            headerView?.pubKeyHashLabel.text = state?.pubKeyHash
            headerView?.nameLabel.text = section == 0 ? "Committed" : "Verified"
            return headerView
        case 2:
            let label = UILabel()
            label.textColor = .black
            label.text = "Depositing"
            label.textAlignment = .center
            return label
        default:
            break
        }
        return nil
    }
}
