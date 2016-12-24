//
//  MSDFGenBridge.h
//  AtlasGenerator
//
//  Created by Ryan Walklin on 9/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDFGenBridge : NSObject

/// Generates a multi-channel signed distance field. Edge colors must be assigned first! (see edgeColoringSimple)

+(bool)generateMSDF:(nonnull uint8_t *)bitmap width:(int)width height:(int)height shapeDesc:(nonnull const char *)shapeDesc translateX:(float)translateX translateY:(float)translateY edgeThreshold:(float)edgeThreshold autoFrame:(bool)autoFrame printMetrics:(bool)printMetrics scaledBounds:(nullable CGRect *)boundsRect;

@end

