import UIKit
import Vision
import CoreML

enum ImageClassifierServiceState { // классификация объектов (состояние)
  case startRequest, requestFailed, receiveResult(resultModel: ClassifierResultModel)
}

class ImageClassifierService {
  var onDidUpdateState: ((ImageClassifierServiceState) -> Void)?
  
  func classifyImage(_ image: UIImage) {
    onDidUpdateState?(.startRequest)
    
    guard let model = makeImageClassifierModel(), let ciImage = CIImage(image: image) else {
      onDidUpdateState?(.requestFailed)
      return
    }
    makeClassifierRequest(for: model, ciImage: ciImage)
  }
  
  private func makeImageClassifierModel() -> VNCoreMLModel? {  
      return try? VNCoreMLModel(for: HW_12_cat_dog_mouse_tree().model)
  }
  
  private func makeClassifierRequest(for model: VNCoreMLModel, ciImage: CIImage) {
    let request = VNCoreMLRequest(model: model) { [weak self] request, error in
        self?.handleClassifierResults(request.results)
    }
    
    let handler = VNImageRequestHandler(ciImage: ciImage)
      DispatchQueue.global(qos: .userInteractive).async {
      do {
        try handler.perform([request])
      } catch {
        self.onDidUpdateState?(.requestFailed)
      }
    }
  }
  
  private func handleClassifierResults(_ results: [Any]?) {
    guard let results = results as? [VNClassificationObservation],
      let firstResult = results.first else {
      onDidUpdateState?(.requestFailed)
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      let confidence = (firstResult.confidence * 100).rounded()
      let resultModel = ClassifierResultModel(identifier: firstResult.identifier, confidence: Int(confidence))
      self?.onDidUpdateState?(.receiveResult(resultModel: resultModel))
    }
  }
}
