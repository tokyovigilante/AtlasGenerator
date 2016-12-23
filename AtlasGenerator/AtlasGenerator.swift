//
//  AtlasGenerator.swift
//  AtlasGenerator
//
//  Created by Ryan Walklin on 8/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

import Foundation
import Cocoa

private let textureSize = 1024

class AtlasGenerator {
    
    private (set) var glyphWidth: CGFloat = 0
    private (set) var glyphHeight: CGFloat = 0
    
    func staticMode() {
        let argument = CommandLine.arguments[1]
        let widthString = CommandLine.arguments[2]
        glyphWidth = CGFloat(Int(widthString)!)
        let heightString = CommandLine.arguments[3]
        glyphHeight = CGFloat(Int(heightString)!)
        print("Glyph dimensions \(glyphWidth) x \(glyphHeight)")
        print("Opening: \(argument)")
        
        guard let font = openFont(name: argument) else {
            print("could not open font named \(argument)")
            exit(-1)
        }
        printFontInfo(font: font)
        renderGlyphs(font: font)
    }
    
    private func openFont(name: String) -> CTFont? {
        let font = CTFontCreateWithName((name as NSString), 30, nil)
        let returnedFontName = CTFontCopyPostScriptName(font)
        if returnedFontName as String == name {
            return font
        }
        return nil
    }
    
    private func printFontInfo (font: CTFont) {
        let family = CTFontCopyFamilyName(font) as String
        var style: String
        if let styleRaw = CTFontCopyName(font, kCTFontStyleNameKey) {
            style = styleRaw as String
        } else {
            style = ""
        }
        print("")
        print("\(family) \(style)")
        let glyphCount = CTFontGetGlyphCount(font)
        let fontAscent = CTFontGetAscent(font)
        let fontDescent = CTFontGetDescent(font)
        print("Glyphs: \(glyphCount)")
        print("Ascent: \(fontAscent)")
        print("Descent: \(fontDescent)")
    }
    
