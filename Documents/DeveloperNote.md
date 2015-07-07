
# PLAY OPC - 開発ノート

PLAY OPCの開発中に気がついたことなどを記録しています。

## アプリケーションの開始と終了

* アプリの中で現在地情報や写真ライブラリへ初めてアクセスするとOSのセキュリティにより権限確認のダイアログが表示され、意図せずにアプリケーションデリゲートのapplicationWillResignActive:メソッドが呼び出される場合があります。オリンパスカメラキットではapplicationWillResignActive:メソッドが呼び出されるとカメラを切断しなければならないルールとなっているようですので、結果として意図せずカメラとの接続が解除されてしまいます。これを防ぐにはカメラに接続する前、すなわちアプリ起動時に予め現在地情報や写真ライブラリへアクセスして権限を入手しておく必要があります。
* applicationWillResignActiveメソッドでのアプリ接続の切断処理はメインスレッド上で実行しなければなりません。この処理を別スレッドの非同期で実行してしまうと、接続解除が完了する前にアプリがバックグラウンドに移行してしまって使用しているリソースを解放していない状態になり、結果として他のアプリがカメラを使用できない問題を引き起こしてしまいます。

## カメラ通信カテゴリ

### Wi-Fi接続

* Info.plistに、Application uses Wi-Fi キー追加してその値を YES にしておかないと、アプリを30分放置すると勝手にWi-Fiが切れてしまうそうです。ちなみに、このキーを設定するとアプリの初回起動時にどのWi-Fiアクセスポイントに接続するかの自動接続しないようにしている時と同じようなダイアログが表示されます。
* iOSデバイスのWi-Fiの接続と切断の検知が遅いので、カメラ本体のLEDの点灯消灯に頼って操作すると、アプリが辻褄の合わない動作をしているように思ってしまいます。Wi-FiのSSIDを監視して他の操作ができないように待ち合わせするようにした方が安全です。
* iOSではアプリからWi-Fiの接続先を指定することはできないので、カメラの電源を入れてもカメラのWi-Fiに接続するとは限りません。自動で他のアクセスポイントに接続してしまうかもしれません。カメラへのWi-Fi接続をエラーとしてユーザーに伝えることはできますが、アプリとしてはそれ以上のことは何もできませんのでリカバリにはユーザー介入が必要になります。つまりユーザーの設定環境によっては、wakeup:とconnect:OLYCameraConnectionTypeWiFi:の組み合わせによるカメラのスタートアップは常に失敗する可能性があるということです。

### Bluetooth接続

* Bluetooth経由で電源オン(wakeup:)やカメラへ接続(connect:error:)を呼び出す時は、その前にアプリでCore Bluetoothを使ってカメラ(Bluetoothペリフェラル)を検索して接続まで済ませておく必要があるようです。Bluetoothペリフェラルとして接続せずにAPIを呼び出すと、"The value of 'peripheral' property is invalid."というエラーが返ってきます。
* Bluetooth経由で接続している場合だと、カメラの状態取得と撮影モードでの基本的な撮影操作にしか対応していないようです。Bluetooth接続に対応していないAPIを呼び出すと、"The operation requires that the instance is connected to the camera over Wi-Fi."というエラーが返ってきます。
* Wi-Fi経由で接続している場合はカメラ側から切断すると切断検知のデリゲート(OLYCameraConnectionDelegateプロトコルのcamera:disconnectedByError:メソッド)が呼ばれますが、Bluetooth経由で接続している場合はその切断検知のデリゲートが呼ばれないようです。対策としてはアプリでBluetoothの切断検知を拾って自発的にカメラ接続解除メソッド(disconnectWithPowerOff:)を呼んで切断しなければなりません。

### 電源管理

* AC電源供給されているUSBケーブルをカメラに挿したまま電源オンメソッド(wakeup:)を呼び出すと時々ですがエラーになる場合があるようです。 #reported-sdk-1.0.1
* レンズ起動なし(bluetoothPrepareForRecordingWhenPowerOn=NO)で電源オンすると、初めて撮影モードに遷移するタイミングかもしくは保守モードへ行って戻って来た2回目のスタンドアロンモードに遷移するタイミングで初めてレンズが起動するようです。また、アプリ接続中のままカメラをしばらく放置してスリープに入るとレンズが沈胴しますが、この場合はスリープ以前の状態を覚えているのか再びアプリ接続するとレンズが起動します。

## カメラシステムカテゴリ

