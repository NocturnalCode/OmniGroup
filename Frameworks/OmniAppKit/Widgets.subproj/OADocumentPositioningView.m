// Copyright 2002-2005, 2010-2011 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.

#import "OADocumentPositioningView.h"

#import <Cocoa/Cocoa.h>
#import <OmniBase/OmniBase.h>
#import "OAZoomableViewProtocol.h"

RCS_ID("$Id$");


@interface OADocumentPositioningView (/*Private*/)
- (void)_documentViewFrameChangedNotification:(NSNotification *)notification;
- (void)_positionDocumentView;
- (BOOL)_setDocumentView:(NSView *)value;
@end


@implementation OADocumentPositioningView

- (id)initWithFrame:(NSRect)frame;
{
    if (!(self = [super initWithFrame:frame]))
        return nil;

    [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    documentViewAlignment = NSImageAlignCenter;

    return self;
}

- (void)dealloc;
{
    [self _setDocumentView:nil];
    [super dealloc];
}

// API

- (NSView *)documentView;
{
    return documentView;
}

- (void)setDocumentView:(NSView *)value;
{
    if ([self _setDocumentView:value])
        [self _positionDocumentView];
}

- (NSImageAlignment)documentViewAlignment;
{
    return documentViewAlignment;
}

- (void)setDocumentViewAlignment:(NSImageAlignment)value;
{
    documentViewAlignment = value;
    [self _positionDocumentView];
}

#pragma mark -
#pragma mark NSView subclass

- (void)resizeSubviewsWithOldSize:(NSSize)oldFrameSize;
{
    [super resizeSubviewsWithOldSize:oldFrameSize];
    [self _positionDocumentView];
}


#pragma mark -
#pragma mark Private

- (void)_documentViewFrameChangedNotification:(NSNotification *)notification;
{
    [self _positionDocumentView];
    [self setNeedsDisplay:YES];	// we don't know what the old frame was, so we hav to be pessimistic about how much of us needs redisplay
}

- (void)_positionDocumentView;
{
    NSView *superview;
    NSSize contentSize;
    NSRect oldDocumentFrame;
    NSRect oldFrame;
    NSRect newFrame;
    
    superview = [self superview];
    //NSLog(@"94: superView = %@",[superview className]);
    if (superview == nil)
        return;
    contentSize = [superview bounds].size;
    //NSLog(@"98: contentSize = %@ ContentRect = %@ DocumentVisibleRect = %@", NSStringFromSize(contentSize),NSStringFromRect([superview bounds]), [superview isKindOfClass:[NSClipView class]] ? NSStringFromRect([(NSClipView*)superview documentVisibleRect]) : @"N/A");
    if (documentView != nil)
        oldDocumentFrame = [documentView frame];
    else
        oldDocumentFrame = NSZeroRect;
    //NSLog(@"100: oldDocumentFrame = %@", NSStringFromRect(oldDocumentFrame));
    // ensure that our size is the greater of the scroll view's content size (visible content area) and our document view's size
    oldFrame = [self frame];
    //NSLog(@"106: oldFrame = %@", NSStringFromRect(oldFrame));
    newFrame = oldFrame;
    newFrame.size.width = MAX(oldDocumentFrame.size.width, contentSize.width);
    newFrame.size.height = MAX(oldDocumentFrame.size.height, contentSize.height);
    //NSLog(@"110: newFrame = %@", NSStringFromRect(newFrame));
//    NSRect oldFrameInt = NSIntegralRect(oldFrame);
//    NSRect newFrameInt = NSIntegralRect(newFrame);
    //At this point we have everything we need to know where to move the content view
//    if (!NSEqualRects(oldFrameInt, newFrameInt) && [superview isKindOfClass:[NSClipView class]]) {
//        NSRect documentVisibleRect = [(NSClipView*)superview documentVisibleRect];
//        NSClipView *superClipView = (NSClipView*)superview;
//        //Then there has been a zoom in or out
//        //if (NSContainsRect(oldFrameInt, newFrameInt)) {
//            //then the new frame is a zoomed in version
//            //need the center point in a percentagewise fashion of the old document
//            NSPoint center;
//            center.x = (NSMidX(documentVisibleRect) / oldFrameInt.size.width) * newFrameInt.size.width;
//            center.y = (NSMidY(documentVisibleRect) / oldFrameInt.size.height) * newFrameInt.size.height;
//            
//            NSPoint newVisibleOrigin = NSMakePoint(center.x - (documentVisibleRect.size.width*0.5), center.y - (documentVisibleRect.size.height*0.5));
//            [superClipView scrollToPoint:newVisibleOrigin];
//            
//        //}
//        //else
//        {
//            //the frame has zoomed out
//        }
//        
//        
//    }
    
    if (!NSEqualRects(newFrame, oldFrame)) {
        //NSLog(@"112: Frames are not Equal - Redrawing the Union:%@",NSStringFromRect(NSUnionRect(oldFrame, newFrame) ));
        [self setFrame:newFrame];
        [[self superview] setNeedsDisplayInRect:NSUnionRect(oldFrame, newFrame)];
    }
    
    if (documentView != nil) {
        //NSLog(@"118: Document View !=nil");
        NSRect newDocumentFrame;
        
        newDocumentFrame = oldDocumentFrame;
        
        // calculate our desired frame, given the document view alignment setting
        switch (documentViewAlignment) {
            case NSImageAlignCenter:
                newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width) / 2.0f;
                newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height) / 2.0f;
                //NSLog(@"126: Image align Center: %@", NSStringFromRect(newDocumentFrame));
                break;
            
            case NSImageAlignTop:
                newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width) / 2.0f;
                newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height);
                //NSLog(@"132: Image align Top: %@", NSStringFromRect(newDocumentFrame));
                break;
            
            case NSImageAlignTopLeft:
                newDocumentFrame.origin.x = 0.0f;
                newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height);
                //NSLog(@"138: Image align Top Left: %@", NSStringFromRect(newDocumentFrame));
                break;
            
            case NSImageAlignTopRight:
                newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width);
                newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height);
                //NSLog(@"144: Image align Top Right: %@", NSStringFromRect(newDocumentFrame));
                break;
            
            case NSImageAlignLeft:
                newDocumentFrame.origin.x = 0.0f;
                newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height) / 2.0f;
                //NSLog(@"150: Image align Left: %@", NSStringFromRect(newDocumentFrame));
                break;
            
            case NSImageAlignBottom:
                newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width) / 2.0f;
                newDocumentFrame.origin.y = 0.0f;
                //NSLog(@"156: Image align Bottom: %@", NSStringFromRect(newDocumentFrame));
                break;
            
            case NSImageAlignBottomLeft:
                newDocumentFrame.origin.x = 0.0f;
                newDocumentFrame.origin.y = 0.0f;
                //NSLog(@"162: Image align Bottom Left: %@", NSStringFromRect(newDocumentFrame));
                break;
            
            case NSImageAlignBottomRight:
                newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width);
                newDocumentFrame.origin.y = 0.0f;
                //NSLog(@"168: Image align Bottom Right: %@", NSStringFromRect(newDocumentFrame));
                break;
            
            case NSImageAlignRight:
                newDocumentFrame.origin.x = (newFrame.size.width - newDocumentFrame.size.width);
                newDocumentFrame.origin.y = (newFrame.size.height - newDocumentFrame.size.height) / 2.0f;
                //NSLog(@"174: Image align Right: %@", NSStringFromRect(newDocumentFrame));
                break;
                
            default:
                OBASSERT_NOT_REACHED("Unknown alignment value in documentViewAlignment");
                break;
        }
        
        // keep the frame on integral boundaries
        newDocumentFrame.origin.x = (CGFloat)floor(newDocumentFrame.origin.x);
        newDocumentFrame.origin.y = (CGFloat)floor(newDocumentFrame.origin.y);
        //NSLog(@"187: Integral newdocumentFrame: %@", NSStringFromRect(newDocumentFrame));
