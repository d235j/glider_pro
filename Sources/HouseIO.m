
//============================================================================
//----------------------------------------------------------------------------
//									HouseIO.c
//----------------------------------------------------------------------------
//============================================================================


#include "Quickdraw.h"
#include <CoreServices/CoreServices.h>
#include <QuickTime/QuickTime.h>
#include "Externs.h"
#include "Environ.h"
#include "House.h"
#include "ObjectEdit.h"


#define kSaveChangesAlert		1002
#define kSaveChanges			1
#define kDiscardChanges			2


void LoopMovie (void);
void OpenHouseMovie (void);
void CloseHouseMovie (void);
Boolean IsFileReadOnly (FSSpec *);
void HouseBigToHostEndian(void);


Movie		theMovie;
Rect		movieRect;
short		houseRefNum, houseResFork, wasHouseVersion;
Boolean		houseOpen, fileDirty, gameDirty;
Boolean		changeLockStateOfHouse, saveHouseLocked, houseIsReadOnly;
Boolean		hasMovie, tvInRoom;

extern	FSSpecPtr	theHousesSpecs;
extern	short		thisHouseIndex, tvWithMovieNumber;
extern	short		numberRooms, housesFound;
extern	Boolean		noRoomAtAll, quitting, wardBitSet;
extern	Boolean		phoneBitSet, bannerStarCountOn;


//==============================================================  Functions
//--------------------------------------------------------------  LoopMovie

void LoopMovie (void)
{
	Handle		theLoop;
	UserData	theUserData;
	short		theCount;
	
	theLoop = NewHandle(sizeof(long));
	(** (long **) theLoop) = 0;
	theUserData = GetMovieUserData(theMovie);
	theCount = CountUserDataType(theUserData, 'LOOP');
	while (theCount--)
	{
		RemoveUserData(theUserData, 'LOOP', 1);
	}
	AddUserData(theUserData, theLoop, 'LOOP');
}

//--------------------------------------------------------------  OpenHouseMovie

void OpenHouseMovie (void)
{
#ifdef COMPILEQT
	TimeBase	theTime;
	FSSpec		theSpec;
	FInfo		finderInfo;
	Handle		spaceSaver;
	OSErr		theErr;
	short		movieRefNum;
	Boolean		dataRefWasChanged;
	
	if (thisMac.hasQT)
	{
		theSpec = theHousesSpecs[thisHouseIndex];
		PasStringConcat(theSpec.name, "\p.mov");
		
		theErr = FSpGetFInfo(&theSpec, &finderInfo);
		if (theErr != noErr)
			return;
		
		theErr = OpenMovieFile(&theSpec, &movieRefNum, fsCurPerm);
		if (theErr != noErr)
		{
			YellowAlert(kYellowQTMovieNotLoaded, theErr);
			return;
		}
		
		theErr = NewMovieFromFile(&theMovie, movieRefNum, nil, theSpec.name, 
				newMovieActive, &dataRefWasChanged);
		if (theErr != noErr)
		{
			YellowAlert(kYellowQTMovieNotLoaded, theErr);
			theErr = CloseMovieFile(movieRefNum);
			return;
		}
		theErr = CloseMovieFile(movieRefNum);
		
		spaceSaver = NewHandle(307200L);
		if (spaceSaver == nil)
		{
			YellowAlert(kYellowQTMovieNotLoaded, 749);
			CloseHouseMovie();
			return;
		}
		
		GoToBeginningOfMovie(theMovie);
		theErr = LoadMovieIntoRam(theMovie, 
				GetMovieTime(theMovie, 0L), GetMovieDuration(theMovie), 0);
		if (theErr != noErr)
		{
			YellowAlert(kYellowQTMovieNotLoaded, theErr);
			DisposeHandle(spaceSaver);
			CloseHouseMovie();
			return;
		}
		DisposeHandle(spaceSaver);
				
		theErr = PrerollMovie(theMovie, 0, 0x000F0000);
		if (theErr != noErr)
		{
			YellowAlert(kYellowQTMovieNotLoaded, theErr);
			CloseHouseMovie();
			return;
		}
		
		theTime = GetMovieTimeBase(theMovie);
		SetTimeBaseFlags(theTime, loopTimeBase);
		SetMovieMasterTimeBase(theMovie, theTime, nil);
		LoopMovie();
		
		GetMovieBox(theMovie, &movieRect);
		
		hasMovie = true;
	}
#endif
}

