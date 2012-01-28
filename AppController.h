/* AppController */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "LSLookup.h"


@interface AppController : NSObject
{
    IBOutlet id lookupTextField;
    IBOutlet id mainWebView;
	IBOutlet id statusText;
	IBOutlet id previousButton;
	IBOutlet id nextButton;
	
	LSLookup* LSLookupObj;
}
- (IBAction)lookupHeadword:(id)sender;
- (IBAction)lookupNextHeadword:(id)sender;
- (IBAction)lookupPreviousHeadword:(id)sender;
- (IBAction)showStartScreen:(id)sender;

- (void) awakeFromNib;
- (void) updateMainWebViewWithHTML: (NSString*)input;
@end
