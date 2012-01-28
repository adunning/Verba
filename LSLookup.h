//
//  LSLookup.h
//  Verba
//
//  Created by Joshua Hayes on 7/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"
#import <Foundation/Foundation.h>
#import "FMDatabaseAdditions.h"


@interface LSLookup : NSObject {
	int totalEntries;
	int currentEntryID;
	NSString* XMLData;
	NSString* headword;
	NSString* HTMLData;
	
	//Sqlite3 database stuff
	FMDatabase* db;
}
//Accessors
-(int) totalEntries;
-(int) currentEntryID;
-(NSString*) headword;
-(NSString*) HTMLData;

//Functions
-(BOOL) getEntryHTMLWithHeadwordString: (NSString*) requestString;
-(BOOL) getEntryHTMLWithID: (int) requestID;
@end
