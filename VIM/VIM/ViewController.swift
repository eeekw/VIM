//
//  ViewController.swift
//  VIM
//
//  Created by Leaf on 2017/11/23.
//  Copyright © 2017年 leaf. All rights reserved.
//

import UIKit
import Socket
import IQKeyboardManagerSwift

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    let client = Client()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        client.delegate = self
        client.connect(to: "localhost", port: 1337)

        tableView.register(MessagesCell.self, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var messages = [Message]()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MessagesCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    @IBAction func send(_ sender: UIButton) {
        
        if textField.text == "" {
            return
        }
        
        let message = Message(text: textField.text, from: 0, to: 1)
        messages.append(message)
        
        tableView.reloadData()
        
        guard let data = message.text?.data(using: .utf8) else {
            print("Error decoding response...")
            
            return
        }
        
        client.write(from: data)
    }
    
}

extension ViewController: ClientDelegate {
    
    func didReadData(data: Data) {
        
        guard let response = String(data: data, encoding: .utf8) else {
            
            print("Error decoding response...")
            
            return
        }
        
        let message = Message(text: response, from: 1, to: 0)
        messages.append(message)
        tableView.reloadData()
    }
}


protocol ClientDelegate {
    
    func didReadData(data: Data)
}

class Client {

    static let bufferSize = 4096

    var socket: Socket? = nil
    var continueRunning = true

    deinit {
        // Close all open sockets...
        self.socket?.close()
    }

    var delegate: ClientDelegate?
    
    func connect(to host: String, port: Int32) {

        let queue = DispatchQueue.global(qos: .default)

        queue.async { [unowned self] in

            do {
                // Create an IPV6 socket...
                try self.socket = Socket.create(family: .inet6)

                guard let socket = self.socket else {

                    print("Unable to unwrap socket...")
                    return
                }

                try socket.connect(to: host, port: port)

                print("connected to host: \(socket.remoteHostname) on port \(socket.remotePort)")

                var readData = Data(capacity: Client.bufferSize)
                
                repeat {

                    let bytesRead = try socket.read(into: &readData)

                    if bytesRead > 0 {
                        self.delegate?.didReadData(data: readData)
                        guard let response = String(data: readData, encoding: .utf8) else {
                              
                            print("Error decoding response...")
                            readData.count = 0
                            break
                        }
                        
                        print("Client received from connection at \(socket.remoteHostname):\(socket.remotePort): \(response) ")

                    }

                } while self.continueRunning

            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    print("Unexpected error...")
                    return
                }

                if self.continueRunning {

                    print("Error reported:\n \(socketError.description)")

                }
            }
        }
    }
    
    func write(from data:Data) -> Void {
        
        do {
            try self.socket?.write(from: data)
        }
        catch let error {
            guard let socketError = error as? Socket.Error else {
                print("Unexpected error...")
                return
            }
            if self.continueRunning {
                
                print("Error reported:\n \(socketError.description)")
                
            }
        }
        
    }
}