//--------------------------------------------------------------  CloseHouseMovie

void CloseHouseMovie (void)
{
#ifdef COMPILEQT
	OSErr		theErr;
	
	if ((thisMac.hasQT) && (hasMovie))
	{
		theErr = LoadMovieIntoRam(theMovie, 
				GetMovieTime(theMovie, 0L), GetMovieDuration(theMovie), flushFromRam);
		DisposeMovie(theMovie);
	}
#endif
	hasMovie = false;
}

//--------------------------------------------------------------  OpenHouse
// Opens a house (whatever current selection is).  Returns true if all went well.

Boolean OpenHouse (void)
{
	OSErr		theErr;
	Boolean		targetIsFolder, wasAliased;
	
	if (houseOpen)
	{
		if (!CloseHouse())
			return(false);
	}
	if ((housesFound < 1) || (thisHouseIndex == -1))
		return(false);
	
	theErr = ResolveAliasFile(&theHousesSpecs[thisHouseIndex], true, 
			&targetIsFolder, &wasAliased);
	if (!CheckFileError(theErr, thisHouseName))
		return (false);
	
	#ifdef COMPILEDEMO
	if (!EqualString(theHousesSpecs[thisHouseIndex].name, "\pDemo House", false, true))
		return (false);
	#endif
	
	houseIsReadOnly = IsFileReadOnly(&theHousesSpecs[thisHouseIndex]);
	
	theErr = FSpOpenDF(&theHousesSpecs[thisHouseIndex], fsCurPerm, &houseRefNum);
	if (!CheckFileError(theErr, thisHouseName))
		return (false);
	
	houseOpen = true;
	OpenHouseResFork();
	
	hasMovie = false;
	tvInRoom = false;
	tvWithMovieNumber = -1;
	OpenHouseMovie();
	
	return (true);
}

//--------------------------------------------------------------  OpenSpecificHouse
// Opens the specific house passed in.

#ifndef COMPILEDEMO
Boolean OpenSpecificHouse (FSSpec *specs)
{
	short		i;
	Boolean		itOpened;
	
	if ((housesFound < 1) || (thisHouseIndex == -1))
		return (false);
	
	itOpened = true;
	
	for (i = 0; i < housesFound; i++)
	{
		if ((theHousesSpecs[i].vRefNum == specs->vRefNum) && 
				(theHousesSpecs[i].parID == specs->parID) && 
				(EqualString(theHousesSpecs[i].name, specs->name, false, true)))
		{
			thisHouseIndex = i;
			PasStringCopy(theHousesSpecs[thisHouseIndex].name, thisHouseName);
			if (OpenHouse())
				itOpened = ReadHouse();
			else
				itOpened = false;
			break;
		}
	}
	
	return (itOpened);
}
#endif

//--------------------------------------------------------------  SaveHouseAs

