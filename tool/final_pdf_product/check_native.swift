// Offline test probe using the same CoreGraphics PDF decoder as printing on macOS.
import Foundation
import CoreGraphics
let data = FileHandle.standardInput.readDataToEndOfFile()
guard let provider = CGDataProvider(data: data as CFData),
      let pdf = CGPDFDocument(provider), pdf.numberOfPages > 0, pdf.isUnlocked else {
    exit(2)
}
for index in 1...pdf.numberOfPages {
    guard let page = pdf.page(at: index) else { exit(3) }
    let rect = page.getBoxRect(.mediaBox)
    guard rect.width > 0, rect.height > 0,
          let context = CGContext(data:nil,width:256,height:256,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) else { exit(4) }
    context.scaleBy(x:256/rect.width,y:256/rect.height)
    context.drawPDFPage(page)
}
print(pdf.numberOfPages)
