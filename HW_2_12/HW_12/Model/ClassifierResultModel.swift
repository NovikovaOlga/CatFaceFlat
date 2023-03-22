
import Foundation

struct ClassifierResultModel {
  let identifier: String
  let confidence: Int
  
  var description: String {
    return "Это \(identifier) с вероятностью \(confidence)% "
  }
}
