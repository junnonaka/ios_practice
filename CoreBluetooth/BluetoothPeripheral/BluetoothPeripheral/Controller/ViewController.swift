//
//  ViewController.swift
//  BluetoothPeripheral
//
//  Created by 野中淳 on 2021/06/16.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var startAdvertiseButton: UIButton!
    @IBOutlet weak var stopAdvertiseButton: UIButton!
    @IBOutlet weak var notifyButton: UIButton!
    @IBOutlet weak var indicateButton: UIButton!
    @IBOutlet weak var logTextView: UITextView!
    
    //MARK: - 変数
    // BLEで用いるサービス用のUUID
    let BLEServiceUUID = CBUUID(string:"AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE")

    // BLEで用いるキャラクタリスティック用のUUID
    let BLEWriteCharacteristicUUID = CBUUID(string:"AAAAAAAA-AAAA-BBBB-BBBB-BBBBBBBBBBBB")
    let BLEWriteWithoutResponseCharacteristicUUID = CBUUID(string:"AAAAAAAA-BBBB-BBBB-BBBB-BBBBBBBBBBBB")
    let BLEReadCharacteristicUUID = CBUUID(string:"AAAAAAAA-CCCC-BBBB-BBBB-BBBBBBBBBBBB")
    let BLENotifyCharacteristicUUID = CBUUID(string:"AAAAAAAA-DDDD-BBBB-BBBB-BBBBBBBBBBBB")
    let BLEIndicateCharacteristicUUID = CBUUID(string:"AAAAAAAA-EEEE-BBBB-BBBB-BBBBBBBBBBBB")


    //BLEで用いるサービス
    var service:CBMutableService?
    //BLEで用いるキャラクタリスティック：今回は全ての種類のCharacteristicを付与する
    //write属性のCharacteristic
    var writeCharacteristic:CBMutableCharacteristic?
    //writewithoutResponse属性のCharacteristic
    var writeWithoutResponseCharacteristic:CBMutableCharacteristic?
    //read属性のCharacteristic
    var readCharacteristic:CBMutableCharacteristic?
    //notify属性のCharacteristic
    var notifyCharacteristic:CBMutableCharacteristic?
    //indicate属性のCharacteristic
    var indicateCharacteristic:CBMutableCharacteristic?

    // BLEのペリフェラルマネージャー、ペリフェラルとしての挙動を制御する
    private var peripheralManager : CBPeripheralManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        //navigationの色変更
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular),.foregroundColor:UIColor.white]
        appearance.backgroundEffect = .none
        appearance.backgroundColor = UIColor.blue
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    //①BLEのペリフェラルを使用開始できる状態にセットアップ
    func setup()
    {
        //インスタンス化
        self.peripheralManager = CBPeripheralManager(delegate:self, queue:nil)
    }
    
    //③PeripheralにService及びCharacteristicを追加する
    func addService(){
        //サービスの設定
        service = CBMutableService(type: BLEServiceUUID, primary: true)

        //キャラクタリスティックの設定(properties:属性、permissions：読み出し書込みの可否を与える)
        writeCharacteristic = CBMutableCharacteristic(type: BLEWriteCharacteristicUUID, properties: .write, value: nil, permissions: [.writeable,.readable])
        
        writeWithoutResponseCharacteristic = CBMutableCharacteristic(type: BLEWriteWithoutResponseCharacteristicUUID, properties: .writeWithoutResponse, value: nil, permissions: .writeable)
        
        //readCharacteristicは読み出した時の初期値を与えておくと、初期値固定になるのでnilにする
        //let readData = Data( [0x55])
        readCharacteristic = CBMutableCharacteristic(type: BLEReadCharacteristicUUID, properties: .read, value: nil, permissions: .readable)

        notifyCharacteristic = CBMutableCharacteristic(type: BLENotifyCharacteristicUUID, properties: .notify, value: nil, permissions: .readable)

        
        indicateCharacteristic = CBMutableCharacteristic(type: BLEIndicateCharacteristicUUID, properties: .indicate, value: nil, permissions: .readable)

        //サービスにキャラクタリスティックの設定
        service?.characteristics = [writeCharacteristic!,writeWithoutResponseCharacteristic!,readCharacteristic!,notifyCharacteristic!,indicateCharacteristic!]
        
        //ペリフェラルにサービスを追加
        peripheralManager?.add(service!)
    }

    
    @IBAction func advertiseButtonTupped(_ sender: UIButton) {
        //④アドバタイズ開始
        startAdvertising();
        
    }
    
    @IBAction func stopAdvertiseButtonTupped(_ sender: UIButton) {
        //アドバタイズ停止
        stopAdvertising()
    }
    
    @IBAction func notifyButtonTup(_ sender: UIButton) {
        //notifyでデータをCentralに送る
        let notifyData = Data( [0xAA])
        peripheralManager?.updateValue(notifyData, for: notifyCharacteristic!, onSubscribedCentrals: nil)
    }
    
    
    @IBAction func indicateButtonTup(_ sender: UIButton) {
        //IndicateでデータをCentralに送る
        let indicateData = Data( [0xBB])
        peripheralManager?.updateValue(indicateData, for: indicateCharacteristic!, onSubscribedCentrals: nil)
    }
    
    
    //④アドバタイズを開始
    func startAdvertising()
    {
        //アドバタイズに乗せるService
        let serviceUUIDs = [BLEServiceUUID]
        //アドバタイズデータのセット（LocalName:BLEの設定画面で表示される名称）
        let advertisementData:[String:Any] = [CBAdvertisementDataLocalNameKey: "TEST BLE"
                                 ,CBAdvertisementDataServiceUUIDsKey:serviceUUIDs]
        //アドバタイズ開始
        self.peripheralManager?.startAdvertising(advertisementData)
    }

    // アドバタイズを停止
    func stopAdvertising()
    {
        self.peripheralManager?.stopAdvertising()
        startAdvertiseButton.isEnabled = true
        stopAdvertiseButton.isEnabled = false
        logTextView.text.append("Advertisingを停止しました\n")
        
    }
    
}

