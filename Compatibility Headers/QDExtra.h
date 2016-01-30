/*
	QDExtra.h
	-------------------
 */

#ifndef QDEXTRA_H
#define QDEXTRA_H

// Mac OS X
#ifdef __APPLE__
#include <ApplicationServices/ApplicationServices.h>
#endif

// Mac OS
#ifndef __QUICKDRAW__
#include <Quickdraw.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif
    
#ifdef MAC_OS_X_VERSION_10_7

enum {
    blackColor                    = 33,
    whiteColor                    = 30,
    redColor                      = 205,
    greenColor                    = 341,
    blueColor                     = 409,
    cyanColor                     = 273,
    magentaColor                  = 137,
    yellowColor                   = 69
};

enum {
    systemFont                    = 0,
    applFont                      = 1
};
    
/* gdFlags bits. Bits 1..10 are legacy, and currently unused */
enum {
    gdDevType                     = 0,    /* 0 = monochrome 1 = color */
    interlacedDevice              = 2,
    hwMirroredDevice              = 4,
    roundedDevice                 = 5,
    hasAuxMenuBar                 = 6,
    burstDevice                   = 7,
    ext32Device                   = 8,
    ramInit                       = 10,
    mainScreen                    = 11,   /* 1 if main screen */
    allInit                       = 12,   /* 1 if all devices initialized */
    screenDevice                  = 13,   /* 1 if screen device */
    noDriver                      = 14,   /* 1 if no driver for this GDevice */
    screenActive                  = 15    /* 1 if in use*/
};

    
extern void ForeColor(long color)                                         AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern void BackColor(long color)                                         AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern void CopyMask(const BitMap *  srcBits,
                     const BitMap *  maskBits,
                     const BitMap *  dstBits,
                     const Rect *    srcRect,
                     const Rect *    maskRect,
                     const Rect *    dstRect)                                    AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern void PenMode(short mode)                                           AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern long DeltaPoint(Point   ptA,
                       Point   ptB)                                                AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern void GetIndPattern(Pattern *  thePat,
                          short      patternListID,
                          short      index)                                           AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern PicHandle GetPicture(short pictureID)                                   AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern void SubPt(Point    src,
                  Point *  dst)                                               AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER;

extern void DrawString(ConstStr255Param s)                                AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern short TextWidth(const void *  textBuf,
                       short         firstByte,
                       short         byteCount)                                    AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern short HasDepth(GDHandle   gd,
                      short      depth,
                      short      whichFlags,
                      short      flags)                                           AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern OSErr SetDepth(GDHandle   gd,
                      short      depth,
                      short      whichFlags,
                      short      flags)                                           AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern Rect * GetRegionBounds(RgnHandle   region,
                              Rect *      bounds)                                         AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER;

extern Boolean
TestDeviceAttribute(GDHandle   gdh,
                    short      attribute)                                       AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern CCrsrHandle GetCCursor(short crsrID)                                      AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern void SetCCursor(CCrsrHandle cCrsr)                                 AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern void Index2Color(long        index,
                        RGBColor *  aColor)                                         AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern void RestoreDeviceClut(GDHandle gd)                                AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_4;

extern Boolean PtInRgn(Point       pt,
                       RgnHandle   rgn)                                            AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER;

#endif  // #ifdef MAC_OS_X_VERSION_10_7
    
#ifdef __cplusplus
}
#endif

#endif

