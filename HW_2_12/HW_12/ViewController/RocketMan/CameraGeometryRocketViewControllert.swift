
import UIKit
import ARKit

class CameraGeometryRocketViewControllert: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        // Конфигурация отслеживания лиц AR доступна только для телефонов с фронтальной камерой истинной глубины. Вам нужно убедиться, что вы проверили это, прежде чем что-либо делать.
        guard ARFaceTrackingConfiguration.isSupported else {
          fatalError("Face tracking is not supported on this device")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
            
      // 1 Создайте конфигурацию для отслеживания лица.
      let configuration = ARFaceTrackingConfiguration()
            
      // 2 Запустите конфигурацию отслеживания лиц, используя встроенное свойство ARSession вашего ARSCNView
      sceneView.session.run(configuration)
    }
        
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
            
      // 1 Прежде чем вид исчезнет, вы убедитесь, что Приостановите сеанс AR
        sceneView.session.pause()
    }
}

// 1 CameraGeometryRocketViewControllert реализует протокол ARSCNViewDelegate.
extension CameraGeometryRocketViewControllert: ARSCNViewDelegate {
  // 2 визуализация маски (статика с поворотом)
  func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    
    // 3  устройство, используемое для визуализации, не равно нулю.
    guard let device = sceneView.device else {
      return nil
    }
    
    // 4  Создайте геометрию грани для визуализации устройством.
    let faceGeometry = ARSCNFaceGeometry(device: device)
    
    // 5 Создайте узел SceneKit на основе геометрии грани.
    let node = SCNNode(geometry: faceGeometry)
    
    // 6 Установите режим заливки, чтобы материал узла был просто линиями.
      node.geometry?.firstMaterial?.fillMode = .lines
    
    // 7 Верните узел.
    return node
  }
    
    // 1 определим версию обновления (движение маски  - движение мышц лица)
    func renderer(
      _ renderer: SCNSceneRenderer,
      didUpdate node: SCNNode,
      for anchor: ARAnchor) {
       
      // 2 Убедитесь, что обновляемый якорь является ARFaceAnchor и что геометрия узла является ARSCNFaceGeometry.
      guard let faceAnchor = anchor as? ARFaceAnchor,
        let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
          return
      }
        
      // 3 обновите ARSCNFaceGeometry, используя ARFaceAnchor в arfacegeometry
      faceGeometry.update(from: faceAnchor.geometry)
    }

}
