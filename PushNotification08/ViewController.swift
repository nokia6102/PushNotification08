import UIKit

class ViewController: UIViewController
{
    //顯示推播訊息的地方
    @IBOutlet weak var lblPushMessage: UILabel!
    //接收AppDelegate傳來的推播訊息
    var pushMessage:String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        //當接收到推播通知，且App是在未啟動的狀態下（不在背景），由此處顯示推播訊息到介面上
        lblPushMessage.text = pushMessage
        //清除通知標記
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    //此方法在App進入背景又回到前景時，由applicationDidBecomeActive呼叫，以顯示推播訊息到介面上
    func showPushMessage(_ newMessage:String?)
    {
        //顯示推播訊息
        lblPushMessage.text = newMessage
        //清除通知標記
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