    fileprivate func estimatedLineWidthForFont (_ font: CTFont) -> Double {
        
        let attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), "!" as CFString!)
        
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, font)
        
        let framesetter = CTFramesetterCreateWithAttributedString(attrString!)
        var fitRange = CFRangeMake(0, 0)
        let textSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), &fitRange)
        
        return ceil(Double(textSize.width))
    }
    
    private func renderGlyphs (font: CTFont) {
        
        let insetWidth = glyphWidth - 2
        let insetHeight = glyphHeight - 2
        
        let glyphCount = CTFontGetGlyphCount(font)
        let glyphMargin = CGFloat(estimatedLineWidthForFont(font))

        let fontAscent = CTFontGetAscent(font)
        let fontDescent = CTFontGetDescent(font)
        
        var origin = CGPoint(x: 0, y: fontAscent)
        var maxYCoordForLine: CGFloat = -1
        
        var imageData = [UInt8](repeating: 0, count: textureSize * textureSize * 4)
        let glyphsPerRow = textureSize / Int(glyphWidth * 4)
        
        let cgFont = CTFontCopyGraphicsFont(font, nil)
        
        for glyph in 0..<UInt16(glyphCount) {
            
            let glyphName = cgFont.name(for: glyph) ?? "Unknown" as CFString
            
            var boundingRect = CGRect()
            CTFontGetBoundingRectsForGlyphs(font, .horizontal, [glyph], &boundingRect, 1)
            
            print("\(glyphName): glyph \(glyph+1) of \(glyphCount), boundingRect: \(boundingRect)")
            
            if (origin.x + boundingRect.maxX + glyphMargin > glyphWidth) {
             origin.x = 0
             origin.y = maxYCoordForLine + glyphMargin + fontDescent
             maxYCoordForLine = -1
             }
             
             if origin.y + boundingRect.maxY > maxYCoordForLine {
             maxYCoordForLine = origin.y + boundingRect.maxY
             }
             
             let glyphOriginX = origin.x - boundingRect.origin.x + (glyphMargin * 0.5)
             let glyphOriginY = glyphHeight - (origin.y + (glyphMargin * 0.5))
            
            
            guard let path = CTFontCreatePathForGlyph(font, glyph, nil) else {
                continue
            }
            if path.isEmpty {
                print("Empty path for glyph \(glyph)")
                continue
            } 
            
            let descriptionWriter = ShapeDescriptionWriter(path: path)
            guard let shapeDescription = descriptionWriter.generate() else {
                print("Could not generate ShapeDescriptionWriter description for glyph \(glyph)")
                continue
            }
                        
            var bitmap = [UInt8](repeating: 0, count: Int(insetWidth) * Int(insetHeight) * 4)
            let success = MSDFGenBridge.generateMSDF(&bitmap, width: Int32(insetWidth), height: Int32(insetHeight), shapeDesc: shapeDescription, translateX: 0, translateY: 0, edgeThreshold: 1.0, autoFrame: true, printMetrics: false)
            if !success {
                continue
            }
            /*
            let bitmapInfo: CGBitmapInfo = [ CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue) ]
            
            let context = CGContext.init(data: &bitmap, width: Int(glyphWidth), height: Int(glyphWidth), bitsPerComponent: 8, bytesPerRow: 4*Int(glyphWidth), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue, releaseCallback: nil, releaseInfo: nil)
            guard let image = context?.makeImage() else {
                return
            }
            let nsImage = NSImage(cgImage: image, size: CGSize(width: glyphWidth, height: glyphHeight))
            nsImage.isValid*/
            
            let imageRow = Int(glyph) / Int(glyphWidth)
            let imageColumn = Int(glyph) % Int(glyphWidth)
            
            let topLeft = (imageRow * Int(glyphHeight) * textureSize * 4) + textureSize * 4 + (imageColumn * Int(glyphWidth) * 4)
            for i in 0..<Int(insetHeight) {
                let offset = topLeft + i * textureSize * 4 + 4
                    //(i + 1) * Int(textureSize) + imageRow * Int(glyphWidth) + imageColumn * Int(glyphWidth) + 1
                memcpy(&imageData+offset, &bitmap+i*Int(insetWidth)*4, Int(insetWidth)*4)
            }
            /*
             context.addPath(path)
             context.fillPath()
             
             var glyphPathBoundingRect = path.boundingBoxOfPath
             
             // The null rect (i.e., the bounding rect of an empty path) is problematic
             // because it has its origin at (+inf, +inf); we fix that up here
             if ((glyphPathBoundingRect.equalTo(CGRect.null)) != nil) {
             glyphPathBoundingRect = CGRect.zero
             }
             
             let texCoordLeft = glyphPathBoundingRect.origin.x / fWidth
             let texCoordRight = (glyphPathBoundingRect.origin.x + glyphPathBoundingRect.size.width) / fWidth
             let texCoordTop = glyphPathBoundingRect.origin.y / fHeight
             let texCoordBottom = (glyphPathBoundingRect.origin.y + glyphPathBoundingRect.size.height) / fHeight
             
             let descriptor = GlyphDescriptor(
             glyphIndex: glyph,
             topLeftTexCoord: CGPoint(x: texCoordLeft, y: texCoordTop),
             bottomRightTexCoord: CGPoint(x: texCoordRight, y: texCoordBottom)
             )
             glyphDescriptors.append(descriptor)
             
             origin.x += boundingRect.width + glyphMargin*/
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo: CGBitmapInfo = [ CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue) ]
        
        guard let context = CGContext(data: &imageData,
                                      width: textureSize,
                                      height: textureSize,
                                      bitsPerComponent: 8,
                                      bytesPerRow: textureSize*4,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return }
        
        guard let image = context.makeImage() else {
            return
        }
        let nsImage = NSImage(cgImage: image, size: CGSize(width: glyphWidth, height: glyphHeight))
        nsImage.isValid
        
        // Turn off antialiasing so we only get fully-on or fully-off pixels.
        // This implicitly disables subpixel antialiasing and hinting.
        //context.setAllowsAntialiasing(false)

    }
}