* 実行モードがスタンドアロンモードにある時にしばらく放置してその間にカメラがスリープに入ってしまうと(レンズが沈胴してカメラ本体のLEDが緑色でゆっくり点滅している状態)、そこから撮影モードに入ろうとした場合にカメラのスリープが解除されずにハングアップしてしまいます。(正確には実行モード変更(changeRunMode:error:)を呼んでから3分ぐらい待つと通信がタイムアウトしてエラーになります) #reported-sdk-1.0.1 #avoided-app-1.0.1589
* AC電源供給されているUSBケーブルをカメラに抜き差ししても、カメラプロパティのバッテリー残量(BATTERY\_LEVEL)が変化したことがデリゲート(camera:didChangeCameraProperty:)で通知されないようです。
* カメラに16GBのマイクロSDカードを挿していてもメディア空き容量プロパティ(remainingMediaCapacity)の戻り値が2GB止まりになっているようです。4GB止まりかも。
* ~~カメラプロパティ一括取得メソッド(cameraPropertyValues:error:)で得た全てのカメラプロパティ値を、カメラプロパティ一括設定メソッド(setCameraPropertyValues:error:)で復元しようとするとタイムアウトエラーが発生してその後にカメラ接続が解除されてしまいます。カメラの挙動を見る限りファームウェアのリセットがかかっているようです。~~ #reported-sdk-1.0.1 #avoided-app-1.0.1589 #fixed-sdk-1.1.0
* ~~現在位置(CLLocationオブジェクト)を位置情報設定メソッド(setGeolocation:)に指定するNMEA0183形式の文字列に変換する方法が分かりません。~~ (OPCサポートの方からスタック・オーバーフローで情報をもらって無事に解決しました! 感謝! 2015-05-08) #fixed-app-1.0.1589

## 撮影操作カテゴリ

* カメラ本体のシャッターボタンで撮影すると、カメラに記録できる撮影画像の最大数(remainingImageCapacity)とカメラがメディアに書き込み中か(mediaBusy)が変化しません。アプリ(プログラム)から撮影すると意図している通りに変化します。
* カメラプロパティの撮影後確認用画像(RECVIEW)を生成する(ON)に設定した状態でカメラ本体のシャッターボタンを連打して立て続けに単写撮影すると、そのほとんどが撮影後確認用画像を受信完了(camera:didReceiveCapturedImagePreview:metadata:)の代わりに撮影後確認用画像の受信失敗(camera:didFailToReceiveCapturedImagePreviewWithError:)で通知されます。その引数には"The camera that command was requested gave back status 520."というエラーが渡されています。
* 撮影直後でメディアに書き込み中の時にカメラプロパティ値を変更しようとするとエラーになる場合があるようです。
* 連写撮影でメディアへの書き込みが始まると、写真撮影停止メソッド(stopTakingPicture:completionHandler:errorHandler:)を呼び出してもカメラが連写をすぐに停止しないか、とても時間がかかることがあるようです。 ライブビューのサイズ(changeLiveViewSize:error:)や静止画サイズ(IMAGESIZE)の値も関係しているようです。#reported-sdk-1.0.1
* Bluetooth経由で接続していて撮影結果確認用画像(RECVIEW)がONになっている場合だと、撮影した直後に"The operation requires that the instance is connected to the camera over Wi-Fi."というエラーが発生します。Bluetooth経由で接続している場合は撮影結果確認用画像が取得できないようです。

### ライブビュー

* Bluetooth経由で接続している場合だと、撮影モードに入ってもライブビュー画像はカメラから送信されてこないようです。
* アスペクト比(ASPECT\_RATIO)を変更するとタッチ有効範囲(autoFocusEffectiveArea:, autoExposureEffectiveArea:)の横幅が予想より小さい値になっている場合があります。

### ステータスと設定保存

