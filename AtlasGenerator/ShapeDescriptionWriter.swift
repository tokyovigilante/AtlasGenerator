//
//  ShapeDescription.swift
//  AtlasGenerator
//
//  Created by Ryan Walklin on 9/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

import Foundation
import CoreGraphics

class ShapeDescriptionWriter {
    
    private var _path: CGPath
    
    init (path: CGPath) {
        _path = path
    }
    
    private var _shapeDescription = ""
    private var _startPoint = CGPoint()
    private var _currentPoint = CGPoint()
    private var _contourStarted = false
    private var _success = false
    
    func generate() -> String? {
        
        _startPoint = CGPoint()
        _currentPoint = _startPoint
        _shapeDescription = "@invert-y\n"
        _success = false
        
        let info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        _path.apply(info: info, function: { info, elementPointer in
            
            guard let infoPointer = info else {
                return
            }

            let mySelf = Unmanaged<ShapeDescriptionWriter>.fromOpaque(infoPointer).takeUnretainedValue()
            mySelf._success = false

            let element = elementPointer.pointee
            let command: String
            let pointCount: Int
            
            if !mySelf._contourStarted && element.type != .moveToPoint {
                // invalid command outside contour
                return
            }
            
            switch element.type {
            case .moveToPoint:
                command = "moveTo"; pointCount = 1
                mySelf._contourStarted = true
                mySelf._shapeDescription.append("{\n")
                mySelf._startPoint = element.points[0]
                mySelf._currentPoint = element.points[0]
            case .addLineToPoint:
                command = "lineTo"; pointCount = 1
                mySelf._shapeDescription.append("\t") // fprintf(output, "\t");
                mySelf._shapeDescription.append(String(format: "%.12g, %.12g", mySelf._currentPoint.x, mySelf._currentPoint.y)) // writeCoord(output, e->p[0]);
                mySelf._shapeDescription.append(";\n") // fprintf(output, ";\n");
                mySelf._currentPoint = element.points[0]
            case .addQuadCurveToPoint:
                command = "quadCurveTo"; pointCount = 2
                mySelf._shapeDescription.append("\t") // fprintf(output, "\t");
                mySelf._shapeDescription.append(String(format: "%.12g, %.12g", mySelf._currentPoint.x, mySelf._currentPoint.y)) //writeCoord(output, e->p[0]);                
                mySelf._shapeDescription.append(";\n\t\t")// fprintf(output, ";\n\t\t");
                mySelf._shapeDescription.append("(")// fprintf(output, "(");
                mySelf._shapeDescription.append(String(format: "%.12g, %.12g", element.points[0].x, element.points[0].y)) // writeCoord(output, e->p[1]);
                mySelf._shapeDescription.append(");\n") // fprintf(output, ");\n");
                mySelf._currentPoint = element.points[1]
            case .addCurveToPoint:
                command = "curveTo"; pointCount = 3
                mySelf._shapeDescription.append("\t") // fprintf(output, "\t");
                mySelf._shapeDescription.append(String(format: "%.12g, %.12g", mySelf._currentPoint.x, mySelf._currentPoint.y)) //writeCoord(output, e->p[0]);
                mySelf._shapeDescription.append(";\n\t\t")// fprintf(output, ";\n\t\t");
                mySelf._shapeDescription.append("(")// fprintf(output, "(");
                mySelf._shapeDescription.append(String(format: "%.12g, %.12g", element.points[0].x, element.points[0].y)) //writeCoord(output, e->p[1]);
                mySelf._shapeDescription.append("; ") // fprintf(output, "; ");
                mySelf._shapeDescription.append(String(format: "%.12g, %.12g", element.points[1].x, element.points[1].y)) // writeCoord(output, e->p[2]);
                mySelf._shapeDescription.append(");\n") // fprintf(output, ");\n");
                mySelf._currentPoint = element.points[2]
            case .closeSubpath:
                command = "close"; pointCount = 0
                if mySelf._startPoint != mySelf._currentPoint {
                    mySelf._shapeDescription.append("\t") // fprintf(output, "\t");
                    mySelf._shapeDescription.append(String(format: "%.12g, %.12g", mySelf._currentPoint.x, mySelf._currentPoint.y)) // writeCoord(output, e->p[0]);
                    mySelf._shapeDescription.append(";\n") // fprintf(output, ";\n");
                }
                mySelf._contourStarted = false
                mySelf._startPoint = CGPoint()
                mySelf._currentPoint = mySelf._startPoint
                mySelf._shapeDescription.append("\t#\n") // fprintf(output, "\t#\n");
                mySelf._shapeDescription.append("}\n") // fprintf(output, "}\n");
                mySelf._success = true
            }
            //let points = Array(UnsafeBufferPointer(start: element.points, count: pointCount))
            //print("\(command) \(points)")
        })
        if !_success {
            return nil
        }
        return _shapeDescription
    }
    
}
