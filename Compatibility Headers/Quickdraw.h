/*
	missing/Quickdraw.h
	-------------------
*/

#ifndef MISSING_QUICKDRAW_H
#define MISSING_QUICKDRAW_H

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

// ...

enum
{
//	srcCopy            = 0,
	srcOr              = 1,
	srcXor             = 2,
	srcBic             = 3,
	notSrcCopy         = 4,
	notSrcOr           = 5,
	notSrcXor          = 6,
	notSrcBic          = 7,
	patCopy            = 8,
	patOr              = 9,
	patXor             = 10,
	patBic             = 11,
	notPatCopy         = 12,
	notPatOr           = 13,
	notPatXor          = 14,
	notPatBic          = 15,
	grayishTextOr      = 49,
	hilitetransfermode = 50,
	hilite             = 50,
	blend              = 32,
	addPin             = 33,
	addOver            = 34,
	subPin             = 35,
	addMax             = 37,
	adMax              = 37,
	subOver            = 38,
	adMin              = 39,
	ditherCopy         = 64,
	transparent        = 36
};

// ...

enum
{
	sysPatListID = 0,
	iBeamCursor  = 1,
	crossCursor  = 2,
	plusCursor   = 3,
	watchCursor  = 4
};

// ...

typedef SInt8 PixelType;

typedef short Bits16[ 16 ];

// ...

struct Cursor
{
	Bits16  data;
	Bits16  mask;
	Point   hotSpot;
};

typedef struct Cursor  Cursor;
typedef Cursor*        CursPtr;
typedef CursPtr*       CursHandle;

struct PenState
{
	Point    pnLoc;
	Point    pnSize;
	short    pnMode;
	Pattern  pnPat;
};

typedef struct PenState PenState;

// ...

struct CCrsr
{
	short         crsrType;
	PixMapHandle  crsrMap;
	Handle        crsrData;
	Handle        crsrXData;
	short         crsrXValid;
	Handle        crsrXHandle;
	Bits16        crsr1Data;
	Bits16        crsrMask;
	Point         crsrHotSpot;
	long          crsrXTable;
	long          crsrID;
};

typedef struct CCrsr  CCrsr;
typedef CCrsr*        CCrsrPtr;
typedef CCrsrPtr*     CCrsrHandle;

// ...

#pragma mark -

#define MacSetPort SetPort

extern void MacSetPort( GrafPtr port );

extern void GetPort( GrafPtr* port );

extern Boolean QDSwapPort( CGrafPtr   inNewPort,
                           CGrafPtr*  outOldPort );

// ...

extern void PortSize( short  width,
                      short  height );

extern void MovePortTo( short  leftGlobal,
                        short  topGlobal );

extern void SetOrigin( short  h,
                       short  v );

extern void SetClip( RgnHandle rgn );

extern void GetClip( RgnHandle rgn );

extern void ClipRect( const Rect* r );

extern void BackPat( const Pattern* pat );

#pragma mark -

extern void InitCursor( void );

#define MacSetCursor SetCursor

extern void MacSetCursor( const Cursor* crsr );

extern void HideCursor( void );

#define MacShowCursor ShowCursor

extern void MacShowCursor( void );

extern void ObscureCursor( void );

#pragma mark -

extern void HidePen( void );

extern void ShowPen( void );

// ...

extern void GetPenState( PenState* pnState );

extern void SetPenState( const PenState* pnState );

extern void PenSize( short  width,
                     short  height );

// ...

extern void PenPat( const Pattern* pat );

extern void PenNormal( void );

extern void MoveTo( short  h,
                    short  v );

extern void Move( short  dh,
                  short  dv );

#define MacLineTo LineTo

extern void MacLineTo( short  h,
                       short  v );

extern void Line( short  dh,
                  short  dv );

// ...

#pragma mark -

#define MacSetRect SetRect

extern void MacSetRect( Rect*  r,
                        short  left,
                        short  top,
                        short  right,
                        short  bottom );

#define MacOffsetRect OffsetRect

extern void MacOffsetRect( Rect*  r,
                           short  dh,
                           short  dv );

#define MacInsetRect InsetRect

extern void MacInsetRect( Rect*  r,
                          short  dh,
                          short  dv );

extern Boolean SectRect( const Rect*  src1,
                         const Rect*  src2,
                         Rect*        dstRect );