#ifndef COMPILEDEMO
Boolean SaveHouseAs (void)
{
	// TEMP - fix this later -- use NavServices (see House.c)
/*
	StandardFileReply	theReply;
	FSSpec				oldHouse;
	OSErr				theErr;
	Boolean				noProblems;
	Str255				tempStr;
	
	noProblems = true;
	
	GetLocalizedString(15, tempStr);
	StandardPutFile(tempStr, thisHouseName, &theReply);
	if (theReply.sfGood)
	{
		oldHouse = theHousesSpecs[thisHouseIndex];
			
		CloseHouseResFork();						// close this house file
		theErr = FSClose(houseRefNum);
		if (theErr != noErr)
		{
			CheckFileError(theErr, "\pPreferences");
			return(false);
		}
													// create new house file
		theErr = FSpCreate(&theReply.sfFile, 'ozm5', 'gliH', theReply.sfScript);
		if (!CheckFileError(theErr, theReply.sfFile.name))
			return (false);
		HCreateResFile(theReply.sfFile.vRefNum, theReply.sfFile.parID, 
				theReply.sfFile.name);
		if (ResError() != noErr)
			YellowAlert(kYellowFailedResCreate, ResError());
		PasStringCopy(theReply.sfFile.name, thisHouseName);
													// open new house data fork
		theErr = FSpOpenDF(&theReply.sfFile, fsRdWrPerm, &houseRefNum);
		if (!CheckFileError(theErr, thisHouseName))
			return (false);
		
		houseOpen = true;
		
		noProblems = WriteHouse(false);				// write out house data
		if (!noProblems)
			return(false);
		
		BuildHouseList();
		if (OpenSpecificHouse(&theReply.sfFile))	// open new house again
		{
		}
		else
		{
			if (OpenSpecificHouse(&oldHouse))
			{
				YellowAlert(kYellowOpenedOldHouse, 0);
			}
			else
			{
				YellowAlert(kYellowLostAllHouses, 0);
				noProblems = false;
			}
		}
	}
	
	
	return (noProblems);
	*/
	return false;
}
#endif

//--------------------------------------------------------------  ReadHouse
// With a house open, this function reads in the actual bits of data…
// into memory.

Boolean ReadHouse (void)
{
	long		byteCount;
	OSErr		theErr;
	short		whichRoom;
	
	if (!houseOpen)
	{
		YellowAlert(kYellowUnaccounted, 2);
		return (false);
	}
	
	if (gameDirty || fileDirty)
	{
		if (houseIsReadOnly)
		{
			if (!WriteScoresToDisk())
			{
				YellowAlert(kYellowFailedWrite, 0);
				return(false);
			}
		}
		else if (!WriteHouse(false))
			return(false);
	}
	
	theErr = GetEOF(houseRefNum, &byteCount);
	if (theErr != noErr)
	{
		CheckFileError(theErr, thisHouseName);
		return(false);
	}
	
	#ifdef COMPILEDEMO
	if (byteCount != 16526L)
		return (false);
	#endif
	
	if (thisHouse != nil)
		DisposeHandle((Handle)thisHouse);
	
	thisHouse = (houseHand)NewHandle(byteCount);
	if (thisHouse == nil)
	{
		YellowAlert(kYellowNoMemory, 10);
		return(false);
	}
	MoveHHi((Handle)thisHouse);
	
	theErr = SetFPos(houseRefNum, fsFromStart, 0L);
	if (theErr != noErr)
	{
		CheckFileError(theErr, thisHouseName);
		return(false);
	}
	
	HLock((Handle)thisHouse);
	theErr = FSRead(houseRefNum, &byteCount, *thisHouse);
	if (theErr != noErr)
	{
		CheckFileError(theErr, thisHouseName);
		HUnlock((Handle)thisHouse);
		return(false);
	}
	
    HouseBigToHostEndian();

	numberRooms = (*thisHouse)->nRooms;
	#ifdef COMPILEDEMO
	if (numberRooms != 45)
		return (false);
	#endif
	if ((numberRooms < 1) || (byteCount == 0L))
	{
		numberRooms = 0;
		noRoomAtAll = true;
		YellowAlert(kYellowNoRooms, 0);
		HUnlock((Handle)thisHouse);
		return(false);
	}
	
	wasHouseVersion = (*thisHouse)->version;
	if (wasHouseVersion >= kNewHouseVersion)
	{
		YellowAlert(kYellowNewerVersion, 0);
		HUnlock((Handle)thisHouse);
		return(false);
	}
	
	houseUnlocked = (((*thisHouse)->timeStamp & 0x00000001) == 0);
	#ifdef COMPILEDEMO
	if (houseUnlocked)
		return (false);
	#endif
	changeLockStateOfHouse = false;
	saveHouseLocked = false;
	
	whichRoom = (*thisHouse)->firstRoom;
	#ifdef COMPILEDEMO
	if (whichRoom != 0)
		return (false);
	#endif
	
	wardBitSet = (((*thisHouse)->flags & 0x00000001) == 0x00000001);
	phoneBitSet = (((*thisHouse)->flags & 0x00000002) == 0x00000002);
	bannerStarCountOn = (((*thisHouse)->flags & 0x00000004) == 0x00000000);
	
	HUnlock((Handle)thisHouse);
	
	noRoomAtAll = (RealRoomNumberCount() == 0);
	thisRoomNumber = -1;
	previousRoom = -1;
	if (!noRoomAtAll)
		CopyRoomToThisRoom(whichRoom);
	
	if (houseIsReadOnly)
	{
		houseUnlocked = false;
		if (ReadScoresFromDisk())
		{
		}
	}
	
	objActive = kNoObjectSelected;
	ReflectCurrentRoom(true);
	gameDirty = false;
	fileDirty = false;
	UpdateMenus(false);
	
	return (true);
}

