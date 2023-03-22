import Foundation
import UIKit

protocol ScanerViewControllerDelegate: AnyObject {
    func updateDemoImage(imageName: String)
}

extension ScanerViewController: ScanerViewControllerDelegate {
    func updateDemoImage(imageName: String) {
        imageView.image = UIImage(named: imageName)
        guard let im = UIImage(named: imageName) else { return  }
        classifierService.classifyImage(imageView.image ?? im)
    }
}

class ScanerViewController: UIViewController {
    
    let alertHelper = AlertHelper.shared
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func onAddButtonTap(_ sender: UIButton) {
        showAlert() // меню выбора (1) активная камера, 2)снимок с камеры, 3)выбор из галлереи телефона, 4) выбор из демо галлереи, 5)отмена)
    }
    
    
    private let classifierService = ImageClassifierService() // сервис распознавания
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //       let im = UIImage(named: "1")
        //        classifierService.classifyImage(im!)
        
        bindToImageClassifierService()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? ScanerCollectionViewController else { return }
        destination.delegate = self
    }
    
    private func bindToImageClassifierService() {
        classifierService.onDidUpdateState = { [weak self] state in
            self?.setupWithImageClassifierState(state)
        }
    }
    
    private func setup() { // красота для кнопки
        addButton.setTitle("Add Image", for: .normal)
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 16
        
    }
    
    private func setupWithImageClassifierState(_ state: ImageClassifierServiceState) {
        switch state {
        case .startRequest:
            descriptionLabel.text = "Сlassification in progress"
        case .requestFailed:
            descriptionLabel.text = "Classification is failed"
        case .receiveResult(let result):
            descriptionLabel.text = result.description // надпись с процентом результата
        }
    }
    
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        imagePickerViewController.sourceType = sourceType
        present(imagePickerViewController, animated: true)
    }
    
    private func showAlert() {
        
        let alertController = UIAlertController(title: "Выбор изображения", message: nil, preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Камера", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.showImagePicker(sourceType: .camera)
            } else {
                self.alertHelper.cameraIsNotAvialable(controller: self)
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "Альбом", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        
        let userPhotoLibraryAction = UIAlertAction(title: "Демо альбом", style: .default) { _ in
            self.performSegue(withIdentifier: "toDemoPhotoLibrary", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alertController.addAction(camera) // снимок с камеры
        alertController.addAction(photoLibraryAction) // галерея телефона
        alertController.addAction(userPhotoLibraryAction) // предустановленная галерея
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
    
    // MARK: - UIImagePickerControllerDelegate
    
    extension ScanerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) { 
            
            let imageKey = UIImagePickerController.InfoKey.originalImage
            guard let image = info[imageKey] as? UIImage else {
                dismiss(animated: true, completion: nil)
                return
            }
            dismiss(animated: true, completion: nil)
            classifierService.classifyImage(image)
            imageView.image = image
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
