
#pragma once

/*
 * MULTI-CHANNEL SIGNED DISTANCE FIELD GENERATOR v1.3 (2016-12-07)
 * ---------------------------------------------------------------
 * A utility by Viktor Chlumsky, (c) 2014 - 2016
 *
 * The technique used to generate multi-channel distance fields in this code
 * has been developed by Viktor Chlumsky in 2014 for his master's thesis,
 * "Shape Decomposition for Multi-Channel Distance Fields". It provides improved
 * quality of sharp corners in glyphs and other 2D shapes in comparison to monochrome
 * distance fields. To reconstruct an image of the shape, apply the median of three
 * operation on the triplet of sampled distance field values.
 *
 */

#include "arithmetics.hpp"
#include "Vector2.h"
#include "Shape.h"
#include "Bitmap.h"
#include "edge-coloring.h"
#include "render-sdf.h"
#include "save-bmp.h"
#include "shape-description.h"

#define MSDFGEN_VERSION "1.3"

namespace msdfgen {

/// Generates a conventional single-channel signed distance field.
void generateSDF(Bitmap<float> &output, const Shape &shape, double range, const Vector2 &scale, const Vector2 &translate);

/// Generates a single-channel signed pseudo-distance field.
void generatePseudoSDF(Bitmap<float> &output, const Shape &shape, double range, const Vector2 &scale, const Vector2 &translate);

/// Generates a multi-channel signed distance field. Edge colors must be assigned first! (see edgeColoringSimple)
void generateMSDF(Bitmap<FloatRGB> &output, const Shape &shape, double range, const Vector2 &scale, const Vector2 &translate, double edgeThreshold = 1.00000001);

}
