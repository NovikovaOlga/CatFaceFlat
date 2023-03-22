
import UIKit
import Vision

protocol RocketViewControllerDelegate: AnyObject {
    func updateDemoImage(imageName: String)
}

extension RocketViewController: RocketViewControllerDelegate {
    func updateDemoImage(imageName: String) {
        
        let originalImage = UIImage(named: imageName)!
        
        show(originalImage)
        
        let cgOrientation = CGImagePropertyOrientation (originalImage.imageOrientation)
        
        guard let cgImage = originalImage.cgImage else {
            return
        }
        performVisionRequest(image: cgImage, orientation: cgOrientation)
    }
}

class RocketViewController: UIViewController {
    
    let alertHelper = AlertHelper.shared
    let picker = UIImagePickerController()
    
    // MARK: face detection  - var, let
    var pathLayer: CALayer?
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    var croppedImage: UIImage!
    
    // MARK: face detection - Vision
    lazy var faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.handleDetectedFaces)
    lazy var faceLandmarkRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleDetectedFaceLandmarks)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerOutlet: UIButton!
    
    @IBAction func pickerButtonPress(_ sender: UIButton) {
        showAlert()
    }
    
    @IBAction func rocketButtonPress(_ sender: Any) {
        // Извлечь выбранное изображение.
        let originalImage: UIImage = imageView.image!

        // Конвертировать из UIImageOrientation в CGImagePropertyOrientation.
        let cgOrientation = CGImagePropertyOrientation(originalImage.imageOrientation)
        
        guard let cgImage = originalImage.cgImage else {
            return
        }
        
        performVisionRequest(image: cgImage, orientation: cgOrientation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: segue -> RocketCollectionViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? RocketCollectionViewController else { return }
       destination.delegate = self
    }
    
    private func setup() { // красота для кнопки
        pickerOutlet.setTitle("Add Image", for: .normal)
        pickerOutlet.layer.masksToBounds = true
        pickerOutlet.layer.cornerRadius = 16
    }
    
    //MARK: picker
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        imagePickerViewController.sourceType = sourceType
        present(imagePickerViewController, animated: true)
    }
    
    //MARK: picker showAlert
    private func showAlert() {
        
        let alertController = UIAlertController(title: "Выбор изображения", message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryAction = UIAlertAction(title: "Альбом", style: .default) { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        }
        
        let userPhotoLibraryAction = UIAlertAction(title: "Демо альбом", style: .default) { _ in
            self.performSegue(withIdentifier: "toDemoPhotoLibraryForRocket", sender: self)
        }
        
        let infiniteCamera = UIAlertAction(title: "Камера бесконечная ошибка", style: .default) { _ in
            self.performSegue(withIdentifier: "toInfiniteCamera", sender: self)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.showImagePicker(sourceType: .camera)
            } else {
                self.alertHelper.cameraIsNotAvialable(controller: self)
            }
        }
        
        let cameraWithoutApple = UIAlertAction(title: "Признаки лица (доп)", style: .default) { _ in
            self.performSegue(withIdentifier: "toCameraWithoutApple", sender: self)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.showImagePicker(sourceType: .camera)
            } else {
                self.alertHelper.cameraIsNotAvialable(controller: self)
            }
        }
      
        let geometryCamera = UIAlertAction(title: "VR камера (доп)", style: .default) { _ in  https://www.raywenderlich.com/5491-ar-face-tracking-tutorial-for-ios-getting-started
            self.performSegue(withIdentifier: "toGeometryFaceCamera", sender: self)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.showImagePicker(sourceType: .camera)
            } else {
                self.alertHelper.cameraIsNotAvialable(controller: self)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alertController.addAction(userPhotoLibraryAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(infiniteCamera)
        alertController.addAction(cameraWithoutApple)
        alertController.addAction(geometryCamera)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    
    // MARK: face detection(1+) - объединение результатов в массив
    fileprivate func createVisionRequests() -> [VNRequest] {
        
        var requests: [VNRequest] = []
        
        requests.append(self.faceDetectionRequest)
        requests.append(self.faceLandmarkRequest)
        
        return requests
    }
    
    // MARK: face detection (1) - Vision
    fileprivate func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {
     
        let requests = createVisionRequests()
        // обработчик запросов
        let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                        orientation: orientation,
                                                        options: [:])
        
        // запросы обработчику запросов
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error as NSError {
                print("Failed to perform image request: \(error)")
                self.alertHelper.presentAlert("Image Request Failed", error: error, controller: self)
                return
            }
        }
    }
    
    // MARK: face detection (2) - request
    fileprivate func handleDetectedFaces(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            self.alertHelper.presentAlert("Face Detection Error", error: nsError, controller: self)
            return
        }
        DispatchQueue.main.async {
            guard let drawLayer = self.pathLayer,
                  let results = request?.results as? [VNFaceObservation] else {
                      return
                  }
            self.draw(faces: results, onImageWithBounds: drawLayer.bounds)
            drawLayer.setNeedsDisplay()
        }
    }
    
    fileprivate func handleDetectedFaceLandmarks(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            self.alertHelper.presentAlert("Face Landmark Detection Error", error: nsError, controller: self)
            return
        }
        
        DispatchQueue.main.async {
            guard let drawLayer = self.pathLayer,
                  let results = request?.results as? [VNFaceObservation] else {
                      return
                  }
            self.drawFeatures(onFaces: results, onImageWithBounds: drawLayer.bounds)
            drawLayer.setNeedsDisplay()
        }
    }
    
    // MARK: face detection (3) - отрисовка
    fileprivate func draw(faces: [VNFaceObservation], onImageWithBounds bounds: CGRect) {
        CATransaction.begin()
        for observation in faces {
            let faceBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds)
            let faceLayer = shapeLayer(color: .yellow, frame: faceBox)
           
            pathLayer?.addSublayer(faceLayer)
            animateRocketTo(frame: faceBox)
        }
        CATransaction.commit()
    }

    // MARK: ракета (яблоко)
    fileprivate func animateRocketTo(frame: CGRect) {
        let rocket = UIImageView(image: UIImage(named: "appleM"))
        rocket.frame = CGRect(origin: CGPoint.zero, size: rocket.image!.size) // 5
        rocket.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - rocket.image!.size.height/8)
        view.addSubview(rocket)

        let distance = view.frame.size.width / min(frame.size.width, frame.size.height) // все объекты летят с разной скоростю - красиво если лиц много
        let duration = Double(distance) * 0.45
   //      let duration = 1.5
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            rocket.center = CGPoint(x: frame.origin.x + frame.size.width/2, y: frame.origin.y + frame.size.height/8)
        }) { (_) in

            rocket.removeFromSuperview()
        }
    }
    
    // MARK: face detection (3) - отрисовка признаков лица
    fileprivate func drawFeatures(onFaces faces: [VNFaceObservation], onImageWithBounds bounds: CGRect) { // получаем на вход массив VNFaceObservation
        CATransaction.begin()
        for faceObservation in faces {
            let faceBounds = boundingBox(forRegionOfInterest: faceObservation.boundingBox, withinImageBounds: bounds)
            guard let landmarks = faceObservation.landmarks else { // отличие от draw что пробегаясь по лицам берем уже landmarks
                continue
            }
            
            // Перебор ориентиров, обнаруженных на текущем лице.
            let landmarkLayer = CAShapeLayer()
            let landmarkPath = CGMutablePath()
            let affineTransform = CGAffineTransform(scaleX: faceBounds.size.width, y: faceBounds.size.height)
            
            //MARK: FACE - регионы нахождения признаков лица
            let openLandmarkRegions: [VNFaceLandmarkRegion2D?] = [ // При рисовании контуров рассматриваем брови и линии как открытые области
             //   landmarks.leftEyebrow,
                landmarks.rightEyebrow,
                landmarks.faceContour,
                landmarks.noseCrest,
                landmarks.medianLine
            ]
            
            // глаза, губы и нос как закрытые области
            let closedLandmarkRegions = [
                landmarks.leftEyebrow,
                landmarks.leftEye,
                landmarks.rightEye,
                landmarks.outerLips,
                landmarks.innerLips,
                landmarks.nose
            ].compactMap { $0 } // Отфильтруйте недостающие регионы.
            
            // Нарисуйте контуры для открытых областей.
            for openLandmarkRegion in openLandmarkRegions where openLandmarkRegion != nil {
                landmarkPath.addPoints(in: openLandmarkRegion!,
                                       applying: affineTransform,
                                       closingWhenComplete: false)
            }
            
            // Нарисуйте контуры для закрытых областей.
            for closedLandmarkRegion in closedLandmarkRegions {
                landmarkPath.addPoints(in: closedLandmarkRegion,
                                       applying: affineTransform,
                                       closingWhenComplete: true)
            }
            
            // Отформатируйте внешний вид контура: цвет, толщину, тень.
            landmarkLayer.path = landmarkPath
            landmarkLayer.lineWidth = 2
            landmarkLayer.strokeColor = UIColor.green.cgColor
            landmarkLayer.fillColor = nil
            landmarkLayer.shadowOpacity = 0.75
            landmarkLayer.shadowRadius = 4
            
            // Найдите путь в родительской системе координат.
            landmarkLayer.anchorPoint = .zero
            landmarkLayer.frame = faceBounds
            landmarkLayer.transform = CATransform3DMakeScale(1, -1, 1)
            
            // Добавить слой пути поверх изображения.
            pathLayer?.addSublayer(landmarkLayer)
        }
        CATransaction.commit()
    }
  
    // MARK: face detection (3+) - наложение нового слоя
    fileprivate func shapeLayer(color: UIColor, frame: CGRect) -> CAShapeLayer {
        // Создайте новый слой.
        let layer = CAShapeLayer()
        
        // Настройка внешнего вида слоя.
        layer.fillColor = nil
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.borderWidth = 2
        
        layer.borderColor = color.cgColor
        
        // Найдите слой.
        layer.anchorPoint = .zero
        layer.frame = frame
        layer.masksToBounds = true
        
        // Преобразуйте слой так, чтобы он имел ту же систему координат, что и изображение под ним.
        layer.transform = CATransform3DMakeScale(1, -1, 1)
        
        return layer
    }
    
    // MARK: face detection (3+) - Path-Drawing
    fileprivate func boundingBox(forRegionOfInterest: CGRect, withinImageBounds bounds: CGRect) -> CGRect {
        
        let imageWidth = bounds.width
        let imageHeight = bounds.height
        
        // Начнем с входного выпрямителя.
        var rect = forRegionOfInterest
        
        // Переместите начало координат.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.origin.x
        rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y
        
        // Масштабирование нормализованных координат.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        return rect
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension RocketViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: face detection (fin)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey: Any]) { // извлечение из меню алерта - необрезанное изображение
        
        // Извлечь выбранное изображение.
        let imageKey = UIImagePickerController.InfoKey.originalImage
        guard let originalImage = info[imageKey] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        //    let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        show(originalImage)
        
        // Конвертировать из UIImageOrientation в CGImagePropertyOrientation.
        let cgOrientation = CGImagePropertyOrientation(originalImage.imageOrientation)
        
        guard let cgImage = originalImage.cgImage else {
            return
        }
        performVisionRequest(image: cgImage, orientation: cgOrientation)
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

