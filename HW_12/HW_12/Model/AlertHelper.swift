
import Foundation
import UIKit

class AlertHelper {
    
    static let shared = AlertHelper()
    
    // MARK: камера не найдена (при попытке запустить камеру на симуляторе - чтоб приложение не крэшнулось)
    func cameraIsNotAvialable(controller: UIViewController) {
        // Всегда оповещение в основном потоке.
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Ошибка", message: "The camera is not available", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .destructive, handler: nil)
            alert.addAction(ok)
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: present alert (2+)
    func presentAlert(_ title: String, error: NSError, controller: UIViewController ) {
        // Всегда оповещение в основном потоке.
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title,
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default) { _ in
            }
            alertController.addAction(okAction)
            controller.present(alertController, animated: true, completion: nil)
        }
    }
}