#define MacUnionRect UnionRect

extern Boolean MacUnionRect( const Rect*  src1,
                             const Rect*  src2,
                             Rect*        dstRect );

// ...

extern Boolean EmptyRect( const Rect* r );

#define MacFrameRect FrameRect

extern void MacFrameRect( const Rect* r );

extern void PaintRect( const Rect* r );

extern void EraseRect( const Rect* r );

#define MacInvertRect InvertRect

extern void MacInvertRect( const Rect* r );

#define MacFillRect FillRect

extern void MacFillRect( const Rect*     r,
                         const Pattern*  pat );

#pragma mark -

extern void FrameOval( const Rect* r );

extern void PaintOval( const Rect* r );

extern void EraseOval( const Rect* r );

extern void InvertOval( const Rect* r );

extern void FillOval( const Rect*     r,
                      const Pattern*  pat );

extern void FrameRoundRect( const Rect*  r,
                            short        ovalWidth,
                            short        ovalHeight );

// ...

#pragma mark -

extern RgnHandle NewRgn( void );

extern void OpenRgn( void );

extern void CloseRgn( RgnHandle dstRgn );

// ...

extern void DisposeRgn( RgnHandle rgn );

#define MacCopyRgn CopyRgn

extern void MacCopyRgn( RgnHandle  srcRgn,
                        RgnHandle  dstRgn );

extern void SetEmptyRgn( RgnHandle rgn );

// ...

extern void RectRgn( RgnHandle    rgn,
                     const Rect*  r );

#define MacOffsetRgn OffsetRgn

extern void MacOffsetRgn( RgnHandle  rgn,
                          short      dh,
                          short      dv );

extern void InsetRgn( RgnHandle  rgn,
                      short      dh,
                      short      dv );

extern void SectRgn( RgnHandle  srcRgnA,
                     RgnHandle  srcRgnB,
                     RgnHandle  dstRgn );

#define MacUnionRgn UnionRgn

extern void MacUnionRgn( RgnHandle  srcRgnA,
                         RgnHandle  srcRgnB,
                         RgnHandle  dstRgn );

extern void DiffRgn( RgnHandle  srcRgnA,
                     RgnHandle  srcRgnB,
                     RgnHandle  dstRgn );

#define MacXorRgn XorRgn

extern void MacXorRgn( RgnHandle  srcRgnA,
                       RgnHandle  srcRgnB,
                       RgnHandle  dstRgn );

extern Boolean RectInRgn( const Rect*  r,
                          RgnHandle    rgn );

#define MacEqualRgn EqualRgn

extern Boolean MacEqualRgn( RgnHandle  rgnA,
                            RgnHandle  rgnB );

extern Boolean EmptyRgn( RgnHandle rgn );

#define MacFrameRgn FrameRgn

extern void MacFrameRgn( RgnHandle rgn );

#define MacPaintRgn PaintRgn

extern void MacPaintRgn( RgnHandle rgn );

extern void EraseRgn( RgnHandle rgn );

#define MacInvertRgn InvertRgn

extern void MacInvertRgn( RgnHandle rgn );

#define MacFillRgn FillRgn

extern void MacFillRgn( RgnHandle       rgn,
                        const Pattern*  pat );

#pragma mark -

extern void ScrollRect( const Rect*  r,
                        short        dh,
                        short        dv,
                        RgnHandle    updateRgn );

extern void CopyBits( const BitMap*  srcBits,
                      const BitMap*  dstBits,
                      const Rect*    srcRect,
                      const Rect*    dstRect,
                      short          mode,
                      RgnHandle      maskRgn );

// ...

#pragma mark -

extern void ClosePicture( void );

// ...

extern void DrawPicture( PicHandle    pic,
                         const Rect*  dstRect );

extern void KillPicture( PicHandle pic );

// ...

#pragma mark -

extern void ClosePoly( void );

extern void KillPoly( PolyHandle poly );

extern void OffsetPoly( PolyHandle  poly,
                        short       dh,
                        short       dv );

extern void FramePoly( PolyHandle poly );

extern void PaintPoly( PolyHandle poly );

extern void ErasePoly( PolyHandle poly );

extern void InvertPoly( PolyHandle poly );

extern void FillPoly( PolyHandle      poly,
                      const Pattern*  pat );

// ...

#pragma mark -

extern void LocalToGlobal( Point* pt );

