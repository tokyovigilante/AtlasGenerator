//
//  AtlasGenerator.swift
//  AtlasGenerator
//
//  Created by Ryan Walklin on 8/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

import Foundation
import CoreText
import CoreGraphics
import Cocoa

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
        let font = CTFontCreateWithName((name as NSString), 28, nil)
        let returnedFontName = /*CTFontCopyName(font, kCTFontStyleNameKey)*/CTFontCopyPostScriptName(font)
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
        
        let glyphCount = CTFontGetGlyphCount(font)
        let glyphMargin = CGFloat(estimatedLineWidthForFont(font))

        let fontAscent = CTFontGetAscent(font)
        let fontDescent = CTFontGetDescent(font)
        
        var origin = CGPoint(x: 0, y: fontAscent)
        var maxYCoordForLine: CGFloat = -1
        
        var imageData = [UInt8](repeating: 0, count: 1024 * 1024 * 4)
        
        for glyph in 0..<UInt16(glyphCount) {
            var boundingRect = CGRect()
            CTFontGetBoundingRectsForGlyphs(font, .horizontal, [glyph], &boundingRect, 1)
            
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
                        
            var bitmap = [UInt8](repeating: 0, count: Int(glyphWidth) * Int(glyphHeight) * 4)
            MSDFGenBridge.generateMSDF(&bitmap, width: Int32(glyphWidth), height: Int32(glyphHeight), shapeDesc: shapeDescription, range: 1.0, scaleX: 1.0, scaleY: 1.0, translateX: Float(glyphOriginX), translateY: Float(glyphOriginY), edgeThreshold: 1.0)
            
            let bitmapInfo: CGBitmapInfo = [ CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue) ]
            
            
            let context = CGContext.init(data: &bitmap, width: Int(glyphWidth), height: Int(glyphWidth), bitsPerComponent: 8, bytesPerRow: 4*Int(glyphWidth), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo.rawValue, releaseCallback: nil, releaseInfo: nil)
            guard let image = context?.makeImage() else {
                return
            }
            let nsImage = NSImage(cgImage: image, size: CGSize(width: glyphWidth, height: glyphHeight))
            print(nsImage)
            /*
            let imageRow = glyph / glyphWidth + glyph % glyphWidth
            let imageColumn = xyz
            for i in 1..<30 {
                memcpy(
                copy based on imagerow/col first offset
            }*/
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
                                      width: 1024,
                                      height: 1024,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 1024*4,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return }
        
        // Turn off antialiasing so we only get fully-on or fully-off pixels.
        // This implicitly disables subpixel antialiasing and hinting.
        context.setAllowsAntialiasing(false)

    }
}
