
#include <M5Core2.h>
#include <NimBLEDevice.h>

#define LOCAL_NAME                  "M5Stack-Secure"
#define COMPLETE_LOCAL_NAME                  "M5Stack-Secure"

#define SERVICE_UUID                "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
#define CHARACTERISTIC_UUID_RX      "AAAAAAAA-BBBB-AAAA-AAAA-AAAAAAAAAAAA"//out
#define CHARACTERISTIC_UUID_NOTIFY  "AAAAAAAA-CCCC-AAAA-AAAA-AAAAAAAAAAAA"//in

//画像
#include "image.cpp"

//Notiry用のCharacteristic
NimBLECharacteristic * pNotifyCharacteristic;
//BLEServer
NimBLEServer *pServer = NULL;

bool deviceConnected = false;
bool oldDeviceConnected = false;

bool isButtonAPressed = false;
bool isButtonBPressed = false;
bool isButtonCPressed = false;

uint8_t data_buff[2];  // データ通知用バッファ

// Bluetooth LE Change Connect State
class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(NimBLEServer* pServer) {
      deviceConnected = true;
    };
    void onDisconnect(NimBLEServer* pServer) {
      deviceConnected = false;
    }
};

//BLEServerのCallback
class ServerCallbacks: public NimBLEServerCallbacks {
    void onConnect(NimBLEServer* pServer) {
        Serial.println("Client connected");
        deviceConnected = true;
    };
    //Deviceが接続された時
    void onConnect(NimBLEServer* pServer, ble_gap_conn_desc* desc) {
        Serial.print("Client address: ");
        Serial.println(NimBLEAddress(desc->peer_ota_addr).toString().c_str());

         //BLEデバイス側からSecurity Requestを送る
         //NimBLEDevice::startSecurity(desc->conn_handle);

        deviceConnected = true;
    };
    //Deviceが切断された時
    void onDisconnect(NimBLEServer* pServer) {
        Serial.println("Client disconnected - start advertising");
        deviceConnected = false;
    };
    //MTUChangeRequestが来た時の返信
    void onMTUChange(uint16_t MTU, ble_gap_conn_desc* desc) {
        Serial.printf("MTU updated: %u for connection ID: %u\n", MTU, desc->conn_handle);
    };

    //PassKeyリクエストが来た時の返信
    uint32_t onPassKeyRequest(){
        Serial.println("Server Passkey Request");
        return 123456; 
    };

    bool onConfirmPIN(uint32_t pass_key){
        Serial.print("The passkey YES/NO number: ");Serial.println(pass_key);
        /** Return false if passkeys don't match. */
        return true; 
    };

    void onAuthenticationComplete(ble_gap_conn_desc* desc){
        /** Check that encryption was successful, if not we disconnect the client */  
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
//Service:RxCharacteristicのコールバック
class MyServiceCallbacks: public BLECharacteristicCallbacks {
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
  NimBLEDevice::init(COMPLETE_LOCAL_NAME);
  NimBLEDevice::setPower(ESP_PWR_LVL_P9);
  //bonding,mitm,sc
  //ボンディング無し
  NimBLEDevice::setSecurityAuth(false, false, false);
  //ボンディング有り,
  //NimBLEDevice::setSecurityAuth(true, false, false);
  
  //SecuritySetting；個別
  //Mitmプロテクション
//  NimBLEDevice::setSecurityAuth(BLE_SM_PAIR_AUTHREQ_MITM);
//  //Bonding有り
//  NimBLEDevice::setSecurityAuth(BLE_SM_PAIR_AUTHREQ_BOND);
//  //PassKeySet
//  NimBLEDevice::setSecurityPasskey(123456);
//  //DISPLAY有り
//  //NimBLEDevice::setSecurityIOCap(BLE_HS_IO_DISPLAY_ONLY);
//  //DISPLAY無し
//  NimBLEDevice::setSecurityIOCap(BLE_HS_IO_NO_INPUT_OUTPUT);
  pServer = NimBLEDevice::createServer();
  pServer->setCallbacks(new ServerCallbacks());

  //Service
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



  pRxCharacteristic->setCallbacks(new MyServiceCallbacks());
  pService->start();

  //Advertise
  NimBLEAdvertising *pNimBleAdvertising = NimBLEDevice::getAdvertising();
  pNimBleAdvertising->addServiceUUID(SERVICE_UUID);
  pNimBleAdvertising->addTxPower();
  //AdvertisementData
  NimBLEAdvertisementData advertisementData;
  advertisementData.setName(COMPLETE_LOCAL_NAME);  
  advertisementData.setManufacturerData("NORA");  
  
  pNimBleAdvertising->setScanResponse(true);
  pNimBleAdvertising->setScanResponseData(advertisementData);

  //AdvirtisementStart
  pNimBleAdvertising->start();  
}

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
    //BtnAが押されたらNotify
    if (M5.BtnA.pressedFor(100)) {
      if(isButtonAPressed == false){
        Serial.println("BtnA pressed");
        isButtonAPressed = true;
        data_buff[0] = (int16_t)(11);
        data_buff[1] = (int16_t)(11);
        pNotifyCharacteristic->setValue(data_buff, 2);
        pNotifyCharacteristic->notify();
      }
    //BtnBが押されたらNotify
    }else if(M5.BtnB.pressedFor(100)){
      if(isButtonBPressed == false){
        Serial.println("BtnB pressed");
        isButtonBPressed = true;
        data_buff[0] = (int16_t)(22);
        data_buff[1] = (int16_t)(22);
        pNotifyCharacteristic->setValue(data_buff, 2);
        pNotifyCharacteristic->notify();
        
      }
    //BtnCが押されたらNotify
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


void loop() {
  M5.update();
  loopBLE();
}
