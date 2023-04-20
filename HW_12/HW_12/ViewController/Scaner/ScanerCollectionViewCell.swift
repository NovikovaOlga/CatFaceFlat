

import UIKit

class ScanerCollectionViewCell: UICollectionViewCell {
    
    var pressDemoImage: (() -> Void)? // отслеживание нажатия на картинку
    
    @IBOutlet weak var photoScaner: UIImageView!
    
    @IBAction func photoScanerButton(_ sender: Any) {
        pressDemoImage?() // на картинку нажали (или нет)

    }
}
