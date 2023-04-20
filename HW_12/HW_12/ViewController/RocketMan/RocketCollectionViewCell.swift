
import UIKit

class RocketCollectionViewCell: UICollectionViewCell {
    
    var pressDemoImage: (() -> Void)? // отслеживание нажатия на картинку
    
    @IBOutlet weak var photoRocket: UIImageView!
    
    @IBAction func photoRocketButton(_ sender: Any) {
        pressDemoImage?() // на картинку нажали (или нет)
    }
}
