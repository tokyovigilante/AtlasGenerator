//
//  MSDFGenBridge.m
//  AtlasGenerator
//
//  Created by Ryan Walklin on 9/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

#import "MSDFGenBridge.h"

#import "msdfgen.h"

@implementation MSDFGenBridge

+(bool)generateMSDF:(uint8_t *)bitmap width:(int)width height:(int)height shapeDesc:(const char *)shapeDesc range:(float)range scaleX:(float)scaleX scaleY:(float)scaleY translateX:(float)translateX translateY:(float)translateY edgeThreshold:(float)edgeThreshold {
    
    double angleThreshold = 3;
    unsigned long long coloringSeed = 0;
    
    bool skipColoring;
    msdfgen::Shape shape;
    msdfgen::readShapeDescription(shapeDesc, shape, &skipColoring);
    if (!shape.validate()) {
        return false;
    }
    shape.normalize();
    if (!skipColoring) {
        msdfgen::edgeColoringSimple(shape, angleThreshold, coloringSeed);
    }
    
    msdfgen::Vector2 scale = msdfgen::Vector2(scaleX, scaleY);
    msdfgen::Vector2 translate = msdfgen::Vector2(translateX, translateY);
    msdfgen::Bitmap<msdfgen::FloatRGB> output = msdfgen::Bitmap<msdfgen::FloatRGB>(width, height);
    msdfgen::generateMSDF(output, shape, range, scale, translate);
    int pixel = 0;
    for (int y = 0; y < output.height(); ++y) {
        for (int x = 0; x < output.width(); ++x) {
            uint8_t bgr[3] = {
                (uint8_t) msdfgen::clamp(int(output(x, y).b*0x100), 0xff),
                (uint8_t) msdfgen::clamp(int(output(x, y).g*0x100), 0xff),
                (uint8_t) msdfgen::clamp(int(output(x, y).r*0x100), 0xff),
            };
            memcpy(bitmap+pixel, &bgr, 3);
            pixel+=4;
        }
    }
    return true;
}


@end

