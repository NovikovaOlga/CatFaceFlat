
import UIKit

class ScanerCollectionViewController: UICollectionViewController {
    
    private let classifierService = ImageClassifierService() // сервис распознавания
    
    var demoImage = UIImageView()
    
    weak var delegate: ScanerViewControllerDelegate?
    
    let photosScaner = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17"]
    
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
        return photosScaner.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! ScanerCollectionViewCell
    
        // Configure the cell
        let imageName = photosScaner[indexPath.item]
        let image = UIImage(named: imageName)
        
        cell.photoScaner.image = image // чтобы картинка была квадратная по размерам вью, в мейн сториборд ставим аспект филл и галочку на клип ту баундс
        
        cell.pressDemoImage = { [unowned self] in // отслеживаем нажатие
           
        //    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in // выполнение задачи в основном потоке с выполнением указанных атрибутов (deadline - время, на которое планируется выполнение блока и возвращает текущее время + величина
            
            delegate?.updateDemoImage(imageName: imageName)
            dismiss(animated: true)
            
       //     }
        }
        return cell
    }
}
    
extension ScanerCollectionViewController: UICollectionViewDelegateFlowLayout {
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