//        NSScrollView *scrollView = [self enclosingScrollView];
//        if (scrollView) {
//            CGFloat xVal = [[scrollView horizontalScroller] floatValue];
//            CGFloat yVal = [[scrollView verticalScroller] floatValue];
//            
//            CGFloat xDest = ABS(xVal*(scrollView.contentView.frame.size.width - [(NSView*)scrollView.documentView frame ].size.width));
//            CGFloat yDest = ABS(-1.0*yVal*(scrollView.contentView.frame.size.height - [(NSView*)scrollView.documentView frame ].size.height));
//            [scrollView.contentView scrollPoint:NSMakePoint(xDest, yDest)];
//        }
        // if the frame has actually changed, set the new frame and mark the appropriate area as needing to be displayed
        if (!NSEqualPoints(newDocumentFrame.origin, oldDocumentFrame.origin)) {
            //NSLog(@"199: new and old origins not Equal %@ : %@ respectively", NSStringFromRect(newDocumentFrame), NSStringFromRect(oldDocumentFrame));
            [documentView setFrameOrigin:newDocumentFrame.origin];
            [self setNeedsDisplayInRect:NSUnionRect(oldDocumentFrame, newDocumentFrame)];
        }
    }
    
    //NSLog(@"\n");
    
}

- (void)zoomTo:(CGFloat)zoom
{
    if ([documentView conformsToProtocol:@protocol(OAZoomableView)]) {
        [(id<OAZoomableView>)documentView zoomTo:zoom];
    }
    
}

- (BOOL)_setDocumentView:(NSView *)value;
{
    if (documentView == value)
        return NO;

    if (documentView != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self  name:NSViewFrameDidChangeNotification object:documentView];
        [documentView removeFromSuperview];
        [documentView release];
        documentView = nil;
    }

    if (value != nil) {
        documentView = [value retain];
        [self addSubview:documentView];
        [documentView setAutoresizingMask:NSViewNotSizable];	// so we will be told when our superview changes size, which might impact our frame
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_documentViewFrameChangedNotification:) name:NSViewFrameDidChangeNotification object:documentView];	// so we know when the document view changes size, which might impact our frame and/or the document view's position, and may mean we need to redisplay regardless
    }

    return YES;
}

@end
