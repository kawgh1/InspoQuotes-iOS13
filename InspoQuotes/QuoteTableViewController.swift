//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {
 
    
    let productId = "io.kwebdev.InspoQuotes.PremiumQuotes"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Debugger is running...")

        // set this ViewController as the delegate to run the SKPaymentQueue (In-App Purchase) methods
        SKPaymentQueue.default().add(self)
        
        if hasPurchased() {
            showPremiumQuotes()
        }
        
    
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        
        if hasPurchased() {
            return quotesToShow.count
        } else {
            // the + 1 is our last cell that is a button that says "Buy More Quotes"
            return quotesToShow.count + 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        
        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = UIColor.white
            cell.accessoryType = .none
        } else {
            // last cell is for buy quotes button for in-app purchase
            cell.textLabel?.text = "Buy More Quotes"
            cell.textLabel?.textColor = UIColor(hex: "#38b5a4ff")
                cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
           buyPremiumQuotes()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
        
// MARK: - In-App Purchase Methods
    
    func buyPremiumQuotes() {
        
        // check is user authorized to make purchase
        if SKPaymentQueue.canMakePayments() {
            
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productId
            SKPaymentQueue.default().add(paymentRequest)
            
        } else {
            print("User is not authorized to make in-app purchases.")
        }
    }
    
    // gets called every time the transaction status is updated
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                // User payment successful or already purchased
                print("Transaction success!")
                
                showPremiumQuotes()
                SKPaymentQueue.default().finishTransaction(transaction)

                
            } else if transaction.transactionState == .failed {
                // User payment failed
                print("Transaction failed!")
                
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    print("Transaction failed! Error: \(errorDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)


            } else if transaction.transactionState == .restored {
                showPremiumQuotes()
                print("Transaction restored!")
                // hide Restore button
                navigationItem.setRightBarButton(nil, animated: true)
                SKPaymentQueue.default().finishTransaction(transaction)

            }
            

        }
    }
    
    
    func showPremiumQuotes() {
        // add key if user purchased app that can be checked with hasPurchased()
        UserDefaults.standard.set(true, forKey: productId)
        
        quotesToShow.append(contentsOf: premiumQuotes)
        
        tableView.reloadData()
    }
    
    func hasPurchased() -> Bool {
        let purchaseStatus = UserDefaults.standard.bool(forKey: productId)
        
        if purchaseStatus {
            print("Already purchased app!")
            return true
        } else {
            print("Never purchased app!")
            return false
        }
    }
        
        
        
        
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        // checks app user's Apple ID in Apple servers to see if they have purchased this app
        // if yes, restore the purchase
        SKPaymentQueue.default().restoreCompletedTransactions()
        
    }


}
    
// MARK: - Hex color

    extension UIColor {
        public convenience init?(hex: String) {
            let r, g, b, a: CGFloat

            if hex.hasPrefix("#") {
                let start = hex.index(hex.startIndex, offsetBy: 1)
                let hexColor = String(hex[start...])

                if hexColor.count == 8 {
                    let scanner = Scanner(string: hexColor)
                    var hexNumber: UInt64 = 0

                    if scanner.scanHexInt64(&hexNumber) {
                        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                        a = CGFloat(hexNumber & 0x000000ff) / 255

                        self.init(red: r, green: g, blue: b, alpha: a)
                        return
                    }
                }
            }

            return nil
        }
    }
