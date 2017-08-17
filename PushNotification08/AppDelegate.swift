import UIKit
import UserNotifications
//注意：使用推播時，專案的Capibility要開啟推播（此時會產生.entitlements檔案）
//若伺服器無法推播至2195port，可利用Pusher軟體測試推播，網址：https://github.com/noodlewerk/NWPusher
//其他參考教材：https://www.raywenderlich.com/156966/push-notifications-tutorial-getting-started
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    //推播伺服器所在的網域
    let webDomain = "http://max9.000space.com/"
    //記錄當次的推播訊息（主要給App從背景進入前景時使用）
    var currentMessage: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        //設定要收到的通知類型
        let userNotificationCenter = UNUserNotificationCenter.current()
        userNotificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted
            {
                print("使用者同意接收推播訊息")
                userNotificationCenter.getNotificationSettings { (settings) in
                    print("Notification settings: \(settings)")
                    guard settings.authorizationStatus == .authorized else { return }
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            else
            {
                print("使用者不接受推播訊息!")
            }
        }
        //註冊通知
        application.registerForRemoteNotifications()
        //如果App在沒啟動的狀態下，點了『推播通知』之後，推播資料將會以launchOptions傳入
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
        {
            //將推播訊息傳送到進入前景後的推播通知事件
            //注意：缺少此步驟，點『推播通知』後，隨之開啟的App介面上將會無法顯示推播訊息！
            self.application(application, didReceiveRemoteNotification: remoteNotification)
        }
        return true
    }
    
    //成功註冊了遠端推播時
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        print("Token ID：\(deviceToken)")
        //取得設備的TokenID
        let tokenID = deviceToken.map({ String(format: "%02.2hhx", $0)}).joined()
        //呼叫伺服器端的PHP服務，將移動設備的TokenID記錄下來
        let strURL = String(format: webDomain+"register_mobile.php?token_id=%@", tokenID)
        print("記錄TokenID的網址：\(strURL)")
        //傳送網址
        let url = URL(string: strURL)
        //非同步連接
        //網路傳輸物件
        let session = URLSession.shared
        //宣告網路任務
        let dataTask = session.dataTask(with: url!, completionHandler: { (echoData, response, error) -> Void in
            let strEchoMessage = String(NSString(data: echoData!, encoding: String.Encoding.utf8.rawValue)!)
            if strEchoMessage == "1" || strEchoMessage == "2"
            {   //1.tokenID新增成功 2.tokenID已經存在
                print("已經記錄下移動設備的TokenID")
            }
            else
            {
                print("無法成功記錄設備的TokenID")
            }
        })
        //執行網路任務
        dataTask.resume()
    }
    
    //遠端推播註冊失敗時
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("無法取得Token:\(error.localizedDescription)")
    }
    
    //接收APNs傳來的推播訊息
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
        print("接收到的推播訊息：\(userInfo.description)")
        //擷取推播訊息中的文字欄位
        if let dicAps = userInfo["aps"] as? [AnyHashable: Any]
        {
            if let strAlert = dicAps["alert"] as? String
            {
                print("推播中alert的內容：\(strAlert)")
                //記錄此次的推播訊息（主要給App從背景進入前景時使用）
                currentMessage = strAlert
                
                //如果App在前景時，直接將推播訊息顯示在畫面上（App在前景時，不會發出推播的聲音）
                if let vc = window?.rootViewController as? ViewController
                {
                    //當App在前景時
                    if application.applicationState == UIApplicationState.active
                    {
                        //將訊息傳遞給下一頁的方法
                        vc.showPushMessage(currentMessage)
                    }
                        //當App不在前景時
                    else
                    {
                        //將訊息傳遞給下一頁的變數（讓viewDidAppear顯示推播訊息）
                        vc.pushMessage = currentMessage
                    }
                }
            }
        }
    }
    
    //當應用程式從背景被重新啟動時
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        //如果App在前景時，直接將推播訊息顯示在畫面上（App在前景時，不會發出推播的聲音）
        if let vc = window?.rootViewController as? ViewController
        {
            //將訊息傳遞給下一頁的方法
            vc.showPushMessage(currentMessage)
            //清除已記錄的推播訊息
            currentMessage = ""
        }
    }
    
}

