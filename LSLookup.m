//
//  LSLookup.m
//  Verba
//
//  Created by Joshua Hayes on 7/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LSLookup.h"


@implementation LSLookup

//Private methods
//Setters for pointer vars (all of which are essentially private)
- (void) setXMLData: (NSString*)input
{
    [XMLData autorelease];
    XMLData = [input retain];
}

- (void) setHeadword: (NSString*)input
{
    [headword autorelease];
    headword = [input retain];
}

- (void) setHTMLData: (NSString*)input
{
    [HTMLData autorelease];
    HTMLData = [input retain];
}

//transforms the XML already loaded into our obj
//TODO - fix Greek text display
- (NSString*) transformXML{
	if([XMLData length] < 1){
		//something's wrong
		NSLog(@"Tried to tranformXML, but it's empty!");
		return @"There was an error; please retry your search.";
	}
	// find XSLT code
    NSString *xsltPath = [[NSBundle mainBundle]
		pathForResource:@"tei" ofType:@"xsl"];
	
	// transform through XSLT
	NSError *err=nil;
		//turn our XML string into a NSXMLDocument
	NSXMLDocument* XMLDataAsNSDoc = [[NSXMLDocument alloc]
		initWithXMLString:XMLData options:nil error:&err];

    NSData* entryData = [XMLDataAsNSDoc objectByApplyingXSLTAtURL:[NSURL fileURLWithPath:xsltPath]
		arguments:nil  // no extra XSLT parameters needed
        error:&err];
		
	[XMLDataAsNSDoc release];
	return [entryData description];
}

//Accessors
-(int) totalEntries{
	return totalEntries;
}

-(int) currentEntryID{
	return currentEntryID;
}

-(NSString*) headword{
	return headword;
}

-(NSString*) HTMLData{
	return HTMLData;
}

//Methods
-(BOOL) getEntryHTMLWithHeadwordString: (NSString*) requestString{
	//reset the totalEntries count etc.
	totalEntries = 0;
	currentEntryID = 0;
	
	//replace every j/J with i and every v with u
	NSMutableString* mutableString = [NSMutableString stringWithString:requestString];
	[mutableString replaceOccurrencesOfString:@"j"withString:@"i"
									  options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableString length])];
	[mutableString replaceOccurrencesOfString:@"v"withString:@"u"
									  options:nil range:NSMakeRange(0, [mutableString length])];
	
	//A LIKE query means not case sensitive; not noticeably slower for now.
    FMResultSet *rs =
		[db executeQuery:@"SELECT headwords.*,entries.entry FROM headwords,entries WHERE headwords.headword LIKE ? AND headwords.id = entries.id", mutableString];
    while ([rs next]) {
		//This is because I want to know how many rows returned,
		//but only the data from the first.
		if(currentEntryID == 0){
			currentEntryID = [rs intForColumn:@"id"];
			[self setHeadword:[rs stringForColumn:@"headword"]];
			[self setXMLData:[rs stringForColumn:@"entry"]];
		}
		totalEntries++;
    }
	// close the result set.
	[rs close];
	
	if(totalEntries > 0){
		//fill in the rest of my data
		[self setHTMLData:[self transformXML]];
		return YES;
	}else{
		NSString* notFound = [NSString stringWithFormat:@"<em>%@</em> was not found.", requestString];
		[self setHTMLData:notFound];
		return NO;
	}
}

-(BOOL) getEntryHTMLWithID: (int) requestID{
	NSLog(@"Get entry HTML with id = %d", requestID);
	FMResultSet *rs =
		[db executeQuery:@"SELECT headwords.*,entries.entry FROM headwords,entries WHERE headwords.id = ? AND headwords.id = entries.id LIMIT 1",
			[NSNumber numberWithInt:requestID]];
    if ([rs next]) {
		currentEntryID = [rs intForColumn:@"id"];
		[self setHeadword:[rs stringForColumn:@"headword"]];
		[self setXMLData:[rs stringForColumn:@"entry"]];
		
		[rs close];
		
		[self setHTMLData:[self transformXML]];
		return YES;
    }else{
		// close the result set.
		[rs close];
		
		//if we can't find it, then this must be set to 0
		currentEntryID = 0;
		totalEntries = 0;

		return NO;
	}
}

//init and dealloc
- (id) init
{
    if ( self = [super init] )
    {
		NSLog(@"Initializing %@", [self description]);
		totalEntries = 0;
		currentEntryID = 0;
		
		NSString* dbPath = [[NSBundle mainBundle]
        pathForResource:@"Lewis_Short" ofType:@"db"];
		db = [FMDatabase databaseWithPath:dbPath];
		if ([db open]) {
			NSLog(@"Successfully opened db: %@", [db description]);
		}else{
			NSLog(@"Error: could not open db!");
		}
		//keep this db connection around please
		[db retain];
    }
    return self;
}

//Hurray for no memory leaks!
- (void) dealloc
{
	[db close];
	[db release];
	
	[XMLData release];
	[headword release];
	[HTMLData release];
    [super dealloc];
}

@end
