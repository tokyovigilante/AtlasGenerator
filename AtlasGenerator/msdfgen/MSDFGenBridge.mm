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

+(void)generateMSDF:(float *)bitmap width:(int)width height:(int)height shape:(const void *)shape range:(double)range scaleX:(double)scaleX scaleY:(double)scaleY translateX:(double)translateX translateY:(double)translateY edgeThreshold:(double)edgeThreshold {
    
    msdfgen::Vector2 scale = msdfgen::Vector2(scaleX, scaleY);
    msdfgen::Vector2 translate = msdfgen::Vector2(translateX, translateY);
    const msdfgen::Shape *shapeObj = (msdfgen::Shape *)shape;
    msdfgen::Bitmap<msdfgen::FloatRGB> output = msdfgen::Bitmap<msdfgen::FloatRGB>(width, height);
    msdfgen::generateMSDF(output, *shapeObj, range, scale, translate);
}


@end

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
    
    if (msdfgen::readShapeDescription(description.UTF8String, _shapeObj) == false) {
        return nil;
    }
    if (!_shapeObj.validate()) {
        return nil;
    }
    return self;
}



@end
