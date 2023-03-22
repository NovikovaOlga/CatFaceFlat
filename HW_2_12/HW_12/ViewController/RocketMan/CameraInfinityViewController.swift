
import UIKit
import Vision
import AVFoundation

// Прямоугольник границ лица и яблоки дублируются (не пойму как стирать со слоя по мере движения).

class CameraInfinityViewController: UIViewController {
    var sequenceHandler = VNSequenceRequestHandler()// анализ изображений каждого кадра в последовательности
    
    let alertHelper = AlertHelper.shared
    
    @IBOutlet weak var faceView: FaceView!
    
    let session = AVCaptureSession() //  захват в реальном времени
    var previewLayer: AVCaptureVideoPreviewLayer! //обработчик запросов, на который подается изображения из ленты камеры (запросы на обнаружение лиц для серии изображений, а не на одно статическое)
    
    let dataOutputQueue = DispatchQueue( // для вывода видеоданных
        label: "video data queue",
        qos: .userInitiated, // немедленные результаты действий пользователя
        attributes: [],
        autoreleaseFrequency: .workItem) // настраивает пул авторелиза перед выполнением блока и освобождает объекты в этом пуле после завершения выполнения блока.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCaptureSession()
        session.startRunning()
    }
    
    //  func detectedFace(request: VNRequest, error: Error?) {
    //    // 1 первый результат из массива результатов =
    //    guard
    //      let results = request.results as? [VNFaceObservation],
    //      let result = results.first
    //    else {
    //      // 2 Очистим FaceView, если лицо не обнаружено.
    //      faceView.clear()
    //      return
    //    }
    //    updateFaceView(for: result)
    //  }
    //
    
    
    
    fileprivate func handleDetectedFaces(request: VNRequest?, error: Error?) {
        if let nsError = error as NSError? {
            self.alertHelper.presentAlert("Face Detection Error", error: nsError, controller: self)
            return
        }
        DispatchQueue.main.async { // переходим на главный поток, тк вся работа с интерфейсом на главном потоке
            guard let drawLayer = self.previewLayer,
                  let results = request?.results as? [VNFaceObservation] else { // из request достаем результаты
                      return
                  }
            self.draw(faces: results, onImageWithBounds: drawLayer.bounds) // и просим отрисовать их
            drawLayer.setNeedsDisplay()
            
        }
    }
    
    // MARK: face detection (3) - отрисовка
    fileprivate func draw(faces: [VNFaceObservation], onImageWithBounds bounds: CGRect) {
        CATransaction.begin() // группировки операций с несколькими слоями (новая транзакция для текущего потока)
        for observation in faces { // из массива лиц достаем boundingBox - CGRect прямоугольник границ лица
            let faceBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds) // boundingBox - прямоугольник границ лица
            let faceLayer = shapeLayer(color: .yellow, frame: faceBox) // создаем для faceBox - faceLayer
            
            // Добавить слой пути поверх изображения.
            previewLayer?.addSublayer(faceLayer) // добавляем его в наш интерфейс
            
            animateRocketTo(frame: faceBox) // запуск ракеты
        }
        CATransaction.commit() // группировки операций с несколькими слоями (Зафиксируйте все изменения, внесенные во время текущей транзакции)
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
    
    // MARK: face detection (3+) - наложение нового слоя
    fileprivate func shapeLayer(color: UIColor, frame: CGRect) -> CAShapeLayer {
        // Создайте новый слой.
        let layer = CAShapeLayer()
        
        // Настройка внешнего вида слоя.
        layer.fillColor = nil // Нет заливки для отображения объекта в штучной упаковке
        layer.shadowOpacity = 0
        layer.shadowRadius = 0
        layer.borderWidth = 2
        
        // Измените цвет линии в соответствии с вводимыми данными.
        layer.borderColor = color.cgColor
        
        // Найдите слой.
        layer.anchorPoint = .zero
        layer.frame = frame
        layer.masksToBounds = true
        
        // Преобразуйте слой так, чтобы он имел ту же систему координат, что и изображение под ним.
        layer.transform = CATransform3DMakeScale(1, -1, 1)
        
        return layer
    }
    
    // MARK: ракета (яблоко)
    fileprivate func animateRocketTo(frame: CGRect) {
        let rocket = UIImageView(image: UIImage(named: "appleM"))
        rocket.frame = CGRect(origin: CGPoint.zero, size: rocket.image!.size) // 5
        rocket.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - rocket.image!.size.height/8)
        view.addSubview(rocket)
        
        // let distance = view.frame.size.width / min(frame.size.width, frame.size.height)
        //  let duration = Double(distance) * 0.45
        let duration: Double = 0.5
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            rocket.center = CGPoint(x: frame.origin.x + frame.size.width/2, y: frame.origin.y + frame.size.height/8)
        }) { (_) in
            
            rocket.removeFromSuperview() // удаляем ракету - если выстрелить много раз, то они копятся на слое и это ужасно
        }
    }
    
    
    func convert(rect: CGRect) -> CGRect { // Координаты ограничительной рамки результата
        // 1 преобразование нормализованного начала координат в систему координат слоя предварительного просмотра.
        let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        // 2 преобразование нормализованного размера в систему координат слоя предварительного просмотра.
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
        // 3 Создайте CGRect, используя новую начало координат и размер.
        return CGRect(origin: origin, size: size.cgSize)
    }
    
    func updateFaceView(for result: VNFaceObservation) {
        defer {
            //    DispatchQueue.main.async {
            self.faceView.setNeedsDisplay()
            //  }
        }
        let box = result.boundingBox
        faceView.boundingBox = convert(rect: box)
    }
}

