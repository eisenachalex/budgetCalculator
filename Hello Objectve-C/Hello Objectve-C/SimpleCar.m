//
//  SimpleCar.m
//  Hello Objectve-C
//
//  Created by Alex Eisenach on 12/17/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import "SimpleCar.h"

@implementation SimpleCar
@synthesize make, model, vin;
- (void) setMake: (NSString*)newMake
        andModel: (NSString*)newModel {
    [self setMake:newMake];
    [self setModel:newModel];
}
@end