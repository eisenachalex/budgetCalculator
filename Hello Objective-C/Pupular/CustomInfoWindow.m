//
//  CustomInfoWindow.m
//  Pupular
//
//  Created by Alex Eisenach on 8/25/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "CustomInfoWindow.h"

@implementation CustomInfoWindow

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
    
    
    
}

-(IBAction)message:(id)sender {
    NSLog(@"hey world");
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
