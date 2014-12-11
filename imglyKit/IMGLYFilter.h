//
//  IMGLYFilter.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 25.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IMGLYFilterType) {
    IMGLYFilterTypeNone,
    IMGLYFilterTypeLord,
    IMGLYFilterTypePale,
    IMGLYFilterTypeHippie,
    IMGLYFilterTypeTejas,
    IMGLYFilterTypeSunny,
    IMGLYFilterTypeMellow,
    IMGLYFilterTypeA15,
    IMGLYFilterTypeFood,
    IMGLYFilterTypeLomo,
    IMGLYFilterTypeBW,
    IMGLYFilterTypeBWSoft,
    IMGLYFilterTypeBWHard,
    IMGLYFilterTypeSketch,
    IMGLYFilterType8Bit,
    IMGLYFilterType669,
    IMGLYFilterTypePola,
    IMGLYFilterTypeGlam,
    IMGLYFilterTypeBrightness,
    IMGLYFilterTypeContrast,
    IMGLYFilterTypeSaturation,
    IMGLYFilterTypeBoxTiltShift,
    IMGLYFilterTypeRadialTiltShift,
    IMGLYFilterTypeGauss,
    IMGLYFilterTypeOrientation,
    IMGLYFilterType9EK1,
    IMGLYFilterType9EK6,
    IMGLYFilterType9EKDynamic,
    IMGLYFilterTypeNoise,
    IMGLYFilterTypeFridge,
    IMGLYFilterTypeChestnut,
    IMGLYFilterTypeFront,
    IMGLYFilterTypeFixie,
 };

@class GPUImageOutput;
@protocol GPUImageInput;

@interface IMGLYFilter : NSObject

+ (GPUImageOutput <GPUImageInput> *)filterWithType:(IMGLYFilterType)filterType;

@end