//--------------------------------------------------------------  WriteHouse
// This function writes out the house data to disk.

Boolean WriteHouse (Boolean checkIt)
{
	UInt32			timeStamp;
	long			byteCount;
	OSErr			theErr;
	
	if (!houseOpen)
	{
		YellowAlert(kYellowUnaccounted, 4);
		return (false);
	}
	
	theErr = SetFPos(houseRefNum, fsFromStart, 0L);
	if (theErr != noErr)
	{
		CheckFileError(theErr, thisHouseName);
		return(false);
	}
	
	CopyThisRoomToRoom();
	
	if (checkIt)
		CheckHouseForProblems();
	
	HLock((Handle)thisHouse);
	byteCount = GetHandleSize((Handle)thisHouse);
	
	if (fileDirty)
	{
		GetDateTime(&timeStamp);
		timeStamp &= 0x7FFFFFFF;
		
		if (changeLockStateOfHouse)
			houseUnlocked = !saveHouseLocked;
		
		if (houseUnlocked)								// house unlocked
			timeStamp &= 0x7FFFFFFE;
		else
			timeStamp |= 0x00000001;
		(*thisHouse)->timeStamp = (long)timeStamp;
		(*thisHouse)->version = wasHouseVersion;
	}
	
	theErr = FSWrite(houseRefNum, &byteCount, *thisHouse);
	if (theErr != noErr)
	{
		CheckFileError(theErr, thisHouseName);
		HUnlock((Handle)thisHouse);
		return(false);
	}
	
	theErr = SetEOF(houseRefNum, byteCount);
	if (theErr != noErr)
	{
		CheckFileError(theErr, thisHouseName);
		HUnlock((Handle)thisHouse);
		return(false);
	}
	
	HUnlock((Handle)thisHouse);
	
	if (changeLockStateOfHouse)
	{
		changeLockStateOfHouse = false;
		ReflectCurrentRoom(true);
	}
	
	gameDirty = false;
	fileDirty = false;
	UpdateMenus(false);
	return (true);
}

//--------------------------------------------------------------  CloseHouse
// This function closes the current house that is open.

Boolean CloseHouse (void)
{
	OSErr		theErr;
	
	if (!houseOpen)
		return (true);
	
	if (gameDirty)
	{
		if (houseIsReadOnly)
		{
			if (!WriteScoresToDisk())
				YellowAlert(kYellowFailedWrite, 0);
		}
		else if (!WriteHouse(theMode == kEditMode))
			YellowAlert(kYellowFailedWrite, 0);
	}
	else if (fileDirty)
	{
#ifndef COMPILEDEMO
		if (!QuerySaveChanges())	// false signifies user canceled
			return(false);
#endif
	}
	
	CloseHouseResFork();
	CloseHouseMovie();
	
	theErr = FSClose(houseRefNum);
	if (theErr != noErr)
	{
		CheckFileError(theErr, thisHouseName);
		return(false);
	}
	
	houseOpen = false;
	
	return (true);
}

//--------------------------------------------------------------  OpenHouseResFork
// Opens the resource fork of the current house that is open.

