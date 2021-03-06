//
//  TLGradientView.m
//  Created by Jonathan Dann and on 20/10/2008.
//  Copyright (c) 2008, espresso served here.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this list
//  of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice, this list
//  of conditions and the following disclaimer in the documentation and/or other materials
//  provided with the distribution.
//
//  Neither the name of the espresso served here nor the names of its contributors may be
//  used to endorse or promote products derived from this software without specific prior
//  written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS
//  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
//  AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
//  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains code from "TLAnimatingOutlineView" by Jonathan Dann http://code.google.com/p/tlanimatingoutlineview/" will do.

#import "TLGradientView.h"

@interface TLGradientView ()

@end

@interface TLGradientView (Private)
- (void)windowDidChangeFocus:(NSNotification *)notification;
@end

@implementation TLGradientView (Private)

- (void)windowDidChangeFocus:(NSNotification *)notification {
    [self setNeedsDisplay:YES];
}

@end

@implementation TLGradientView

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeFocus:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeFocus:) name:NSApplicationDidResignActiveNotification object:NSApp];
    }
    
    return self;
}

- (id)initWithFrame:(NSRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        self.activeFillGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.916 alpha:1.0],[NSColor colorWithCalibratedWhite:0.814 alpha:1.0],nil]] tl_autorelease];
        self.inactiveFillGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.916 alpha:1.0],[NSColor colorWithCalibratedWhite:0.916 alpha:1.0],nil]] tl_autorelease];
        self.clickedFillGradient = [[[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:[NSColor colorWithCalibratedWhite:0.916 alpha:1.0],[NSColor colorWithCalibratedWhite:0.814 alpha:1.0],nil]] tl_autorelease];
        self.fillOption = TLGradientViewActiveGradient;
        self.fillAngle = 270.0;
        
        self.borderColor = [NSColor lightGrayColor];
        self.borderSidesMask = (TLMinXEdge|TLMaxXEdge|TLMinYEdge|TLMaxYEdge);
        
        self.highlightColor = [NSColor colorWithCalibratedWhite:0.97 alpha:1.0];
    }
    
    return self;
}

- (NSArray *)keysForCoding {
    return [NSArray arrayWithObjects:nil];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        for (NSString *key in [self keysForCoding])
            [coder encodeObject:[self valueForKey:key] forKey:key];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    for (NSString *key in [self keysForCoding])
        [self setValue:[coder decodeObjectForKey:key] forKey:key];
    [super encodeWithCoder:coder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_activeFillGradient tl_release];
    [_inactiveFillGradient tl_release];
    [_clickedFillGradient tl_release];
    [_borderColor tl_release];
    [_highlightColor tl_release];
    TL_SUPER_DEALLOC();
}

- (void)viewWillMoveToSuperview:(NSView *)superview {
    [super viewWillMoveToSuperview:superview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:[self window]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:[self window]];
    
    if (!superview) return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeFocus:) name:NSWindowDidResignMainNotification object:[superview window]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidChangeFocus:) name:NSWindowDidBecomeMainNotification object:[superview window]];
}

- (void)setBorderSidesMask:(TLRectEdge)mask {
    _borderSidesMask = mask;
    [self setNeedsDisplay:YES];
}

- (void)setClickedFillGradient:(NSGradient *)gradient {
    if (_clickedFillGradient == gradient)
        return;
    [gradient tl_retain];
    [_clickedFillGradient tl_release];
    _clickedFillGradient = gradient;
    [self setNeedsDisplay:YES];
}

- (void)setActiveFillGradient:(NSGradient *)gradient {
    if (_activeFillGradient == gradient)
        return;
    [gradient tl_retain];
    [_activeFillGradient tl_release];
    _activeFillGradient = gradient;
    [self setNeedsDisplay:YES];
}

- (void)setInactiveFillGradient:(NSGradient *)gradient {
    if (_inactiveFillGradient == gradient)
        return;
    [gradient tl_retain];
    [_inactiveFillGradient tl_release];
    _inactiveFillGradient = gradient;
    [self setNeedsDisplay:YES];
}

- (void)setFillOption:(TLGradientViewFillOption)options {
    _fillOption = options;
    [self setNeedsDisplay:YES];
}

- (void)setFillAngle:(CGFloat)angle {
    _fillAngle = angle;
    [self setNeedsDisplay:YES];
}

- (void)setDrawsHighlight:(BOOL)flag {
    if (_drawsHighlight == flag)
        return;
    _drawsHighlight = flag;
    [self setNeedsDisplay:YES];
}

- (void)setDrawsBorder:(BOOL)flag {
    if (_drawsBorder == flag)
        return;
    _drawsBorder = flag;
    [self setNeedsDisplay:YES];
}

- (void)setBorderColor:(NSColor *)color {
    if (_borderColor == color)
        return;
    [color tl_retain];    
    [_borderColor tl_release];
    _borderColor = color;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
    NSGradient *fillGradient = nil;
    if (self.fillOption != TLGradientViewClickedGradient)
        fillGradient = [[self window] isKeyWindow] || [[self window] isMainWindow] ? self.activeFillGradient : self.inactiveFillGradient;
    else
        fillGradient = self.clickedFillGradient;
    
    [fillGradient drawInRect:[self bounds] angle:self.fillAngle];
    
    if (self.drawsBorder) {
        [self.borderColor setStroke];
        NSBezierPath *border = [NSBezierPath bezierPath];
        NSRect bounds = [self bounds];
        if (self.borderSidesMask & TLMinXEdge)
            [border appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(NSMinX(bounds) + 0.5, NSMinY(bounds), 0.0, NSHeight(bounds))]];
        if (self.borderSidesMask & TLMaxXEdge)
            [border appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(NSMaxX(bounds) - 0.5, NSMinY(bounds), 0.0, NSHeight(bounds))]];
        if (self.borderSidesMask & TLMinYEdge)
            [border appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(NSMinX(bounds), NSMinY(bounds) + 0.5, NSWidth(bounds), 0.0)]];
        if (self.borderSidesMask & TLMaxYEdge)
            [border appendBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(NSMinX(bounds), NSMaxY(bounds) - 0.5, NSWidth(bounds), 0.0)]];
        [border stroke];
    }
    
    if (self.drawsHighlight) {
        [self.highlightColor setStroke];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(NSMinX([self bounds]), [self isFlipped] ? NSMinY([self bounds]) + (self.borderSidesMask & TLMinYEdge ? 1.5 : 0.5) : NSMaxY([self bounds]) - (self.borderSidesMask & TLMaxYEdge ? 1.5 : 0.5), NSWidth([self bounds]), 0.0)] stroke];
    }
}

@end