// MARK: - Video Processing methods
extension CameraInfinityViewController {
    func configureCaptureSession() {
        // Определите устройство захвата, которое мы хотим использовать
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
            fatalError("No front video camera available")
        }
        
        // Подключите камеру к входу сеанса съемки
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        // Создайте вывод видеоданных
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        // Добавьте видеовыход в сеанс захвата
        session.addOutput(videoOutput)
        
        let videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        
        // Настройте слой предварительного просмотра
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity =  .resizeAspectFill // videoGravity - как слой отображает видеоконтент в пределах своих границ.
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods
//  для получения буферов отснятого видеоизображения
extension CameraInfinityViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 1 буфер изображения из переданного буфера образца.
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // 2 запрос на обнаружение лиц (ограничительных рамок граней) и передачи результатов обработчику завершения.
        //   let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
        let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: handleDetectedFaces)
        
        
        // 3 ранее определенный обработчик запроса последовательности для выполнения запроса на распознавание лиц на изображении. Параметр ориентации сообщает обработчику запроса, какова ориентация входного изображения.
        do {
            try sequenceHandler.perform( // perform - запрос-выполнение-результат запросов
                [detectFaceRequest],
                on: imageBuffer,
                orientation: .leftMirrored)
        } catch {
            print(error.localizedDescription)
        }
        
    }
}



