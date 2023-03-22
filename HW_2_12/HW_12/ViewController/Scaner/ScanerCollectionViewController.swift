
import UIKit

class ScanerCollectionViewController: UICollectionViewController {
    
    private let classifierService = ImageClassifierService()
    
    var demoImage = UIImageView()
    
    weak var delegate: ScanerViewControllerDelegate?
    
    let photosScaner = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"]
    
    let itemsPerRow: CGFloat = 3
    let sectionInserts = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)  // отступы от секций

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosScaner.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! ScanerCollectionViewCell
    
        // Configure the cell
        let imageName = photosScaner[indexPath.item]
        let image = UIImage(named: imageName)
        
        cell.photoScaner.image = image
        
        cell.pressDemoImage = { [unowned self] in
           
        //    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in // выполнение задачи в основном потоке с выполнением указанных атрибутов (deadline - время, на которое планируется выполнение блока и возвращает текущее время + величина
            
            delegate?.updateDemoImage(imageName: imageName)
            dismiss(animated: true)
            
       //     }
        }
        return cell
    }
}
    
extension ScanerCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingWidth = sectionInserts.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInserts
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInserts.left
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 
        return sectionInserts.left
    }
}
