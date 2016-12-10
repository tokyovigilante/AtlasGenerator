//
//  MSDFGenBridge.h
//  AtlasGenerator
//
//  Created by Ryan Walklin on 9/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shape: NSObject

@property (readonly) bool skipColoring;

-(nonnull id)init;
-(nullable id)initWithDescription:(nonnull NSString *)description;

-(void)normalise;

@end

@interface MSDFGenBridge : NSObject

/// Generates a multi-channel signed distance field. Edge colors must be assigned first! (see edgeColoringSimple)

+(void)generateMSDF:(nonnull float *)bitmap width:(int)width height:(int)height shape:(nonnull Shape *)shape range:(double)range scaleX:(double)scaleX scaleY:(double)scaleY translateX:(double)translateX translateY:(double)translateY edgeThreshold:(double)edgeThreshold;

@end

