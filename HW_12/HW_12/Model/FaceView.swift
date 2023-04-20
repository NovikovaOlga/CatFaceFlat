// контур лица и полигоны ландмарков


import UIKit
import Vision

class FaceView: UIView {
  var faceContour: [CGPoint] = [] // контур лица (нижняя половина)
  var leftEye: [CGPoint] = []
  var rightEye: [CGPoint] = []
  var leftEyebrow: [CGPoint] = []
  var rightEyebrow: [CGPoint] = []
  var nose: [CGPoint] = []
  var noseCrest: [CGPoint] = [] // гребень носа
  var medianLine: [CGPoint] = [] // контур центральной линии лица.
  var outerLips: [CGPoint] = []
  var innerLips: [CGPoint] = []
  var leftPupil: [CGPoint] = [] // точка, в которой расположен левый зрачок. Неточно при моргании
  var rightPupil: [CGPoint] = []
 

  var boundingBox = CGRect.zero
  
  func clear() {
    faceContour = []
    leftEye = []
    rightEye = []
    leftEyebrow = []
    rightEyebrow = []
    nose = []
    noseCrest = []
    medianLine = []
    outerLips = []
    innerLips = []
    leftPupil = []
    rightPupil = []
    
    boundingBox = .zero
    
    DispatchQueue.main.async {
      self.setNeedsDisplay() // Помечает весь прямоугольник границ получателя как требующий перерисовки. Вы можете использовать этот метод или setNeedsDisplay(_:), чтобы уведомить систему о том, что содержимое вашего представления необходимо перерисовать. Этот метод записывает запрос и немедленно возвращает его. Вид фактически не перерисовывается до следующего цикла рисования, после чего все недействительные виды обновляются. Вы должны использовать этот метод, чтобы запросить перерисовку представления только при изменении содержимого или внешнего вида представления. Если вы просто измените геометрию вида, вид обычно не перерисовывается. Вместо этого его существующее содержимое корректируется на основе значения в свойстве contentMode представления. Повторное отображение существующего содержимого повышает производительность, позволяя избежать необходимости перерисовывать содержимое, которое не изменилось.
    }
  }
  
  override func draw(_ rect: CGRect) {
    // 1 Получить текущий графический контекст.
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }

    // 2 Переложите текущее графическое состояние в стек.
    context.saveGState()

    // 3 Восстановите состояние графики при выходе из этого метода.
    defer { // defer можно использовать, например, для выполнения ручного управления ресурсами, такими как закрытие дескрипторов файлов, а также для выполнения действий, которые должны произойти, даже если возникнет ошибка
      context.restoreGState() // Устанавливает текущее состояние графики в состояние, сохраненное последним. Core Graphics удаляет графическое состояние в верхней части стека, так что последнее сохраненное состояние становится текущим графическим состоянием.
    }
        
    // 4 Добавьте контур, описывающий ограничительную рамку в контекст.
    context.addRect(boundingBox) // Добавляет прямоугольный путь к текущему пути.

    // 5 Установите цвет.
    UIColor.systemGreen.setStroke() // Устанавливает цвет последующих операций обводки на цвет, который представляет приемник.

    // 6 Нарисуйте фактический путь, описанный на шаге 4.
    context.strokePath()
    
    // 1 Установите цвет обводки другим, чтобы отличаться
    UIColor.white.setStroke()
    
    if !faceContour.isEmpty {
      context.addLines(between: faceContour)
      context.strokePath()
    }
    
    UIColor.blue.setStroke()
    // 2 Добавьте линии между точками, определяющими лэндмарк, если таковые имеются
    if !leftEye.isEmpty {
      context.addLines(between: leftEye)
      context.closePath()
      context.strokePath()
    }
    
    if !rightEye.isEmpty {
      context.addLines(between: rightEye)
      context.closePath()
      context.strokePath()
    }
       
    UIColor.black.setStroke()
    if !leftEyebrow.isEmpty {
      context.addLines(between: leftEyebrow)
      context.strokePath()
    }
        
    if !rightEyebrow.isEmpty {
      context.addLines(between: rightEyebrow)
      context.strokePath()
    }
      
    UIColor.white.setStroke()
    if !nose.isEmpty {
      context.addLines(between: nose)
      context.strokePath()
    }
    
    if !noseCrest.isEmpty {
      context.addLines(between: noseCrest)
      context.strokePath()
    }
    
    if !medianLine.isEmpty {
      context.addLines(between: medianLine)
      context.strokePath()
    }
       
    UIColor.red.setStroke()
    if !outerLips.isEmpty {
      context.addLines(between: outerLips)
      context.closePath()
      context.strokePath()
    }
    
    if !innerLips.isEmpty {
      context.addLines(between: innerLips)
      context.closePath()
      context.strokePath()
    }
     
    UIColor.yellow.setStroke()
    if !leftPupil.isEmpty {
      context.addLines(between: leftPupil)
      context.closePath()
      context.strokePath()
    }
    
    if !rightPupil.isEmpty {
      context.addLines(between: rightPupil)
      context.closePath()
      context.strokePath()
    }

  }
}