void OpenHouseResFork (void)
{
	if (houseResFork == -1)
	{
		houseResFork = FSpOpenResFile(&theHousesSpecs[thisHouseIndex], fsCurPerm);
		if (houseResFork == -1)
			YellowAlert(kYellowFailedResOpen, ResError());
		else
			UseResFile(houseResFork);
	}
}

//--------------------------------------------------------------  CloseHouseResFork
// Closes the resource fork of the current house that is open.

void CloseHouseResFork (void)
{
	if (houseResFork != -1)
	{
		CloseResFile(houseResFork);
		houseResFork = -1;
	}
}

//--------------------------------------------------------------  QuerySaveChanges
// If changes were made, this function will present the user with a…
// dialog asking them if they would like to save the changes.

#ifndef COMPILEDEMO
Boolean QuerySaveChanges (void)
{
	short		hitWhat;
	Boolean		whoCares;
	
	if (!fileDirty)
		return(true);
	
	InitCursor();
//	CenterAlert(kSaveChangesAlert);
	ParamText(thisHouseName, "\p", "\p", "\p");
	hitWhat = Alert(kSaveChangesAlert, nil);
	if (hitWhat == kSaveChanges)
	{
		if (wasHouseVersion < kHouseVersion)
			ConvertHouseVer1To2();
		wasHouseVersion = kHouseVersion;
		if (WriteHouse(true))
			return (true);
		else
			return (false);
	}
	else if (hitWhat == kDiscardChanges)
	{
		fileDirty = false;
		if (!quitting)
		{
			whoCares = CloseHouse();
			if (OpenHouse())
				whoCares = ReadHouse();
		}
		UpdateMenus(false);
		return (true);
	}
	else
		return (false);
}
#endif

//--------------------------------------------------------------  YellowAlert
// This is a dialog used to present an error code and explanation…
// to the user when a non-lethal error has occurred.  Ideally, of…
// course, this never is called.

void YellowAlert (short whichAlert, short identifier)
{
	#define		kYellowAlert	1006
	Str255		errStr, errNumStr;
	short		whoCares;
	
	InitCursor();
	
	GetIndString(errStr, kYellowAlert, whichAlert);
	NumToString((long)identifier, errNumStr);
	
//	CenterAlert(kYellowAlert);
	ParamText(errStr, errNumStr, "\p", "\p");
	
	whoCares = Alert(kYellowAlert, nil);
}

//--------------------------------------------------------------  IsFileReadOnly

Boolean IsFileReadOnly (FSSpec *theSpec)
{
#pragma unused (theSpec)
	
	return false;
	/*
	Str255			tempStr;
	ParamBlockRec	theBlock;
	HParamBlockRec	hBlock;
	VolumeParam		*volPtr;
	OSErr			theErr;
	
	volPtr = (VolumeParam *)&theBlock;
	volPtr->ioCompletion = nil;
	volPtr->ioVolIndex = 0;
	volPtr->ioNamePtr = tempStr;
	volPtr->ioVRefNum = theSpec->vRefNum;
	
	theErr = PBGetVInfo(&theBlock, false);
	if (CheckFileError(theErr, "\pRead/Write"))
	{
		if (((volPtr->ioVAtrb & 0x0080) == 0x0080) || 
				((volPtr->ioVAtrb & 0x8000) == 0x8000))
			return (true);		// soft/hard locked bits
		else
		{
			hBlock.fileParam.ioCompletion = nil;
			hBlock.fileParam.ioVRefNum = theSpec->vRefNum;
			hBlock.fileParam.ioFVersNum = 0;
			hBlock.fileParam.ioFDirIndex = 0;
			hBlock.fileParam.ioNamePtr = theSpec->name;
			hBlock.fileParam.ioDirID = theSpec->parID;
			
			theErr = PBHGetFInfo(&hBlock, false);
			if (CheckFileError(theErr, "\pRead/Write"))
			{
				if ((hBlock.fileParam.ioFlAttrib & 0x0001) == 0x0001)
					return (true);
				else
					return (false);
			}
			else
				return (false);
		}
	}
	else
		return (false);
	*/
}

