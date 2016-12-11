//
//  MSDFGenBridge.m
//  AtlasGenerator
//
//  Created by Ryan Walklin on 9/12/16.
//  Copyright © 2016 Ryan Walklin. All rights reserved.
//

#import "MSDFGenBridge.h"

#import "msdfgen.h"

#define LARGE_VALUE 1e240

@implementation MSDFGenBridge

+(bool)generateMSDF:(uint8_t *)bitmap width:(int)width height:(int)height shapeDesc:(const char *)shapeDesc translateX:(float)translateX translateY:(float)translateY edgeThreshold:(float)edgeThreshold autoFrame:(bool)autoFrame printMetrics:(bool)printMetrics {

    
    double angleThreshold = 3;
    unsigned long long coloringSeed = 0;
    
    bool scaleSpecified = false;

    struct {
        double l, b, r, t;
    } bounds = {
        LARGE_VALUE, LARGE_VALUE, -LARGE_VALUE, -LARGE_VALUE
    };
    
    msdfgen::Vector2 translate;
    msdfgen::Vector2 scale = 1;
    
    double range = 1;
    double pxRange = 2;
    
    double avgScale = .5*(scale.x+scale.y);
    
    enum {
        RANGE_UNIT,
        RANGE_PX
    } rangeMode = RANGE_PX;
    
    bool skipColoring;
    msdfgen::Shape shape;
    msdfgen::readShapeDescription(shapeDesc, shape, &skipColoring);
    if (!shape.validate()) {
        return false;
    }
    shape.normalize();

    if (autoFrame || printMetrics)
        shape.bounds(bounds.l, bounds.b, bounds.r, bounds.t);
    
    // Auto-frame
    if (autoFrame) {
        double l = bounds.l, b = bounds.b, r = bounds.r, t = bounds.t;
        msdfgen::Vector2 frame(width, height);
        if (rangeMode == RANGE_UNIT)
            l -= range, b -= range, r += range, t += range;
        else if (!scaleSpecified)
            frame -= 2*range;
        if (l >= r || b >= t)
            l = 0, b = 0, r = 1, t = 1;
        if (frame.x <= 0 || frame.y <= 0) {
            printf("Cannot fit the specified pixel range.");
            return false;
        }
        msdfgen::Vector2 dims(r-l, t-b);
        if (scaleSpecified)
            translate = .5*(frame/scale-dims)-msdfgen::Vector2(l, b);
        else {
            if (dims.x*frame.y < dims.y*frame.x) {
                translate.set(.5*(frame.x/frame.y*dims.y-dims.x)-l, -b);
                scale = avgScale = frame.y/dims.y;
            } else {
                translate.set(-l, .5*(frame.y/frame.x*dims.x-dims.y)-b);
                scale = avgScale = frame.x/dims.x;
            }
        }
        if (rangeMode == RANGE_PX && !scaleSpecified)
            translate += pxRange/scale;
    }
    
    if (rangeMode == RANGE_PX)
        range = pxRange/fmin(scale.x, scale.y);
    
    // Print metrics
    if (printMetrics) {
        FILE *out = stdout;
        /*if (mode == METRICS && outputSpecified)
            out = fopen(output, "w");
        if (!out)
            ABORT("Failed to write output file.");*/
        if (shape.inverseYAxis)
            fprintf(out, "inverseY = true\n");
        if (bounds.r >= bounds.l && bounds.t >= bounds.b)
            fprintf(out, "bounds = %.12g, %.12g, %.12g, %.12g\n", bounds.l, bounds.b, bounds.r, bounds.t);
        /*if (svgDims.x != 0 && svgDims.y != 0)
            fprintf(out, "dimensions = %.12g, %.12g\n", svgDims.x, svgDims.y);*/
        /*if (glyphAdvance != 0)
            fprintf(out, "advance = %.12g\n", glyphAdvance);*/
        if (autoFrame) {
            if (!scaleSpecified)
                fprintf(out, "scale = %.12g\n", avgScale);
            fprintf(out, "translate = %.12g, %.12g\n", translate.x, translate.y);
        }
        if (rangeMode == RANGE_PX)
            fprintf(out, "range = %.12g\n", range);
        /*if (mode == METRICS && outputSpecified)
            fclose(out);*/
    }
    
    if (!skipColoring) {
        msdfgen::edgeColoringSimple(shape, angleThreshold, coloringSeed);
    }

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

