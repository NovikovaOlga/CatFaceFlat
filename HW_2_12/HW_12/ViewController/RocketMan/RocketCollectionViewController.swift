
import UIKit

class RocketCollectionViewController: UICollectionViewController {
    
    var demoImage = UIImageView()
    
    weak var delegate: RocketViewControllerDelegate?

    let photosRocket = ["20", "21", "22", "23", "24", "25", "26"]
    
    let itemsPerRow: CGFloat = 3 // количество секций
    let sectionInserts = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)  // отступы от секций

    override func viewDidLoad() {
        super.viewDidLoad()
     //   self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
   

    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosRocket.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! RocketCollectionViewCell
    
        // Configure the cell
        let imageName = photosRocket[indexPath.item]
        let image = UIImage(named: imageName)
        
        cell.photoRocket.image = image // чтобы картинка была квадратная по размерам вью, в мейн сториборд ставим аспект филл и галочку на клип ту баундc
        
        cell.pressDemoImage = { [unowned self] in // отслеживаем нажатие

            delegate?.updateDemoImage(imageName: imageName)
            
            dismiss(animated: true)
        }
        return cell
    }
}

extension RocketCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {  // расчет для вывода по две фото в ряд с ровненькими отступами, независимо от размера экрана
        
        let paddingWidth = sectionInserts.left * (itemsPerRow + 1) // сколько отступов в ряду (2 фото = 3 отступа)
        let availableWidth = collectionView.frame.width - paddingWidth // доступная ширина (ширина  минус отступы)
        let widthPerItem = availableWidth / itemsPerRow // ширина фото (доступная ширина делим на количество в ряду
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInserts
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { // расстояние между объектами секций
        return sectionInserts.left
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { // расстояние между объектами секций
        return sectionInserts.left
    }
}
