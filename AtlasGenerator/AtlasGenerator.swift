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
                print("Empty path for glyph \(glyph)")
                continue
            }
            
            let descriptionWriter = ShapeDescriptionWriter(path: path)
            guard let shapeDescription = descriptionWriter.generate() else {
                print("Could not generate ShapeDescriptionWriter description for glyph \(glyph)")
                continue
            }
            guard let shape = Shape(description: shapeDescription) else {
                print("could not generate Shape from description for glyph \(glyph)")
                continue
            }
            
            shape.normalise()
            var bitmap = [Float](repeating: 0.0, count: 32 * 32 * 3)
            MSDFGenBridge.generateMSDF(&bitmap, width: 32, height: 32, shape: shape, range: 1.0, scaleX: 1.0, scaleY: 1.0, translateX: 0.0, translateY: 0.0, edgeThreshold: 1.0)
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
