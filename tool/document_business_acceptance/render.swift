// Test-only CoreGraphics bridge; no application, network or Printing plugin loaded.
import Foundation
import CoreGraphics
let data = FileHandle.standardInput.readDataToEndOfFile()
guard let provider = CGDataProvider(data: data as CFData), let pdf = CGPDFDocument(provider), pdf.numberOfPages > 0, pdf.numberOfPages <= 40, pdf.isUnlocked else { exit(2) }
let dpi = Double(CommandLine.arguments[1]) ?? 72
var results = [[String:Any]]()
for index in 1...pdf.numberOfPages {
 guard let page = pdf.page(at: index) else { exit(3) }
 let box = page.getBoxRect(.mediaBox)
 let w = Int(ceil(box.width*dpi/72)), h = Int(ceil(box.height*dpi/72))
 guard w>0, h>0, w*h<20000000, let ctx = CGContext(data:nil,width:w,height:h,bitsPerComponent:8,bytesPerRow:w*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else { exit(4) }
 ctx.setFillColor(CGColor(gray:1,alpha:1));ctx.fill(CGRect(x:0,y:0,width:w,height:h))
 ctx.concatenate(page.getDrawingTransform(.mediaBox,rect:CGRect(x:0,y:0,width:w,height:h),rotate:0,preserveAspectRatio:true));ctx.drawPDFPage(page)
 guard let pixels=ctx.data else {exit(5)}
 let raw=Data(bytes:pixels,count:w*h*4)
 results.append(["width":w,"height":h,"rgba":raw.base64EncodedString()])
}
FileHandle.standardOutput.write(try JSONSerialization.data(withJSONObject:results))
