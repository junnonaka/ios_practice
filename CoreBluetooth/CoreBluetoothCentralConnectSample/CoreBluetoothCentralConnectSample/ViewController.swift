//
//  ViewController.swift
//  CoreBluetoothCentralConnectSample
//
//  Created by 野中淳 on 2022/05/21.
//

import UIKit

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    private var centralManager:CBCentralManager!
    private var cbPeripheral:CBPeripheral? = nil
    private var writeCharacteristic: CBCharacteristic? = nil
    private var readCharacteristic: CBCharacteristic? = nil
    
    // BLEで用いるサービス用のUUID
    let BLELoacalName = "TEST BLE"
    
    let BLEServiceUUID = CBUUID(string:"AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")

    // BLEで用いるキャラクタリスティック用のUUID
    let BLEWriteCharacteristicUUID = CBUUID(string:"AAAAAAAA-AAAA-BBBB-BBBB-BBBBBBBBBBBB")
    let BLEWriteWithoutResponseCharacteristicUUID = CBUUID(string:"AAAAAAAA-BBBB-BBBB-BBBB-BBBBBBBBBBBB")
    let BLEReadCharacteristicUUID = CBUUID(string:"AAAAAAAA-CCCC-BBBB-BBBB-BBBBBBBBBBBB")
    let BLENotifyCharacteristicUUID = CBUUID(string:"AAAAAAAA-DDDD-BBBB-BBBB-BBBBBBBBBBBB")
    let BLEIndicateCharacteristicUUID = CBUUID(string:"AAAAAAAA-EEEE-BBBB-BBBB-BBBBBBBBBBBB")
    
    //MARK: - IBOutlet
    @IBOutlet weak var connectStateLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var writeButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var connectLabel: UILabel!
    
    
    //MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        logTextView.isEditable = false
        bleInit()
    }
    
    //MARK: - IBActions
    @IBAction func connectStart(_ sender: UIButton) {
        scan()
    }
    
    @IBAction func disconnectButtonTup(_ sender: UIButton) {
        disconnectPeripheral()
    }
    
    @IBAction func writeButtonTup(_ sender: UIButton) {
        let strData : String = "10"
        let data : Data = strData.data(using: .utf8)!
        sendData(data)
    }
    
    @IBAction func readButtonTup(_ sender: UIButton) {
        readData()
    }
    
    
    //①セントラルマネージャーの初期化
    private func bleInit() {
        //セントラルマネージャーを初期化：初期化した時点でPermissionの許諾のpopupが出て、Bluetoothの電源がONになる。
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    //③Peripheralのスキャン
    private func scan(){
        //Bluetoothの状態がONになっていることを確認
        if centralManager.state == .poweredOn{
            //Service指定せず周囲の全てのPeripheralをスキャンする
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            
            //Serviceを指定してスキャンをする
            //デリゲートメソッドが指定のサービス以外で呼ばれなく、効率的であるため、こちらがベストプラクティス
            //let services: [CBUUID] = [CBUUID(string: "サービスのUUID")]
            //centralManager.scanForPeripherals(withServices: services, options: nil)
            
            //タイマーなど設けずスキャンをしているが、この場合は所望のペリフェラルが見つかるまでスキャンし続けてしまうので、
            //実際に使う場合はタイマーでスキャンを停止する、スキャン停止ボタンを設けるなどの配慮が必要
//            scanTimer = Timer.scheduledTimer(timeInterval: TimeInterval(10),
//                                                  target: self,
//                                                  selector: #selector(self.timeOutScanning),
//                                                  userInfo: nil,
//                                                  repeats: false)
//            ///スキャンタイムアウト
//            @objc func timeOutScanning() {
//                centralManager.stopScan()
//            }
            
            
        }
    }
    
    //データの送信
    private func sendData(_ data:Data){
        //データの書き込み：属性がwrite with responseの場合
        if let peripheral = self.cbPeripheral,let writeCharacteristic = self.writeCharacteristic{
            peripheral.writeValue(data, for: writeCharacteristic, type: CBCharacteristicWriteType.withResponse)
        }
        
        //データの書き込み：属性がwrite without responseの場合
        //        if let peripheral = self.cbPeripheral,let writeCharacteristic = self.writeCharacteristic{
        //            peripheral.writeValue(data, for: writeCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
        //        }
    }
    
    //データの読み出し
    private func readData(){
        if let peripheral = self.cbPeripheral,let readCharacteristic = self.readCharacteristic{
            peripheral.readValue(for: readCharacteristic)
        }
    }
    
    //切断処理
    private func disconnectPeripheral(){
        if let peripheral = cbPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    

    
    
}

//MARK: - extention CBCentralManagerDelegate
extension ViewController:CBCentralManagerDelegate{
    //BLEの状態が変化する毎に呼ばれるメソッド
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            //②:セントラル側BLEの電源ONを待つ
            //BLEが使用可能な状態：電源がONになっている
        case CBManagerState.poweredOn:
            print("Bluetooth PowerON")
            logTextView.text.append("Bluetooth PowerON\n")
            break
            //BLEが使用出来ない状態：電源がONになっていない
        case CBManagerState.poweredOff:
            print("Bluetooth PoweredOff")
            logTextView.text.append("Bluetooth PoweredOff\n")

            break
            //BLEが使用出来ない状態：リセット中
        case CBManagerState.resetting:
            print("Bluetooth resetting")
            logTextView.text.append("Bluetooth resetting\n")

            break
            //BLEが使用出来ない状態：Permissionの許諾が得られていない
        case CBManagerState.unauthorized:
            print("Bluetooth unauthorized")
            logTextView.text.append("Bluetooth unauthorized\n")

            break
            //BLEが使用出来ない状態：不明な場外
        case CBManagerState.unknown:
            print("Bluetooth unknown")
            logTextView.text.append("Bluetooth unknown\n")

            break
            //BLEが使用出来ない状態：BLEをサポートしていない
        case CBManagerState.unsupported:
            print("Bluetooth unsupported")
            logTextView.text.append("Bluetooth unsupported\n")

            break
        }
    }
    //④スキャンでPeripheralが見つかる毎に呼ばれるメソッド
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //peripheralのローカルネーム
        print("name:\(peripheral.name)")
        //advertiseの中身
        print("advertisementData:\(advertisementData)")
        //advertiseに入っているServiceUUID
        print("advertisementServiceUUID:\(advertisementData["kCBAdvDataServiceUUIDs"])")
        //advertiseの電波強度（RSSI）
        print("rssi:\(RSSI.stringValue)")
        
        if let peripheralName = advertisementData["kCBAdvDataLocalName"] as? String{
            //名称フィルターして接続する場合
            if peripheral.name == BLELoacalName || peripheralName == BLELoacalName{
                //見つけたペリフェラルを保持
                self.cbPeripheral = peripheral
                central.connect(peripheral, options: nil)
                //スキャン停止
                centralManager.stopScan()

            }
        }

       
        
        //アドバタイズに入っているService UUIDでフィルターして接続する場合
        //※本来はscanの時点でadvertisementDataを指定することでフィルターをかけるので使用シーンはほとんど無いと思われる
