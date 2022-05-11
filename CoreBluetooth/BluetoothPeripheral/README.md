# Bluetooth Peripheral App
## 概要：本アプリに関して

本アプリはCoreBluetoothを用いて、iOS端末をPeripheralにするサンプルアプリです。

## 外観

<img src="https://user-images.githubusercontent.com/72245628/167847469-0684b419-ba51-439d-a0cc-df8492105b88.PNG" width="300">

## 機能

### アドバタイズ開始ボタン

<img width="207" alt="図1" src="https://user-images.githubusercontent.com/72245628/167850182-e8cb4393-11f0-4225-bd5c-e571f0ca4bce.png">

アドバタイズを開始します。

ローカルネーム

"TEST BLE"でアドバタイズします。

サービス

Service UUID:AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE

キャラクタリスティック

WriteCharacteristic UUID:AAAAAAAA-AAAA-BBBB-BBBB-BBBBBBBBBBBB

WriteWithoutResponseCharacteristic UUID:AAAAAAAA-BBBB-BBBB-BBBB-BBBBBBBBBBBB

ReadCharacteristic UUID:AAAAAAAA-CCCC-BBBB-BBBB-BBBBBBBBBBBB

NotifyCharacteristic UUID:AAAAAAAA-DDDD-BBBB-BBBB-BBBBBBBBBBBB

IndicateCharacteristic UUID:AAAAAAAA-EEEE-BBBB-BBBB-BBBBBBBBBBBB

## アドバタイズ停止ボタン
<img width="207" alt="6" src="https://user-images.githubusercontent.com/72245628/167854551-878077a0-e6ba-4091-af06-5fb129000627.png">
アドバタイズを停止します。

アドバタイズ開始後に有効になります。

## Notifyボタン
<img width="207" alt="7" src="https://user-images.githubusercontent.com/72245628/167854639-86a5a9ca-5a2e-43f3-8597-9263404ea017.png">
接続後にセントラルでNotifyを有効にするとボタンが有効になります。

Notifyでセントラルに「0xAA」を送信します。

## Indicate ボタン
<img width="207" alt="8" src="https://user-images.githubusercontent.com/72245628/167854707-1bbcb099-cdfe-4e37-9f56-101bccfb5841.png">
接続後にセントラルでIndicateを有効化するとボタンが有効になります。

Indicateでセントラルに「0xBB」を送信します。

## イベントログ
<img width="207" alt="5" src="https://user-images.githubusercontent.com/72245628/167855161-defcab8f-4e23-45dd-ab7f-c29c98596e4b.png">
CoreBluetoothのイベントをログとして出力します。