// MARK: - CBPeripheralManagerDelegate

extension ViewController : CBPeripheralManagerDelegate
{
    
    //Notify or Indicateの許可が行われた（ディスクリプタへの書き込み）時に呼ばれるDelegate
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("didSubscribeToCharacteristic")
        logTextView.text.append("didSubscribeToCharacteristic\n")
        if(characteristic.uuid == BLENotifyCharacteristicUUID){
            notifyButton.isEnabled = true
        }else if (characteristic.uuid == BLEIndicateCharacteristicUUID){
            indicateButton.isEnabled = true
        }
        
    }
    
    //Notify or Indicateの禁止が行われた（ディスクリプタへの書き込み）時に呼ばれるDelegate
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("didUnsubscribeFromCharacteristic")
        logTextView.text.append("didUnsubscribeFromCharacteristic\n")
        if(characteristic.uuid == BLENotifyCharacteristicUUID){
            notifyButton.isEnabled = false
        }else if (characteristic.uuid == BLEIndicateCharacteristicUUID){
            indicateButton.isEnabled = false
        }
    }

    //読み出し要求が行われた時に呼ばれるDelegate
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("didReceiveReadRequest")
        logTextView.text.append("didReceiveReadRequest\n")

        //読み出し許可の与えているキャラクタリスティックか確認
        if request.characteristic.uuid.isEqual(readCharacteristic?.uuid){
            let readData = Data( [0x55])
            //valueをセット
            request.value = readData
            logTextView.text.append("read value \(String(data:  readData, encoding: .utf8)!)\n")
            //読み出し要求に応える
            peripheralManager?.respond(to: request, withResult: .success)
        }else{
            //許可されていない読み出しとして応える
            peripheralManager?.respond(to: request, withResult: .readNotPermitted)
        }
    }
    
    //書き込み要求が行われた時に呼ばれるDelegate
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        logTextView.text.append("didReceiveWriteRequest\n")
        for request in requests {
            if request.characteristic.uuid.isEqual(writeCharacteristic?.uuid) {
                //valueをセット
                writeCharacteristic!.value = request.value
                logTextView.text.append("write value \(String(data:  request.value!, encoding: .utf8)!)\n")
                //リクエストに応答
                peripheralManager?.respond(to: requests[0], withResult: .success)
            }else if request.characteristic.uuid.isEqual(writeWithoutResponseCharacteristic?.uuid){
                //何もしない
            }
        }
        
    }

    //アドバタイズを開始した時に呼ばれるDelegate
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("アドバタイズ開始")
        if error == nil {
            logTextView.text.append("PeripheralがAdvertisingを開始しました\n")
            startAdvertiseButton.isEnabled = false
            stopAdvertiseButton.isEnabled = true
        } else {
            logTextView.text.append("PeripheralがAdvertisingの開始に失敗しました\(error?.localizedDescription)\n")
        }
    }
    
    //②Peripheralの状態が変化すると呼ばれるDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        //PeripheralManagerのインスタンス化を実施するとすぐにPowerOnが呼ばれる。
        logTextView.text.append("PeripheralのStateが変更されました。\n現在のState:\(peripheral.state.name)\n")

        if peripheral.state != .poweredOn {
            logTextView.text.append("異常なStateのため処理を終了します\n")
            return;
        }
        //③PeripheralにService及びCharacteristicを追加する
        addService()
    }

    //updateValueのキューがいっぱいの時に値を送信しようとすると呼ばれるDelegate
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        //この中で再送処理を入れるとよい
    }
    
    //PeripheralにServiceを追加した時に呼ばれるDelegate
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error == nil {
            logTextView.text.append("サービスが正常に追加されました\n")
        } else {
            logTextView.text.append("サービスの追加に失敗しました\(error?.localizedDescription)\n")
        }
    }
}

//以下はCBManagerSteteに名称を付けているだけ
extension CBManagerState
{
    var name : String {
        get{
            let enumName = "CBManagerState"
            var valueName = ""

            switch self {
            case .poweredOff:
                valueName = enumName + "PoweredOff"
            case .poweredOn:
                valueName = enumName + "PoweredOn"
            case .resetting:
                valueName = enumName + "Resetting"
            case .unauthorized:
                valueName = enumName + "Unauthorized"
            case .unknown:
                valueName = enumName + "Unknown"
            case .unsupported:
                valueName = enumName + "Unsupported"
            @unknown default:
                valueName = enumName + "Unknown"
            }

            return valueName
        }
    }
}