* ~~水準器プロパティ(levelGauge)から得られる辞書の本体の向きもしくは傾き(OLYCameraLevelGaugeOrientationKey)で、本体仰向けの時に"facedown"が、本体うつ伏せの時に"faceup"が設定されるようです。~~ #reported-sdk-1.0.1 #fixed-sdk-1.1.0
* 水準器プロパティ(levelGauge)のロール量とピッチ量の精度は0.1度単位のようで値は頻繁に変更され、カメラを傾けていくとロール量かピッチ量が±48度から±50度前後のところで本体の向きもしくは傾きが変化するようです。 
* Bluetooth経由で接続している場合だと、水準器プロパティ(levelGauge)がnilのままで変化しないようです。 #reported-sdk-1.0.1
* 顔認識情報プロパティ(detectedHumanFaces)の要素は、顔の数が少ない時は期待通りにそのオブジェクトを追跡しますが、顔の数が多い場合の挙動を観察して見る限り、一度認識した顔を追跡する(インデックスが変化しない)わけではなく、ライブビュー画像ごとに認識しなおしている(同じオブジェクトでも違うインデックスが割当られている)ように思えます。
* 撮影モードで設定したカメラプロパティの値はスタンドアロンモードに遷移するとほとんど忘れてしまうようです。いくつかは保持されるているようですが、実際にどのカメラプロパティが保持されているのか未精査です。これは、カメラプロパティ一括取得メソッド(cameraPropertyValues:error:)とカメラプロパティ一括設定メソッド(setCameraPropertyValues:error:)を使った操作をデザインする際に影響がありそうです。
* カメラプロパティ一括取得メソッド(cameraPropertyValues:error:)で得た設定値をそのままカメラプロパティ一括設定メソッド(setCameraPropertyValues:error:)で設定し直しても、カメラかもしくはライブラリの内部で、撮影モード(TAKEMODE)、動画撮影モード(EXPOSE\_MOVIE\_SELECT)、アートフィルター種別(RECENTLY\_ART\_FILTER)の値と設定の順番が干渉してしまうらしく、以前の状態には戻らないようです。 #reported-sdk-1.1.0 #avoided-app-1.2.1730

### 露出と撮影操作

* カメラプロパティのタイトルを取得(cameraPropertyTitle:)で違うカメラプロパティ名を渡しても同じタイトルが返ってくるものがあります。例えば、フォーカスモード静止画用(FOCUS\_STILL)とフォーカスモード動画用(FOCUS\_MOVIE)は同じ"Focus Mode"という値が返ってきます。
* ~~カメラプロパティの動画撮影モード(EXPOSE\_MOVIE\_SELECT)のタイトルを取得(cameraPropertyTitle:)するとドライブモード(TAKE\_DRIVE)と同じ"Drive Mode"というタイトルが返ってきます。~~ #reported-sdk-1.0.1 #fixed-sdk-1.1.0
* ~~カメラプロパティの撮影モード(TAKEMODE)が"iAuto"に設定されていると、カメラプロパティの露出補正値(EXPREV)の値がnilとなり、しかもプロパティ値変更通知のデリゲート(camera:didChangeCameraProperty:)がライブビュー画像の更新と同じ間隔で呼び出され続けます。~~ #reported-sdk-1.0.1 #fixed-sdk-1.1.0
* ~~カメラプロパティの撮影モード(TAKEMODE)が"movie"に設定されていると、カメラプロパティの絞り値(APERTURE)、シャッター速度(SHUTTER)、ISO感度(ISO)の値がnilになり、しかもプロパティ値変更通知のデリゲート(camera:didChangeCameraProperty:)がライブビュー画像の更新と同じ間隔で呼び出され続けます。~~ #reported-sdk-1.0.1 #fixed-sdk-1.1.0
* カメラプロパティの撮影モード(TAKEMODE、EXPOSE\_MOVIE\_SELECT)の値を変更すると、その他の複数のカメラプロパティの設定可不可(canSetCameraProperty:)が影響を受けるようです。
* カメラプロパティの撮影モード(TAKEMODE、EXPOSE\_MOVIE\_SELECT)の値を変更すると、その他の複数のカメラプロパティの値が勝手に変更される場合があるようです。
  * TAKEMODEをPからMに変更するとISO感度(ISO)の値リストからAutoが消えます。
  * TAKEMODEをP,A,S,Mからmovieに変更すると露出補正値(EXPREV)の値リストが+5.0〜-5.0から+3.0〜-3.0に狭まります。
* ~~カメラプロパティの撮影モード(TAKEMODE)をmovieにして動画撮影モード(EXPOSE\_MOVIE\_SELECT)を変更すると、その時の露光パラメータ(APERTURE, SHUTTER, EXPREV, ISO)の設定可不可メソッド(canSetCameraProperty:)が返す値がおかしい時があります。~~ #reported-sdk-1.0.1 #fixed-sdk-1.1.0
* カメラプロパティの撮影モード(TAKEMODE、EXPOSE\_MOVIE\_SELECT)をmovieに変更すると、そのモードでは設定できない露出パラメータ(actualApertureValue, actualShutterSpeed, actualExposureCompensation, actualIsoSensitivity)の現在値がNANになるようです。

### 色と効果

* ~~撮影モード(TAKEMODE)をmovie、動画撮影モード(EXPOSE\_MOVIE\_SELECT)をPに変更してから、アートフィルター種別(RECENTLY\_ART\_FILTER)を変更すると、撮影モードが勝手にARTになってしまうようです。~~ #fixed-sdk-1.1.0

### オートフォーカスと自動測光と手ぶれ補正