//        let SERVICE_UUID:CBUUID = CBUUID(string: "接続したい機器がアドバタイズに乗っけているServiceUUID")
//        if advertisementData["kCBAdvDataServiceUUIDs"] != nil {
//            let UUID:[CBUUID] = advertisementData["kCBAdvDataServiceUUIDs"] as! [CBUUID]
//            //アドバタイズに入っているUUIDは一つだけのため
//            if UUID.first == SERVICE_UUID{
//                central.connect(peripheral, options: nil)
//            }
//            //スキャン停止
//            centralManager.stopScan()
//        }
    }
    
    //⑤接続が成功したときに呼ばれるデリゲートメソッド
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logTextView.text.append("Connect Peripheral\n")
        connectButton.isEnabled = false
        disconnectButton.isEnabled = true
        connectLabel.text = "接続状態：接続中"
        
        //ペリフェラルのデリゲートをセット
        peripheral.delegate = self
        // 指定のサービスを探す：機器は複数のサービスを持っているので使いたいサービスのみ探すべきである
//        let services: [CBUUID] = [CBUUID(string: "サービスのUUID")]
//        peripheral.discoverServices(services)
        
        //サービスを指定せずにペリフェラルの全てのサービスを探す
        peripheral.discoverServices(nil)
        logTextView.text.append("discoverServices\n")
        //サービスが見つかるとCBPeripheralのデリゲートメソッドが呼ばれる。
        
    }
    
    //⑤'接続が失敗したときに呼ばれるデリゲートメソッド
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("接続失敗")
        logTextView.text.append("接続失敗\n")

    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("切断")
        logTextView.text.append("切断完了\n")
        connectButton.isEnabled = true
        disconnectButton.isEnabled = false
        writeButton.isEnabled = false
        readButton.isEnabled = false
        connectLabel.text = "接続状態：未接続"

    }
}

