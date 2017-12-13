//
//  ViewController.swift
//  swiftSqlite
//
//  Created by Prabu Govindasamy on 05/12/17.
//  Copyright © 2017 Prabu Govindasamy. All rights reserved.
//

import UIKit
import SQLite
import SQLite3

class ViewController: UIViewController {

    @IBOutlet weak var dispalyTextVw: UITextView!
    @IBOutlet weak var userIdFld: UITextField!
    let db = try! Connection("/Users/prabu_g/Desktop/SQLITE/DataBase/swiftSqlite.sqlite")
    
    let users = Table("users")
    let id = Expression<Int64>("id")
    let name = Expression<String?>("name")
    let email = Expression<String>("email")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       
        
        
    }

    
  
    
    @IBAction func clearTxtVw(_ sender: Any) {
        dispalyTextVw.text = ""
    }
    
    @IBAction func insertUserBtnAction(_ sender: Any) {
        let randomUser = randomAlphaNumericString(length: 3)
        
        let insert = users.insert(name <- randomUser , email <- "\(randomUser)@mac.com")
        _ = try! db.run(insert)
    }
    
    @IBAction func fetchAllUserBtnAction(_ sender: Any) {
        
        for user in try! db.prepare(users) {
            let rowValue = "\n id: \(String(user[id])), name: \(user[name] ?? "name"), email: \(String(user[email]))"
            dispalyTextVw.text  = dispalyTextVw.text + rowValue
            
            //print("id: \(user[id]), name: \(String(describing: user[name])), email: \(user[email])")
            // id: 1, name: Optional("Alice"), email: alice@mac.com
        }
    }
    
    @IBAction func fetchUserIdAction(_ sender: Any) {
       userIdFld.text != "" ? fetchUserWithId(id: userIdFld.text! as NSString) : nil
    }
    
    
    @IBAction func fetchUserIdAction_RASP(_ sender: Any) {
        userIdFld.text != "" ? fetchUserWithId_RASP(id: userIdFld.text! as NSString) : nil
    }
    
   
    
    
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        checkTableExist()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func randomAlphaNumericString(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        return randomString
    }

    // Clear DB users
    @IBAction func clearBtnAction(_ sender: Any) {
        let malformedQueryString = "DELETE from users;"
        
        _ = try! db.run(malformedQueryString)
        
        dispalyTextVw.text = ""
    }
    
    // TABLE EXIST
    func checkTableExist() {
        let malformedQueryString = "SELECT name FROM sqlite_master WHERE type='table';"
        
        var tableExist = false
        
        for table in  try! db.run(malformedQueryString)
        {
            if table[0] as! String == "users"
            {
                tableExist = true
            }
            
        }
        tableExist == false ? createTable() : nil
        
    }
    
    // CREATE TABLE
    func createTable()  {
        try! db.run(users.create { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(email, unique: true)
        })
    }
    
    //FETCH WO RASP
    func fetchUserWithId(id : NSString)
    {
        let malformedQueryString = "SELECT id , name , email FROM users where id = \(id) ;"
        
        for row in try! db.run(malformedQueryString) {
            
            let rowValue = "\n id: \(row[0] ?? "row"), name: \(row[1]  ?? "name"), email: \(row[2]  ?? "email")"
            
            dispalyTextVw.text  = dispalyTextVw.text + rowValue
            
        }
        
    }
    
    //FETCH WITH RASP
    func fetchUserWithId_RASP(id : NSString)
    {
        let malformedQueryString = "SELECT id , name , email FROM users where id = \(id) ;"
        var token =  checkToken(query: (malformedQueryString as NSString) as String)
        if checkTokenExist(token: token)
        {
            for row in try! db.run(malformedQueryString) {
                
                let rowValue = "\n id: \(row[0] ?? "row"), name: \(row[1]  ?? "name"), email: \(row[2]  ?? "email")"
                
                dispalyTextVw.text  = dispalyTextVw.text + rowValue
                
            }
        }
    }
    
    //CREATE TOKEN
    func checkToken(query : String) -> String  {
        var str = ""

        let regex = try! NSRegularExpression(pattern: "[0-9]+", options: .caseInsensitive)
        str = regex.stringByReplacingMatches(in: query, options: [], range: NSRange(0..<query.utf16.count), withTemplate: "NUMERIC")
        
        return str
    }
    
    //CHECK TOKEN EXIST
    func checkTokenExist(token : String) -> Bool {
        let malformedQueryString = NSString(format:"SELECT token FROM queryToken WHERE token = \"%@\" ;", token);
        
        for row in try! db.run(malformedQueryString as String) {
            
            return true
        }
        return false
 
    }
}