* オートフォーカスをロック(setAutoFocusPoint:とlockAutoFocus:)するとフォーカス枠は正方形ですが、ロック解除の状態で撮影(takePicture:progressHandler:completionHandler:errorHandler:)した時のフォーカス終了イベント(OLYCameraTakingProgressEndFocusing)のコールバックに渡されるフォーカス枠(OLYCameraTakingPictureProgressInfoFocusRectKey)は長方形になっているようです。
* 予めオートフォーカスをロック(setAutoFocusPoint:とlockAutoFocus:)してから撮影する(takePicture:progressHandler:completionHandler:errorHandler)と、その進捗ハンドラのオートフォーカス終了ステージ(OLYCameraTakingProgressEndFocusing)で渡される合焦結果(OLYCameraTakingPictureProgressInfoFocusResultKey)には、AFが機能しなかったことを示す"none"が設定されています。従って、装着しているレンズがAF非対応か否かをこの合焦結果だけを頼りに判定するのは安全とは言えません。
* オートフォーカス動作をロック(lockAutoFocus:errorHandler:)する時にはカメラプロパティのフォーカス固定(AF\_LOCK\_STATE)が変化したことがデリゲート(camera:didChangeCameraProperty:)で通知されませんが、ロック解除する時には通知されるようです。自動露光制御の動作をロック(lockAutoExposure:)した時の露出固定(AE\_LOCK\_STATE)も同様のようです。オートフォーカス動作をすでにロックしている状態でさらにロックすると、カメラ内部で一旦ロック解除が行われているのか、この場合はフォーカス固定が変化したことがデリゲートで通知されるようです。
* カメラプロパティの動画手ぶれ補正(ANTI\_SHAKE\_MOVIE)のプロパティ値タイトルを取得(cameraPropertyValueTitle:)すると、OFFとONの表示文言がそれぞれ"M-I.S. On"と"M-I.S. Off"となっていて、実際の動作とは逆の内容で返ってきます。 #reported-sdk-1.1.0

### ズーム

* カメラに装着されたレンズの現在の焦点距離プロパティ(actualFocalLength)は1mm単位のようです。 
* ~~Bluetooth経由で接続している場合だと、カメラに装着されたレンズの現在の焦点距離プロパティ(actualFocalLength)が1のままで変化しないようです。~~ #reported-sdk-1.0.1 #fixed-sdk-1.1.0
* 光学ズームの焦点距離指定(startDrivingZoomLensToFocalLength:error:)のズーム速度は、方向速度指定(startDrivingZoomLensForDirection:speed:error:)の時に指定できるOLYCameraDrivingZoomLensSpeedBurstと同じ速度のようです。

## 再生操作カテゴリ

* デバイス用画像のダウンロード(downloadContentScreennail:progressHandler:completionHandler:errorHandler:)で得た画像にはメタデータに回転情報が入っていないらしく、UIImageViewを使って表示した時に撮影時のカメラ本体の向きが再現されないようです。 #reported-sdk-1.0.1
* ~~動画リサイズ(resizeVideoFrame:size:quality:progressHandler:completionHandler:errorHandler:)のresizeパラメータは1920もしくは1280しか受け付けないようです。その他の値を指定するとエラーになったり1920や1280が指定されたものとして扱われるようです。~~ #reported-sdk-1.0.1 #fixed-sdk-1.1.0
* 動画リサイズ(resizeVideoFrame:size:quality:progressHandler:completionHandler:errorHandler:)で作成された動画ファイルをさらに動画リサイズすることはできないようです。
* ~~デバイスのメインメモリに収まりきらないようなサイズの大きい画像や動画をダウンロードすることはできないようです。~~ #reported-sdk-1.0.1 #fixed-sdk-1.1.0
* コンテンツ削除禁止設定(protectContent:error:)、コンテンツ削除禁止許可(unprotectContent:error:)は、JPEGファイルを指定してもRAWファイルを指定してもJPEGファイルとRAWファイルのセットで両方に反映されるようです。
* コンテンツ削除(eraseContent:error:)は、JPEGファイルを指定してもRAWファイルを指定してもJPEGファイルとRAWファイルのセットで両方削除されるようです。
* コンテンツ情報取得(inquireContentInformation:error:)に静止画を指定した場合に得られる情報の詳細は、オープンプラットフォームカメラ通信仕様書の静止画ファイル情報取得(get_imageinfo.cgi)の静止画情報パラメータリストフォーマットに記載されているようです。
* コンテンツ情報取得(inquireContentInformation:error:)に動画を指定した場合に得られる情報の詳細は、オープンプラットフォームカメラ通信仕様書の動画ファイル情報取得(get_movfileinfo.cgi)のHTTPレスポンスに記載されているようです。

以上