/*
 ВАРИАНТ 1
 
 class CameraRocketViewControllert: UIViewController {
 
 var sequenceHandler = VNSequenceRequestHandler()// анализ изображений каждого кадра в последовательности
 
 let alertHelper = AlertHelper.shared
 
 @IBOutlet weak var faceView: FaceView!
 
 let session = AVCaptureSession() //  захват в реальном времени
 var previewLayer: AVCaptureVideoPreviewLayer! //обработчик запросов, на который подается изображения из ленты камеры (запросы на обнаружение лиц для серии изображений, а не на одно статическое)
 
 let dataOutputQueue = DispatchQueue( // для вывода видеоданных
 label: "video data queue",
 qos: .userInitiated, // немедленные результаты действий пользователя
 attributes: [],
 autoreleaseFrequency: .workItem) // настраивает пул авторелиза перед выполнением блока и освобождает объекты в этом пуле после завершения выполнения блока.
 
 override func viewDidLoad() {
 super.viewDidLoad()
 configureCaptureSession()
 session.startRunning()
 }
 
 //  func detectedFace(request: VNRequest, error: Error?) {
 //    // 1 первый результат из массива результатов =
 //    guard
 //      let results = request.results as? [VNFaceObservation],
 //      let result = results.first
 //    else {
 //      // 2 Очистим FaceView, если лицо не обнаружено.
 //      faceView.clear()
 //      return
 //    }
 //    updateFaceView(for: result)
 //  }
 //
 
 
 
 fileprivate func handleDetectedFaces(request: VNRequest?, error: Error?) {
 if let nsError = error as NSError? {
 self.alertHelper.presentAlert("Face Detection Error", error: nsError, controller: self)
 return
 }
 DispatchQueue.main.async { // переходим на главный поток, тк вся работа с интерфейсом на главном потоке
 guard let drawLayer = self.previewLayer,
 let results = request?.results as? [VNFaceObservation] else { // из request достаем результаты
 return
 }
 self.draw(faces: results, onImageWithBounds: drawLayer.bounds) // и просим отрисовать их
 drawLayer.setNeedsDisplay()
 
 }
 }
 
 // MARK: face detection (3) - отрисовка
 fileprivate func draw(faces: [VNFaceObservation], onImageWithBounds bounds: CGRect) {
 CATransaction.begin() // группировки операций с несколькими слоями (новая транзакция для текущего потока)
 for observation in faces { // из массива лиц достаем boundingBox - CGRect прямоугольник границ лица
 let faceBox = boundingBox(forRegionOfInterest: observation.boundingBox, withinImageBounds: bounds) // boundingBox - прямоугольник границ лица
 let faceLayer = shapeLayer(color: .yellow, frame: faceBox) // создаем для faceBox - faceLayer
 
 // Добавить слой пути поверх изображения.
 previewLayer?.addSublayer(faceLayer) // добавляем его в наш интерфейс
 
 animateRocketTo(frame: faceBox) // запуск ракеты
 }
 CATransaction.commit() // группировки операций с несколькими слоями (Зафиксируйте все изменения, внесенные во время текущей транзакции)
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
 
 // MARK: face detection (3+) - наложение нового слоя
 fileprivate func shapeLayer(color: UIColor, frame: CGRect) -> CAShapeLayer {
 // Создайте новый слой.
 let layer = CAShapeLayer()
 
 // Настройка внешнего вида слоя.
 layer.fillColor = nil // Нет заливки для отображения объекта в штучной упаковке
 layer.shadowOpacity = 0
 layer.shadowRadius = 0
 layer.borderWidth = 2
 
 // Измените цвет линии в соответствии с вводимыми данными.
 layer.borderColor = color.cgColor
 
 // Найдите слой.
 layer.anchorPoint = .zero
 layer.frame = frame
 layer.masksToBounds = true
 
 // Преобразуйте слой так, чтобы он имел ту же систему координат, что и изображение под ним.
 layer.transform = CATransform3DMakeScale(1, -1, 1)
 
 return layer
 }
 
 // MARK: ракета (яблоко)
 fileprivate func animateRocketTo(frame: CGRect) {
 let rocket = UIImageView(image: UIImage(named: "appleM"))
 rocket.frame = CGRect(origin: CGPoint.zero, size: rocket.image!.size) // 5
 rocket.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - rocket.image!.size.height/8)
 view.addSubview(rocket)
 
 // let distance = view.frame.size.width / min(frame.size.width, frame.size.height)
 //  let duration = Double(distance) * 0.45
 let duration: Double = 0.5
 UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
 rocket.center = CGPoint(x: frame.origin.x + frame.size.width/2, y: frame.origin.y + frame.size.height/8)
 }) { (_) in
 
 rocket.removeFromSuperview() // удаляем ракету - если выстрелить много раз, то они копятся на слое и это ужасно
 }
 }
 
 
 func convert(rect: CGRect) -> CGRect { // Координаты ограничительной рамки результата
 // 1 преобразование нормализованного начала координат в систему координат слоя предварительного просмотра.
 let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
 // 2 преобразование нормализованного размера в систему координат слоя предварительного просмотра.
 let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
 // 3 Создайте CGRect, используя новую начало координат и размер.
 return CGRect(origin: origin, size: size.cgSize)
 }
 
 func updateFaceView(for result: VNFaceObservation) {
 defer {
 //    DispatchQueue.main.async {
 self.faceView.setNeedsDisplay()
 //  }
 }
 let box = result.boundingBox
 faceView.boundingBox = convert(rect: box)
 }
 }
 
 // MARK: - Video Processing methods
 extension CameraRocketViewControllert {
 func configureCaptureSession() {
 // Определите устройство захвата, которое мы хотим использовать
 guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
 for: .video,
 position: .front) else {
 fatalError("No front video camera available")
 }
 
 // Подключите камеру к входу сеанса съемки
 do {
 let cameraInput = try AVCaptureDeviceInput(device: camera)
 session.addInput(cameraInput)
 } catch {
 fatalError(error.localizedDescription)
 }
 
 // Создайте вывод видеоданных
 let videoOutput = AVCaptureVideoDataOutput()
 videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
 videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
 
 // Добавьте видеовыход в сеанс захвата
 session.addOutput(videoOutput)
 
 let videoConnection = videoOutput.connection(with: .video)
 videoConnection?.videoOrientation = .portrait
 
 // Настройте слой предварительного просмотра
 previewLayer = AVCaptureVideoPreviewLayer(session: session)
 previewLayer.videoGravity =  .resizeAspectFill // videoGravity - как слой отображает видеоконтент в пределах своих границ.
 previewLayer.frame = view.bounds
 view.layer.insertSublayer(previewLayer, at: 0)
 }
 }
 
 // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods
 //  для получения буферов отснятого видеоизображения
 extension CameraRocketViewControllert: AVCaptureVideoDataOutputSampleBufferDelegate {
 func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
 // 1 буфер изображения из переданного буфера образца.
 guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
 return
 }
 
 // 2 запрос на обнаружение лиц (ограничительных рамок граней) и передачи результатов обработчику завершения.
 //   let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
 let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: handleDetectedFaces)
 
 
 // 3 ранее определенный обработчик запроса последовательности для выполнения запроса на распознавание лиц на изображении. Параметр ориентации сообщает обработчику запроса, какова ориентация входного изображения.
 do {
 try sequenceHandler.perform( // perform - запрос-выполнение-результат запросов
 [detectFaceRequest],
 on: imageBuffer,
 orientation: .leftMirrored)
 } catch {
 print(error.localizedDescription)
 }
 
 }
 }
 
 */