Byte getObjType(short what)
{
    switch (what)
    {
        case kFloorVent:
        case kCeilingVent:
        case kFloorBlower:
        case kCeilingBlower:
        case kSewerGrate:
        case kLeftFan:
        case kRightFan:
        case kTaper:
        case kCandle:
        case kStubby:
        case kTiki:
        case kBBQ:
        case kInvisBlower:
        case kGrecoVent:
        case kSewerBlower:
        case kLiftArea:
            return kBlowerMode;
            break;

        case kTable:
        case kShelf:
        case kCabinet:
        case kFilingCabinet:
        case kWasteBasket:
        case kMilkCrate:
        case kCounter:
        case kDresser:
        case kDeckTable:
        case kStool:
        case kTrunk:
        case kInvisObstacle:
        case kManhole:
        case kBooks:
        case kInvisBounce:
            return kFurnitureMode;
            break;

        case kRedClock:
        case kBlueClock:
        case kYellowClock:
        case kCuckoo:
        case kPaper:
        case kBattery:
        case kBands:
        case kGreaseRt:
        case kGreaseLf:
        case kFoil:
        case kInvisBonus:
        case kStar:
        case kSparkle:
        case kHelium:
        case kSlider:
            return kBonusMode;
            break;

        case kUpStairs:
        case kDownStairs:
        case kMailboxLf:
        case kMailboxRt:
        case kFloorTrans:
        case kCeilingTrans:
        case kDoorInLf:
        case kDoorInRt:
        case kDoorExRt:
        case kDoorExLf:
        case kWindowInLf:
        case kWindowInRt:
        case kWindowExRt:
        case kWindowExLf:
        case kInvisTrans:
        case kDeluxeTrans:
            return kTransportMode;
            break;

        case kLightSwitch:
        case kMachineSwitch:
        case kThermostat:
        case kPowerSwitch:
        case kKnifeSwitch:
        case kInvisSwitch:
        case kTrigger:
        case kLgTrigger:
        case kSoundTrigger:
            return kSwitchMode;
            break;

        case kCeilingLight:
        case kLightBulb:
        case kTableLamp:
        case kHipLamp:
        case kDecoLamp:
        case kFlourescent:
        case kTrackLight:
        case kInvisLight:
            return kLightMode;
            break;

        case kShredder:
        case kToaster:
        case kMacPlus:
        case kGuitar:
        case kTV:
        case kCoffee:
        case kOutlet:
        case kVCR:
        case kStereo:
        case kMicrowave:
        case kCinderBlock:
        case kFlowerBox:
        case kCDs:
        case kCustomPict:
            return kApplianceMode;
            break;

        case kBalloon:
        case kCopterLf:
        case kCopterRt:
        case kDartLf:
        case kDartRt:
        case kBall:
        case kDrip:
        case kFish:
        case kCobweb:
            return kEnemyMode;
            break;

        case kOzma:
        case kMirror:
        case kMousehole:
        case kFireplace:
        case kFlower:
        case kWallWindow:
        case kBear:
        case kCalendar:
        case kVase1:
        case kVase2:
        case kBulletin:
        case kCloud:
        case kFaucet:
        case kRug:
        case kChimes:
            return kClutterMode;
            break;
    }
    return 0;
}

