#import "AppController.h"

@implementation AppController

- (void) awakeFromNib
{
	NSLog(@"Awoke from Nib, setting up interface...");
	[self showStartScreen:nil];
	//Clear the status
	[statusText setStringValue:@""];
}

- (void) updateMainWebViewWithHTML: (NSString*)input
{
	[[mainWebView mainFrame] loadHTMLString:input baseURL:nil];
}

- (IBAction)lookupHeadword:(id)sender
{
	NSString* searchWord = [lookupTextField stringValue];
	NSLog(@"Time to lookup %@", searchWord);
	
	if( [LSLookupObj getEntryHTMLWithHeadwordString:searchWord] ){
		[self updateMainWebViewWithHTML:[LSLookupObj HTMLData]];
		NSString* statusString = @"1 entry found.";
		if([LSLookupObj totalEntries] > 1)
			statusString = [NSString stringWithFormat:@"%d entries found.",[LSLookupObj totalEntries]];
		[statusText setStringValue:statusString];
	}else{
		[self updateMainWebViewWithHTML:
			[NSString stringWithFormat:@"<em>%@</em> was not found.", [lookupTextField stringValue]]];
		[statusText setStringValue:@""];
	}
}

- (IBAction)lookupNextHeadword:(id)sender
{
	int nextID = [LSLookupObj currentEntryID] + 1;
	if( [LSLookupObj getEntryHTMLWithID:nextID] ){
		[self updateMainWebViewWithHTML:[LSLookupObj HTMLData]];
		[statusText setStringValue:@""];	
	}else{	//the rare chance that we've gone too high
		[self showStartScreen:nil];
	}
}

- (IBAction)lookupPreviousHeadword:(id)sender
{
	int prevID = [LSLookupObj currentEntryID] - 1;
	if( [LSLookupObj getEntryHTMLWithID:prevID] ){
		[self updateMainWebViewWithHTML:[LSLookupObj HTMLData]];
		[statusText setStringValue:@""];	
	}else{	//the rare chance that we've gone too low
		[self showStartScreen:nil];
	}
}

- (IBAction)showStartScreen:(id)sender{
	NSURLRequest* htmlFile = [NSURLRequest requestWithURL:
		[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"start" ofType:@"html"]]];
	[[mainWebView mainFrame] loadRequest:htmlFile];
	
	[statusText setStringValue:@""];
}

//This ensures that all links clicked are opened in the system default browser
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
	request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
	NSLog(@"Delagate called to open URL: %@", [[request URL] absoluteString]);
	if([[request URL] host]){
		[listener ignore];
		[[NSWorkspace sharedWorkspace] openURL: [request URL]];
	}else{
		[listener use];
	}
}

//init and dealloc
- (id) init
{
    if ( self = [super init] )
    {
		NSLog(@"Initializing %@", [self description]);
		LSLookupObj = [[LSLookup alloc] init];
		return self;
	}
    return 0;
}

//Hurray for no memory leaks!
- (void) dealloc
{
	[LSLookupObj release];
    [super dealloc];
}

@end