/*
 
 import AVFoundation
 import UIKit
 import Vision
 
 class CameraRocketViewControllert: UIViewController {
 
 var sequenceHandler = VNSequenceRequestHandler()// анализ изображений каждого кадра в последовательности
 
 @IBOutlet weak var faceView: FaceView!
 
 let session = AVCaptureSession() //  захват в реальном времени
 var previewLayer: AVCaptureVideoPreviewLayer! //обработчик запросов, на который подается изображения из ленты камеры (запросы на обнаружение лиц для серии изображений, а не на одно статическое)
 
 let dataOutputQueue = DispatchQueue(
 label: "video data queue",
 qos: .userInitiated, // немедленные результаты действий пользователя
 attributes: [],
 autoreleaseFrequency: .workItem) // настраивает пул авторелиза перед выполнением блока и освобождает объекты в этом пуле после завершения выполнения блока.
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 configureCaptureSession()
 session.startRunning()
 }
 
 func detectedFace(request: VNRequest, error: Error?) {
 // 1 первый результат из массива результатов =
 guard
 let results = request.results as? [VNFaceObservation],
 let result = results.first
 else {
 // 2 Очистим FaceView, если лицо не обнаружено.
 faceView.clear()
 return
 }
 updateFaceView(for: result)
 }
 
 func convert(rect: CGRect) -> CGRect { // Координаты ограничительной рамки результата
 
 // 1 преобразование нормализованного начала координат в систему координат слоя предварительного просмотра.
 let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
 
 // 2 преобразование нормализованного размера в систему координат слоя предварительного просмотра.
 let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
 
 // 3 Создайте CGRect, используя новую начало координат и размер.
 return CGRect(origin: origin, size: size.cgSize)
 }
 
 // 1 Определите метод, который преобразует точку ориентира в то, что можно нарисовать на экране.
 func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
 // 2 Вычислите абсолютное положение нормализованной точки с помощью расширения Core Graphics, определенного в CoreGraphicsExtensions.swift.
 let absolute = point.absolutePoint(in: rect)
 
 // 3 Преобразуйте точку в систему координат слоя предварительного просмотра.
 let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
 
 // 4 Верните преобразованную точку.
 return converted
 }
 
 // Этот метод берет массив этих знаковых точек и преобразует их все.
 func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
 return points?.compactMap { landmark(point: $0, to: rect) }
 }
 
 func updateFaceView(for result: VNFaceObservation) {
 defer {
 DispatchQueue.main.async {
 self.faceView.setNeedsDisplay()
 }
 }
 
 let box = result.boundingBox
 faceView.boundingBox = convert(rect: box)
 
 guard let landmarks = result.landmarks else {
 return
 }
 
 // регион контура лица от щеки через подбородок к щеке.
 if let faceContour = landmark(points: landmarks.faceContour?.normalizedPoints, to: result.boundingBox) {
 faceView.faceContour = faceContour
 }
 
 //  регион контура левого глаза.
 if let leftEye = landmark(points: landmarks.leftEye?.normalizedPoints, to: result.boundingBox) {
 faceView.leftEye = leftEye
 }
 
 // регион контура правого глаза
 if let rightEye = landmark(points: landmarks.rightEye?.normalizedPoints, to: result.boundingBox) {
 faceView.rightEye = rightEye
 }
 
 // регион следа левой брови
 if let leftEyebrow = landmark(points: landmarks.leftEyebrow?.normalizedPoints, to: result.boundingBox) {
 faceView.leftEyebrow = leftEyebrow
 }
 
 // регион следа правой брови
 if let rightEyebrow = landmark(points: landmarks.rightEyebrow?.normalizedPoints, to: result.boundingBox) {
 faceView.rightEyebrow = rightEyebrow
 }
 
 // регион контура носа
 if let nose = landmark(points: landmarks.nose?.normalizedPoints, to: result.boundingBox) { // noseCrest
 faceView.nose = nose
 }
 
 // регион центрального гребня носа.
 if let noseCrest = landmark(points: landmarks.noseCrest?.normalizedPoints, to: result.boundingBox) {
 faceView.noseCrest = noseCrest
 }
 
 // контур центральной линии лица.
 if let medianLine = landmark(points: landmarks.medianLine?.normalizedPoints, to: result.boundingBox) {
 faceView.noseCrest = medianLine
 }
 
 if let outerLips = landmark(points: landmarks.outerLips?.normalizedPoints, to: result.boundingBox) {
 faceView.outerLips = outerLips
 }
 
 if let innerLips = landmark(points: landmarks.innerLips?.normalizedPoints, to: result.boundingBox) {
 faceView.innerLips = innerLips
 }
 
 if let leftPupil = landmark(points: landmarks.leftPupil?.normalizedPoints, to: result.boundingBox) {
 faceView.innerLips = leftPupil
 }
 
 if let rightPupil = landmark(points: landmarks.rightPupil?.normalizedPoints, to: result.boundingBox) {
 faceView.innerLips = rightPupil
 }
 }
 }
 
 // MARK: - Video Processing methods
 
 extension CameraRocketViewControllert {
 func configureCaptureSession() {
 // Определите устройство захвата, которое мы хотим использовать
 guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
 for: .video,
 position: .front) else {
 fatalError("No front video camera available")
 }
 
 // Подключите камеру к входу сеанса съемки
 do {
 let cameraInput = try AVCaptureDeviceInput(device: camera)
 session.addInput(cameraInput)
 } catch {
 fatalError(error.localizedDescription)
 }
 
 // Создайте вывод видеоданных
 let videoOutput = AVCaptureVideoDataOutput()
 videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
 videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
 
 // Добавьте видеовыход в сеанс захвата
 session.addOutput(videoOutput)
 
 let videoConnection = videoOutput.connection(with: .video)
 videoConnection?.videoOrientation = .portrait
 
 // Настройте слой предварительного просмотра
 previewLayer = AVCaptureVideoPreviewLayer(session: session)
 previewLayer.videoGravity =  .resizeAspectFill
 previewLayer.frame = view.bounds
 view.layer.insertSublayer(previewLayer, at: 0)
 }
 }
 
 // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods
 //  для получения буферов отснятого видеоизображения
 extension CameraRocketViewControllert: AVCaptureVideoDataOutputSampleBufferDelegate {
 func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
 // 1 буфер изображения из переданного буфера образца.
 guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
 return
 }
 
 // 2 запрос на обнаружение лиц (ограничительных рамок граней) и передачи результатов обработчику завершения.
 let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
 
 
 
 // 3 ранее определенный обработчик запроса последовательности для выполнения запроса на распознавание лиц на изображении. Параметр ориентации сообщает обработчику запроса, какова ориентация входного изображения.
 do {
 try sequenceHandler.perform(
 [detectFaceRequest],
 on: imageBuffer,
 orientation: .leftMirrored)
 } catch {
 print(error.localizedDescription)
 }
 
 }
 }
 
 */
