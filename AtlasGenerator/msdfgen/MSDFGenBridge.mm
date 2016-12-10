//
//  MSDFGenBridge.m
//  AtlasGenerator
//
//  Created by Ryan Walklin on 9/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

#import "MSDFGenBridge.h"

#import "msdfgen.h"

@interface Shape ()

@property msdfgen::Shape shapeObj;

@end

@implementation Shape

-(id)init {
    self = [super init];
    _shapeObj = msdfgen::Shape();
    return self;
}

-(id)initWithDescription:(nonnull NSString *)description {
    self = [super init];
    _shapeObj = msdfgen::Shape();
    
    if (msdfgen::readShapeDescription(description.UTF8String, _shapeObj, &_skipColoring) == false) {
        return nil;
    }
    if (!_shapeObj.validate()) {
        return nil;
    }
    return self;
}

-(void)normalise {
    _shapeObj.normalize();
}

@end


@implementation MSDFGenBridge

+(void)generateMSDF:(float *)bitmap width:(int)width height:(int)height shape:(Shape *)shape range:(double)range scaleX:(double)scaleX scaleY:(double)scaleY translateX:(double)translateX translateY:(double)translateY edgeThreshold:(double)edgeThreshold {
    
    double angleThreshold = 3;
    unsigned long long coloringSeed = 0;
    
    if (!shape.skipColoring) {
        msdfgen::Shape shapeObj = shape.shapeObj;
        msdfgen::edgeColoringSimple(shapeObj, angleThreshold, coloringSeed);
    }
    msdfgen::Vector2 scale = msdfgen::Vector2(scaleX, scaleY);
    msdfgen::Vector2 translate = msdfgen::Vector2(translateX, translateY);
    msdfgen::Bitmap<msdfgen::FloatRGB> output = msdfgen::Bitmap<msdfgen::FloatRGB>(width, height);
    msdfgen::generateMSDF(output, shape.shapeObj, range, scale, translate);
    int pixel = 0;
    for (int y = 0; y < output.height(); ++y) {
        for (int x = 0; x < output.width(); ++x) {
            msdfgen::FloatRGB bgr = output(x, y);
            memcpy(bitmap+pixel, &bgr, 24);
            pixel += 3;
        }
    }
}


@end

