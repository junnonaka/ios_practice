
#include <M5Core2.h>
#include <NimBLEDevice.h>

#define LOCAL_NAME                  "M5Stack-Secure"
#define COMPLETE_LOCAL_NAME         "M5Stack-Secure"

#define SERVICE_UUID                "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
#define CHARACTERISTIC_UUID_RX      "AAAAAAAA-BBBB-AAAA-AAAA-AAAAAAAAAAAA"//out
#define CHARACTERISTIC_UUID_NOTIFY  "AAAAAAAA-CCCC-AAAA-AAAA-AAAAAAAAAAAA"//in


//画像
#include "image.cpp"
//Characteristic
NimBLECharacteristic * pNotifyCharacteristic;
//NimBLEServer
NimBLEServer *pServer = NULL;

bool deviceConnected = false;
bool oldDeviceConnected = false;

bool isButtonAPressed = false;
bool isButtonBPressed = false;
bool isButtonCPressed = false;

uint8_t data_buff[2];  // データ通知用バッファ

class ServerCallbacks: public NimBLEServerCallbacks {
    void onConnect(NimBLEServer* pServer) {
        Serial.println("Client connected");
        deviceConnected = true;
    };
    //SecurytyRequestをペリフェラルから送るとき
//    void onConnect(NimBLEServer* pServer, ble_gap_conn_desc* desc) {
//        Serial.print("Client address: ");
//        Serial.println(NimBLEAddress(desc->peer_ota_addr).toString().c_str());
//
//        NimBLEDevice::startSecurity(desc->conn_handle);
//
//        pServer->updateConnParams(desc->conn_handle, 24, 48, 0, 60);
//        deviceConnected = true;
//    };
    void onDisconnect(NimBLEServer* pServer) {
        Serial.println("Client disconnected - start advertising");
        //NimBLEDevice::startAdvertising();
        deviceConnected = false;
    };
    void onMTUChange(uint16_t MTU, ble_gap_conn_desc* desc) {
        Serial.printf("MTU updated: %u for connection ID: %u\n", MTU, desc->conn_handle);
    };

    uint32_t onPassKeyRequest(){
        Serial.println("Server Passkey Request");
        return 123456; 
    };

    bool onConfirmPIN(uint32_t pass_key){
        Serial.print("The passkey YES/NO number: ");Serial.println(pass_key);
        return true; 
    };

    void onAuthenticationComplete(ble_gap_conn_desc* desc){
        if(!desc->sec_state.encrypted) {
            NimBLEDevice::getServer()->disconnect(desc->conn_handle);
            Serial.println("Encrypt connection failed - disconnecting client");
            return;
        }
        Serial.println("Starting BLE work!");
        M5.Lcd.drawString("Secure     ", 100, 95);
    };
};

//Bluetooth LE Recive
class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string rxValue = pCharacteristic->getValue();

      pCharacteristic->notify();
      
      unsigned char buffer[rxValue.length()];
      int intbuffer[rxValue.length()];
      memcpy(buffer, rxValue.data(), rxValue.length());
      int t;
      for (int i = 0;i<rxValue.length();i++){
        intbuffer[i] = (unsigned char)buffer[i];
        t = (unsigned char)buffer[i];
        Serial.println(t);
      }
    }
};


// Bluetooth LE loop
void loopBLE() {
    // disconnecting
    if (!deviceConnected && oldDeviceConnected) {
        delay(500); // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("startAdvertising");
        oldDeviceConnected = deviceConnected;
        M5.Lcd.setTextSize(2);
        M5.Lcd.drawString("DisConnected    ", 90, 115);
        M5.Lcd.drawString("            ", 100, 95);
        M5.Lcd.fillRect(2, 10, 43, 54, BLACK);

    }
    // connecting
    if (deviceConnected && !oldDeviceConnected) {
    // do stuff here on connecting
       oldDeviceConnected = deviceConnected;
       M5.Lcd.setTextSize(2);
       M5.Lcd.drawString("Connected     ", 90, 115);
       M5.Lcd.drawBitmap(3,10,41,52,bleimage);
    }

    if (M5.BtnA.pressedFor(100)) {
      if(isButtonAPressed == false){
        Serial.println("BtnA pressed");
        isButtonAPressed = true;
        data_buff[0] = (int16_t)(11);
        data_buff[1] = (int16_t)(11);
        pNotifyCharacteristic->setValue(data_buff, 2);
        pNotifyCharacteristic->notify();
      }
    }else if(M5.BtnB.pressedFor(100)){
      if(isButtonBPressed == false){
        Serial.println("BtnB pressed");
        isButtonBPressed = true;
        data_buff[0] = (int16_t)(22);
        data_buff[1] = (int16_t)(22);
        pNotifyCharacteristic->setValue(data_buff, 2);
        pNotifyCharacteristic->notify();
        
      }
    }else if(M5.BtnC.pressedFor(100)){
      if(isButtonCPressed == false){
        Serial.println("BtnC pressed");
        isButtonCPressed = true;
        data_buff[0] = (int16_t)(22);
        data_buff[1] = (int16_t)(22);
        pNotifyCharacteristic->setValue(data_buff, 2);
        pNotifyCharacteristic->notify();
      }
    }else{
    }
    
    if (M5.BtnA.isReleased()) {
      if(isButtonAPressed == true){
        isButtonAPressed = false;
        Serial.println("BtnA rereiced");
        
      }
    }
    
    if(M5.BtnB.isReleased()){
      if(isButtonBPressed == true){
        isButtonBPressed = false;
        Serial.println("BtnB rereiced");
      }
    }

    if(M5.BtnC.isReleased()){
        if(isButtonCPressed == true){
        isButtonCPressed = false;
        Serial.println("BtnC rereiced");
      }
    }

    
}