void HouseBigToHostEndian(void)
{
    int i, j;

    (*thisHouse)->version = EndianS16_BtoN((*thisHouse)->version);
    (*thisHouse)->unusedShort = EndianS16_BtoN((*thisHouse)->unusedShort);
    (*thisHouse)->timeStamp = EndianS32_BtoN((*thisHouse)->timeStamp);
    (*thisHouse)->flags = EndianS32_BtoN((*thisHouse)->flags);
    (*thisHouse)->initial.h = EndianS16_BtoN((*thisHouse)->initial.h);
    (*thisHouse)->initial.v = EndianS16_BtoN((*thisHouse)->initial.v);
    // banner - string
    // trailer - string
    for(i=0; i<kMaxScores; i++) {
        for(j=0; j<kMaxScores; j++) {
            (*thisHouse)->highScores.scores[j] = EndianS32_BtoN((*thisHouse)->highScores.scores[j]);
            (*thisHouse)->highScores.timeStamps[j] = EndianU32_BtoN((*thisHouse)->highScores.timeStamps[j]);
            (*thisHouse)->highScores.levels[j] = EndianS16_BtoN((*thisHouse)->highScores.levels[j]);
        }
    }
    (*thisHouse)->savedGame.version = EndianS16_BtoN((*thisHouse)->savedGame.version);
    (*thisHouse)->savedGame.wasStarsLeft = EndianS16_BtoN((*thisHouse)->savedGame.wasStarsLeft);
    (*thisHouse)->savedGame.timeStamp = EndianS32_BtoN((*thisHouse)->savedGame.timeStamp);
    (*thisHouse)->savedGame.where.h = EndianS16_BtoN((*thisHouse)->savedGame.where.h);
    (*thisHouse)->savedGame.where.v = EndianS16_BtoN((*thisHouse)->savedGame.where.v);
    (*thisHouse)->savedGame.score = EndianS32_BtoN((*thisHouse)->savedGame.score);
    (*thisHouse)->savedGame.unusedLong = EndianS32_BtoN((*thisHouse)->savedGame.unusedLong);
    (*thisHouse)->savedGame.unusedLong2 = EndianS32_BtoN((*thisHouse)->savedGame.unusedLong2);
    (*thisHouse)->savedGame.energy = EndianS16_BtoN((*thisHouse)->savedGame.energy);
    (*thisHouse)->savedGame.bands = EndianS16_BtoN((*thisHouse)->savedGame.bands);
    (*thisHouse)->savedGame.roomNumber = EndianS16_BtoN((*thisHouse)->savedGame.roomNumber);
    (*thisHouse)->savedGame.gliderState = EndianS16_BtoN((*thisHouse)->savedGame.gliderState);
    (*thisHouse)->savedGame.numGliders = EndianS16_BtoN((*thisHouse)->savedGame.numGliders);
    (*thisHouse)->savedGame.foil = EndianS16_BtoN((*thisHouse)->savedGame.foil);
    (*thisHouse)->savedGame.unusedShort = EndianS16_BtoN((*thisHouse)->savedGame.unusedShort);

    // unusedBoolean -- Boolean
    (*thisHouse)->firstRoom = EndianS16_BtoN((*thisHouse)->firstRoom);
    (*thisHouse)->nRooms = EndianS16_BtoN((*thisHouse)->nRooms);

    for (i=0; i<((*thisHouse)->nRooms); i++) {
        // name - string
        (*thisHouse)->rooms[i].bounds = EndianS16_BtoN((*thisHouse)->rooms[i].bounds);
        // leftState - byte
        // rightState - byte
        // unusedByte - byte
        // visited - Boolean
        (*thisHouse)->rooms[i].background = EndianS16_BtoN((*thisHouse)->rooms[i].background);
        for(j=0; j<kNumTiles; j++) {
            (*thisHouse)->rooms[i].tiles[j] = EndianS16_BtoN((*thisHouse)->rooms[i].tiles[j]);
        }
        (*thisHouse)->rooms[i].floor = EndianS16_BtoN((*thisHouse)->rooms[i].floor);
        (*thisHouse)->rooms[i].suite = EndianS16_BtoN((*thisHouse)->rooms[i].suite);
        (*thisHouse)->rooms[i].openings = EndianS16_BtoN((*thisHouse)->rooms[i].openings);
        (*thisHouse)->rooms[i].numObjects = EndianS16_BtoN((*thisHouse)->rooms[i].numObjects);

        for(j=0; j<kMaxRoomObs && j<(*thisHouse)->rooms[i].numObjects; j++) {
            (*thisHouse)->rooms[i].objects[j].what = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].what);

            switch(getObjType((*thisHouse)->rooms[i].objects[j].what)) {
                case kBlowerMode:
                    (*thisHouse)->rooms[i].objects[j].data.a.distance = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.a.distance);
                    (*thisHouse)->rooms[i].objects[j].data.a.topLeft.h = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.a.topLeft.h);
                    (*thisHouse)->rooms[i].objects[j].data.a.topLeft.v = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.a.topLeft.v);
                    break;

                case kFurnitureMode:
                    (*thisHouse)->rooms[i].objects[j].data.b.bounds.bottom = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.b.bounds.bottom);
                    (*thisHouse)->rooms[i].objects[j].data.b.bounds.left = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.b.bounds.left);
                    (*thisHouse)->rooms[i].objects[j].data.b.bounds.right = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.b.bounds.right);
                    (*thisHouse)->rooms[i].objects[j].data.b.bounds.top = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.b.bounds.top);
                    (*thisHouse)->rooms[i].objects[j].data.b.pict = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.b.pict);
                    break;

                case kBonusMode:
                    (*thisHouse)->rooms[i].objects[j].data.c.length = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.c.length);
                    (*thisHouse)->rooms[i].objects[j].data.c.points = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.c.points);
                    (*thisHouse)->rooms[i].objects[j].data.c.topLeft.h = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.c.topLeft.h);
                    (*thisHouse)->rooms[i].objects[j].data.c.topLeft.v = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.c.topLeft.v);
                    break;

                case kTransportMode:
                    (*thisHouse)->rooms[i].objects[j].data.d.tall = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.d.tall);
                    (*thisHouse)->rooms[i].objects[j].data.d.where = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.d.where);
                    (*thisHouse)->rooms[i].objects[j].data.d.topLeft.h = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.d.topLeft.h);
                    (*thisHouse)->rooms[i].objects[j].data.d.topLeft.v = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.d.topLeft.v);
                    break;

                case kSwitchMode:
                    (*thisHouse)->rooms[i].objects[j].data.e.delay = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.e.delay);
                    (*thisHouse)->rooms[i].objects[j].data.e.where = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.e.where);
                    (*thisHouse)->rooms[i].objects[j].data.e.topLeft.h = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.e.topLeft.h);
                    (*thisHouse)->rooms[i].objects[j].data.e.topLeft.v = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.e.topLeft.v);
                    break;

                case kLightMode:
                    (*thisHouse)->rooms[i].objects[j].data.f.length = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.f.length);
                    (*thisHouse)->rooms[i].objects[j].data.f.topLeft.h = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.f.topLeft.h);
                    (*thisHouse)->rooms[i].objects[j].data.f.topLeft.v = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.f.topLeft.v);
                    break;

                case kApplianceMode:
                    (*thisHouse)->rooms[i].objects[j].data.g.height = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.g.height);
                    (*thisHouse)->rooms[i].objects[j].data.g.topLeft.h = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.g.topLeft.h);
                    (*thisHouse)->rooms[i].objects[j].data.g.topLeft.v = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.g.topLeft.v);
                    break;

                case kEnemyMode:
                    (*thisHouse)->rooms[i].objects[j].data.h.length = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.h.length);
                    (*thisHouse)->rooms[i].objects[j].data.h.topLeft.h = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.h.topLeft.h);
                    (*thisHouse)->rooms[i].objects[j].data.h.topLeft.v = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.h.topLeft.v);
                    break;

                case kClutterMode:
                    (*thisHouse)->rooms[i].objects[j].data.i.bounds.bottom = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.i.bounds.bottom);
                    (*thisHouse)->rooms[i].objects[j].data.i.bounds.left = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.i.bounds.left);
                    (*thisHouse)->rooms[i].objects[j].data.i.bounds.right = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.i.bounds.right);
                    (*thisHouse)->rooms[i].objects[j].data.i.bounds.top = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.i.bounds.top);
                    (*thisHouse)->rooms[i].objects[j].data.i.pict = EndianS16_BtoN((*thisHouse)->rooms[i].objects[j].data.i.pict);
                    break;
            }
        }

    }

}
