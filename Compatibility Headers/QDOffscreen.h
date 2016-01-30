/*
	missing/QDOffscreen.h
	---------------------
*/

#ifndef MISSING_QDOFFSCREEN_H
#define MISSING_QDOFFSCREEN_H

// Mac OS X
#ifdef __APPLE__
#include <ApplicationServices/ApplicationServices.h>
#endif

// Mac OS
#ifndef MAC_OS_X_VERSION_10_7
#ifndef __QDOFFSCREEN__
#include <QDOffscreen.h>
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef MAC_OS_X_VERSION_10_7

enum
{
	pixPurgeBit           =  0,
	noNewDeviceBit        =  1,
	useTempMemBit         =  2,
	keepLocalBit          =  3,
	useDistantHdwrMemBit  =  4,
	useLocalHdwrMemBit    =  5,
	pixelsPurgeableBit    =  6,
	pixelsLockedBit       =  7,
	nativeEndianPixMapBit =  8,
	mapPixBit             = 16,
	newDepthBit           = 17,
	alignPixBit           = 18,
	newRowBytesBit        = 19,
	reallocPixBit         = 20,
	clipPixBit            = 28,
	stretchPixBit         = 29,
	ditherPixBit          = 30,
	gwFlagErrBit          = 31
};

enum
{
	pixPurge                = 1L << pixPurgeBit,
	noNewDevice             = 1L << noNewDeviceBit,
	useTempMem              = 1L << useTempMemBit,
	keepLocal               = 1L << keepLocalBit,
	useDistantHdwrMem       = 1L << useDistantHdwrMemBit,
	useLocalHdwrMem         = 1L << useLocalHdwrMemBit,
	pixelsPurgeable         = 1L << pixelsPurgeableBit,
	pixelsLocked            = 1L << pixelsLockedBit,
	kNativeEndianPixMap     = 1L << nativeEndianPixMapBit,
	kAllocDirectDrawSurface = 1L << 14,
	mapPix                  = 1L << mapPixBit,
	newDepth                = 1L << newDepthBit,
	alignPix                = 1L << alignPixBit,
	newRowBytes             = 1L << newRowBytesBit,
	reallocPix              = 1L << reallocPixBit,
	clipPix                 = 1L << clipPixBit,
	stretchPix              = 1L << stretchPixBit,
	ditherPix               = 1L << ditherPixBit,
	gwFlagErr               = 1L << gwFlagErrBit
};

// ...

#if !__LP64__

extern QDErr NewGWorld( GWorldPtr*   offscreenGWorld,
                        short        pixelDepth,
                        const Rect*  boundsRect,
                        CTabHandle   cTable,
                        GDHandle     aGDevice,
                        GWorldFlags  flags );

// ...

extern Boolean LockPixels( PixMapHandle pm );

extern void UnlockPixels( PixMapHandle pm );

extern GWorldFlags UpdateGWorld( GWorldPtr*   offscreenGWorld,
                                 short        pixelDepth,
                                 const Rect*  boundsRect,
                                 CTabHandle   cTable,
                                 GDHandle     aGDevice,
                                 GWorldFlags  flags );

extern void DisposeGWorld( GWorldPtr offscreenGWorld );

extern void GetGWorld( CGrafPtr*  port,
                       GDHandle*  gdh );

extern void SetGWorld( CGrafPtr  port,
                       GDHandle  gdh );

// ...

extern GWorldFlags GetPixelsState( PixMapHandle pm );

extern void SetPixelsState( PixMapHandle  pm,
                            GWorldFlags   state );

// ...

extern PixMapHandle GetGWorldPixMap( GWorldPtr offscreenGWorld );

#endif  // #if !__LP64__

#endif  // #ifdef MAC_OS_X_VERSION_10_7

#ifdef __cplusplus
}
#endif

#endif