void setup() {
    // Initialize the M5Stack object
  M5.begin();
  Serial.begin(115200);
  M5.Lcd.print("Setup....");

  M5.Lcd.println("Done");
  M5.Lcd.clear(TFT_BLACK);

  M5.Lcd.setTextSize(2);
  M5.Lcd.drawString("DisConnected    ", 90, 115);
  
  Serial.println("Starting NimBLE Server");
  //CompleteLocalNameのセット
  NimBLEDevice::init(COMPLETE_LOCAL_NAME);
  //TxPowerのセット
  NimBLEDevice::setPower(ESP_PWR_LVL_P9);

  //セキュリティセッティング
  //bonding,MITM,sc
  //セキュリティ無し
  NimBLEDevice::setSecurityAuth(false, false, false);
  //ボンディング有り
  //NimBLEDevice::setSecurityAuth(true, false, false);
  //ボンディング有り、mitm有り
  //NimBLEDevice::setSecurityAuth(true, true, false);
  //ボンディング有り、mitm有り,sc有り
  //NimBLEDevice::setSecurityAuth(true, true, true);
  //PassKeyのセット
  //NimBLEDevice::setSecurityPasskey(123456);
  //パラメータでディスプレイ有りに設定
  //NimBLEDevice::setSecurityIOCap(BLE_HS_IO_DISPLAY_ONLY);
  //パラメータでInOut無しに設定
  //NimBLEDevice::setSecurityIOCap(BLE_HS_IO_NO_INPUT_OUTPUT);
  pServer = NimBLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  NimBLEService *pService = pServer->createService(SERVICE_UUID);

  //RxCharacteristic
  NimBLECharacteristic *pRxCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_RX, NIMBLE_PROPERTY::WRITE);
  //NotifyCharacteristic
  //NoSec
  //pNotifyCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_NOTIFY, NIMBLE_PROPERTY::NOTIFY);
  //Need Enc
  //pNotifyCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_NOTIFY, NIMBLE_PROPERTY::NOTIFY | NIMBLE_PROPERTY::READ_ENC);
  //Need Authen
  //pNotifyCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_NOTIFY, NIMBLE_PROPERTY::NOTIFY | NIMBLE_PROPERTY::READ_AUTHEN);
  //Need Enc Authen
  pNotifyCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID_NOTIFY, NIMBLE_PROPERTY::NOTIFY | NIMBLE_PROPERTY::READ_ENC | NIMBLE_PROPERTY::READ_AUTHEN);

  //RxCharacteristicにコールバックをセット
  pRxCharacteristic->setCallbacks(new MyCallbacks());
  //Serivice開始
  pService->start();
  //アドバタイズの設定
  NimBLEAdvertising *pNimBleAdvertising = NimBLEDevice::getAdvertising();
  //アドバタイズするUUIDのセット
  pNimBleAdvertising->addServiceUUID(SERVICE_UUID);
  //アドバタイズにTxPowerセット
  pNimBleAdvertising->addTxPower();

  //アドバタイズデータ作成
  NimBLEAdvertisementData advertisementData;
  //アドバタイズにCompleteLoacaNameセット
  advertisementData.setName(COMPLETE_LOCAL_NAME);  
  //アドバタイズのManufactureSpecificにデータセット
  advertisementData.setManufacturerData("NORA");  
  //ScanResponseを行う
  pNimBleAdvertising->setScanResponse(true);
  //ScanResponseにアドバタイズデータセット
  pNimBleAdvertising->setScanResponseData(advertisementData);  
  //アドバタイズ開始
  pNimBleAdvertising->start();
  
}

void loop() {
  M5.update();
  loopBLE();
}
