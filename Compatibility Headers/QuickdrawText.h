/*
	missing/QuickdrawText.h
	-----------------------
*/

#ifndef MISSING_QUICKDRAWTEXT_H
#define MISSING_QUICKDRAWTEXT_H

// Mac OS X
#ifdef __APPLE__
#include <ApplicationServices/ApplicationServices.h>
#endif

// Mac OS
#ifndef MAC_OS_X_VERSION_10_7
#ifndef __QUICKDRAWTEXT__
#include <QuickdrawText.h>
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef MAC_OS_X_VERSION_10_7

// ...

#if !__LP64__

extern void TextFont( short font );

extern void TextFace( StyleParameter face );

extern void TextMode( short mode );

extern void TextSize( short size );

// ...

extern short CharWidth( CharParameter ch );

extern short StringWidth( ConstStr255Param s );

// ...

#endif  // #if !__LP64__

#endif  // #ifdef MAC_OS_X_VERSION_10_7

#ifdef __cplusplus
}
#endif

#endif