extern void GlobalToLocal( Point* pt );

extern short Random( void );

// ...

#define MacGetPixel GetPixel

extern Boolean MacGetPixel( short  h,
                            short  v );

// ...

extern Boolean EqualPt( Point  pt1,
                        Point  pt2 );

#define MacPtInRect PtInRect

extern Boolean MacPtInRect( Point        pt,
                            const Rect*  r );

// ...

extern void DisposePixPat( PixPatHandle pp );

// ...

extern void PenPixPat( PixPatHandle pp );

extern void BackPixPat( PixPatHandle pp );

// ...

extern void RGBForeColor( const RGBColor* color );

extern void RGBBackColor( const RGBColor* color );

extern void SetCPixel( short            h,
                       short            v,
                       const RGBColor*  cPix );

extern void SetPortPix( PixMapHandle pm );

extern void GetCPixel( short      h,
                       short      v,
                       RGBColor*  cPix );

extern void GetForeColor( RGBColor* color );

extern void GetBackColor( RGBColor* color );

// ...

extern void DisposeCTable( CTabHandle cTable );

// ...

extern void AllocCursor( void );

extern void DisposeCCursor( CCrsrHandle cCrsr );

// ...

extern GDHandle GetDeviceList( void );

extern GDHandle GetMainDevice( void );

extern GDHandle GetNextDevice( GDHandle curDevice );

// ...

extern void DisposeGDevice( GDHandle gdh );

extern void SetGDevice( GDHandle gdh );

extern GDHandle GetGDevice( void );

// ...

extern short QDError( void );

// ...

#define MacGetCursor GetCursor

extern CursHandle MacGetCursor( short cursorID );

// ...

extern PixMapHandle GetPortPixMap( CGrafPtr port );

extern const BitMap* GetPortBitMapForCopyBits( CGrafPtr port );

extern Rect* GetPortBounds( CGrafPtr  port,
                            Rect*     rect );

extern RGBColor* GetPortForeColor( CGrafPtr   port,
                                   RGBColor*  foreColor );

extern RGBColor* GetPortBackColor( CGrafPtr   port,
                                   RGBColor*  backColor );

// ...

extern short GetPortTextFont( CGrafPtr port );

extern Style GetPortTextFace( CGrafPtr port );

extern short GetPortTextMode( CGrafPtr port );

extern short GetPortTextSize( CGrafPtr port );

// ...

extern RgnHandle GetPortVisibleRegion( CGrafPtr   port,
                                       RgnHandle  visRgn );

extern RgnHandle GetPortClipRegion( CGrafPtr   port,
                                    RgnHandle  clipRgn );

extern Point* GetPortPenSize( CGrafPtr  port,
                              Point*    penSize );

// ...

extern Boolean IsPortColor( CGrafPtr port );

extern Boolean IsPortVisibleRegionEmpty( CGrafPtr port );

// ...

extern void SetPortTextFont( CGrafPtr  port,
                             short     txFont );

extern void SetPortTextSize( CGrafPtr  port,
                             short     txSize );

// ...

extern void SetPortClipRegion( CGrafPtr   port,
                               RgnHandle  clipRgn );

// ...

extern void SetPortPenSize( CGrafPtr  port,
                            Point     penSize );

// ...

extern BitMap* GetQDGlobalsScreenBits( BitMap* screenBits );

extern Cursor* GetQDGlobalsArrow( Cursor* arrow );

extern Pattern* GetQDGlobalsDarkGray ( Pattern* dkGray );
extern Pattern* GetQDGlobalsLightGray( Pattern* ltGray );
extern Pattern* GetQDGlobalsGray     ( Pattern* gray   );
extern Pattern* GetQDGlobalsBlack    ( Pattern* black  );
extern Pattern* GetQDGlobalsWhite    ( Pattern* white  );

extern CGrafPtr GetQDGlobalsThePort( void );

// ...

extern CGrafPtr CreateNewPort( void );

extern void DisposePort( CGrafPtr port );

// ...

extern void QDFlushPortBuffer( CGrafPtr   port,
                               RgnHandle  region );

// ...

extern CGrafPtr CreateNewPortForCGDisplayID( UInt32 inCGDisplayID );

// ...

#endif  // #ifdef MAC_OS_X_VERSION_10_7

#ifdef __cplusplus
}
#endif

#endif