extension ViewController:CBPeripheralDelegate{
    
    //⑥ ⑤で探したサービスが見つかった時に呼ばれるデリゲートメソッド
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        logTextView.text.append("didDiscoverServices\n")
        //キャラクタリスティック検索開始　指定して検索。以下は一つしか指定していないが配列なので複数指定も可能
        //機器は複数の機能を持っていることがほとんどなので欲しいキャラクタリスティックのみを検索するのが効率的
        //let charcteristicUUID:CBUUID = CBUUID(string: "検索したいUUID")
        //peripheral.discoverCharacteristics([charcteristicUUID],
        //                                   for: (peripheral.services?.first)!)
        
        //全てのサービスのキャラクタリスティックの検索
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    //⑦ ⑥で探したキャラクタリスティックが見つかった時に呼ばれるデリゲートメソッド
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics!{
            if characteristic.uuid == BLENotifyCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                logTextView.text.append("discover Notify Characteristic\n")
            }
            
            if characteristic.uuid == BLEIndicateCharacteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
                logTextView.text.append("discover Indicate Characteristic\n")
            }
            
            if characteristic.uuid == BLEWriteCharacteristicUUID {
                writeCharacteristic = characteristic
                writeButton.isEnabled = true
                logTextView.text.append("discover Write Characteristic\n")

            }
            if characteristic.uuid == BLEReadCharacteristicUUID{
                readCharacteristic = characteristic
                readButton.isEnabled = true
                logTextView.text.append("discover Read Characteristic\n")

            }
            //なおcharacteristicの属性は以下で取得可能
            //characteristic.propertie
            //「.indicate .notify .read .write .writeWithoutResponse」で属性の判別が可能
            print("発見したキャラクタリスティック",characteristic.uuid.uuidString)
        }
    }
    
    //write実行時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("書き込みエラー：",error.localizedDescription)
            return
        }else{
            print("書き込み成功：",characteristic.uuid)
            logTextView.text.append("書き込み成功：\(characteristic.uuid) \n")

        }
    }
    
    //Notify or indicate or Read時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("送信元のCharacteristic:",characteristic.uuid.uuidString)
        if let error = error {
            print("情報受信失敗...error:",error.localizedDescription)
        } else {
            print("受信成功")
            let receivedData = String(bytes: characteristic.value!, encoding: String.Encoding.ascii)
            print("受信データ",receivedData)
            switch characteristic.properties{
            case .read:
                logTextView.text.append("read \n")
            case .indicate:
                logTextView.text.append("indicate \n")

            case .notify:
                logTextView.text.append("notify \n")
            default:
                logTextView.text.append("unknown \n")
            }

            logTextView.text.append("受信データ：\(receivedData) \n")

        }
    }
}
