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

class AtlasGenerator {
    
    func staticMode() {
        let argument = CommandLine.arguments[1]
        print("Opening: \(argument)")
        
        guard let font = openFont(name: argument) else {
            print("could not open font named \(argument)")
            exit(-1)
        }
        printFontInfo(font: font)
        extractGlyphs(font: font)
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
    
    private func extractGlyphs (font: CTFont) {

        let glyphCount = CTFontGetGlyphCount(font)
        let fontAscent = CTFontGetAscent(font)
        let fontDescent = CTFontGetDescent(font)
        
        var origin = CGPoint(x: 0, y: fontAscent)
        var maxYCoordForLine: CGFloat = -1
        
        for glyph in 0..<UInt16(glyphCount) {
            var boundingRect = CGRect()
            CTFontGetBoundingRectsForGlyphs(font, .horizontal, [glyph], &boundingRect, 1)
            
            /*if (origin.x + boundingRect.maxX + glyphMargin > fWidth) {
                origin.x = 0
                origin.y = maxYCoordForLine + glyphMargin + fontDescent
                maxYCoordForLine = -1
            }
            
            if origin.y + boundingRect.maxY > maxYCoordForLine {
                maxYCoordForLine = origin.y + boundingRect.maxY
            }
            
            let glyphOriginX = origin.x - boundingRect.origin.x + (glyphMargin * 0.5)
            let glyphOriginY = origin.y + (glyphMargin * 0.5)
            */
 
            guard let path = CTFontCreatePathForGlyph(font, glyph, nil) else {
                continue
            }
            if path.isEmpty {
                continue
            }
            
            path.apply(info: nil, function: { _, elementPointer in
                let element = elementPointer.pointee
                let command: String
                let pointCount: Int
                switch element.type {
                case .moveToPoint: command = "moveTo"; pointCount = 1
                case .addLineToPoint: command = "lineTo"; pointCount = 1
                case .addQuadCurveToPoint: command = "quadCurveTo"; pointCount = 2
                case .addCurveToPoint: command = "curveTo"; pointCount = 3
                case .closeSubpath: command = "close"; pointCount = 0
                }
                let points = Array(UnsafeBufferPointer(start: element.points, count: pointCount))
                Swift.print("\(command) \(points)")
            })
            
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
        

        
    }
}
