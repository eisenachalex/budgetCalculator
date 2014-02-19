//
//  SimpleCar.h
//  Hello Objectve-C
//
//  Created by Alex Eisenach on 12/17/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleCar : NSObject {
    NSString* make;
    NSString* model;
    NSNumber* vin;
}

@property(readwrite, retain) NSString* make;
@property(readwrite,retain) NSString* model;
@property(readwrite, retain) NSNumber* vin;
-(void) setMake: (NSString*)newMake
       andModel: (NSString*)newModel;

@end

