

import UIKit

class ScanerCollectionViewCell: UICollectionViewCell {
    
    var pressDemoImage: (() -> Void)?
    
    @IBOutlet weak var photoScaner: UIImageView!
    
    @IBAction func photoScanerButton(_ sender: Any) {
        pressDemoImage?() 
    }
}
