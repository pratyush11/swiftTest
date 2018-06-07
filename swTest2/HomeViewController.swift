//
//  HomeViewController.swift
//  swTest2
//
//  Created by Ghazalah on 1/23/18.
//  Copyright © 2018 Pratyush. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreBluetooth


class HomeViewController: UIViewController  {

    var manager:CBCentralManager!
    var peripheral:CBPeripheral!
    var centralManager:CBCentralManager!
    var keepScanning = false
    var peripherals = Array<CBPeripheral>()
    let timerPauseInterval:TimeInterval = 1.0
    let timerScanInterval:TimeInterval = 2.0
    let sections = ["Available Devices"]
    var peripheralNames = Array<String>()
    let ServiceCBUUID = CBUUID(string: "0000ffe0-0000-1000-8000-00805f9b34fb")
    let CharCBUUID = CBUUID(string: "0000ffe1-0000-1000-8000-00805f9b34fb")
    let Char_CBUUID = CBUUID(string: "FFE1")
    var rxChar:CBCharacteristic!
    var txChar:CBCharacteristic!
    var characteristicASCIIValue: NSString!
    @IBOutlet weak var tableView: UITableView!
    var characteristics = [String : CBCharacteristic]()
    var data: String!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginPage")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        centralManager.stopScan()
        let peripheral = peripherals[indexPath.row]
        centralManager.connect(peripheral)
    }
    
    
    
}


extension HomeViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var state = " "
        var showAlert = true
        switch central.state {
        case .poweredOn:
            showAlert = false
            keepScanning = true
            // 2
            //_ = Timer(timeInterval: timerScanInterval, target: self, selector: #selector(pauseScan), userInfo: nil, repeats: false)
            // 3
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff:
            state = "Bluetooth on this device is currently powered off."
        case .unsupported:
            state = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            state = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            state = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            state = "The state of the BLE Manager is unknown."
        }
        
        print(state)
        if showAlert {
            let alertController = UIAlertController(title: "Central Manager State", message: state, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(okAction)
            self.show(alertController, sender: self)
        }
    }
    
    func pauseScan() {
        print("*** PAUSING SCAN...")
        _ = Timer(timeInterval: timerPauseInterval, target: self, selector: #selector(resumeScan), userInfo: nil, repeats: false)
        centralManager.stopScan()
    }
    
    @objc func resumeScan() {
        if keepScanning {
            print("*** RESUMING SCAN!")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            //disconnectButton.enabled = true
        }
    }
    //
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Peripheral discovered: \(peripheral) RSSI: \(RSSI)")
        var flag = false
        for peripheral_t in peripherals {
            if(peripheral.identifier == peripheral_t.identifier) {
                flag = true
            }
        }
        if(!flag && peripheral.name != nil) {
            peripherals.append(peripheral)
            peripherals = peripherals.sorted(by: { $0.rssi?.compare($1.rssi!) == .orderedDescending })
            tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to: \(peripheral)")
        peripheral.delegate = self
        peripheral.discoverServices([ServiceCBUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //self.centralManager.connect(peripheral)
        let alert = UIAlertController(title: "Disconnected", message: "Disconnected from device!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Reconnect?", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
            self.centralManager.connect(peripheral)
        }))
        self.present(alert, animated: true)
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //self.centralManager.connect(peripheral)
        //TODO: implement silent retry
        let alert = UIAlertController(title: "Failed", message: "Connection failed.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Try Again?", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
            self.centralManager.connect(peripheral)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
}

extension HomeViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
            peripheral.delegate = self
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            switch characteristic.uuid {
            case Char_CBUUID:
                peripheral.setNotifyValue(true, for: characteristic)
                
            default:
                print("Characteristic not found")
            }
       // peripheral.discoverDescriptors(for: characteristic)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == Char_CBUUID {
            if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                characteristicASCIIValue = ASCIIstring
                print("Value Received: \((characteristicASCIIValue as String))")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error!)
        }
        else {
            print(characteristic)
            print("Updated Notification State successfully")
            data = "200,0,0,0,0,0,0,0,0,0,0,0,0,0,0"
            let dataVal: Data = (data as NSString).data(using: String.Encoding.utf8.rawValue)!
            peripheral.writeValue(dataVal, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
            print("Sent: \(data)")
        }
    }
    
//    func writeValue(data: String){
//        let dataVal: Data = (data as NSString).data(using: String.Encoding.utf8.rawValue)!
//        peripheral.writeValue(dataVal, for: rxChar, type: CBCharacteristicWriteType.withResponse)
//    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error!)
        }
        else {
            print("Written value")
        }
    }
    
    
}
