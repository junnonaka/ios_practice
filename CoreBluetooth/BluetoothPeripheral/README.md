# Bluetooth Peripheral App
## 概要：本アプリに関して

本アプリはCoreBluetoothを用いて、iOS端末をPeripheralにするサンプルアプリです。

## 外観

<img src="https://user-images.githubusercontent.com/72245628/167847469-0684b419-ba51-439d-a0cc-df8492105b88.PNG" width="300">

## 機能

### アドバタイズ開始ボタン

<img width="207" alt="図1" src="https://user-images.githubusercontent.com/72245628/167850182-e8cb4393-11f0-4225-bd5c-e571f0ca4bce.png">

アドバタイズを開始します。

サービス

Service UUID:AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE

キャラクタリスティック

WriteCharacteristic UUID:AAAAAAAA-AAAA-BBBB-BBBB-BBBBBBBBBBBB

WriteWithoutResponseCharacteristic UUID:AAAAAAAA-BBBB-BBBB-BBBB-BBBBBBBBBBBB

ReadCharacteristic UUID:AAAAAAAA-CCCC-BBBB-BBBB-BBBBBBBBBBBB

NotifyCharacteristic UUID:AAAAAAAA-DDDD-BBBB-BBBB-BBBBBBBBBBBB

IndicateCharacteristic UUID:AAAAAAAA-EEEE-BBBB-BBBB-BBBBBBBBBBBB

## アドバタイズ停止ボタン
<img width="207" alt="2" src="https://user-images.githubusercontent.com/72245628/167850244-e173fdb3-131b-40d8-94f3-427dcf647f76.png">
アドバタイズを停止します。

## Notifyボタン
<img width="207" alt="3" src="https://user-images.githubusercontent.com/72245628/167850348-fa0eabcc-4d86-4f01-bbbd-3e0ae37e14c7.png">
接続後に有効になります。

Notifyでセントラルに「0xAA」を送信します。

## Indicate ボタン
<img width="207" alt="4" src="https://user-images.githubusercontent.com/72245628/167850995-84729e8d-21b7-491f-aa43-7ade5c03066a.png">
接続後に有効になります。

Indicateでセントラルに「0xBB」を送信します。
