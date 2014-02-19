//
//  main.m
//  experiments
//
//  Created by Alex Eisenach on 12/19/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cow : NSObject

@property(nonatomic, assign) NSString *name;
@property (nonatomic, assign) NSString *sound;
    

-(NSString *)makeSound;

@end


@implementation Cow


-(NSString *)makeSound {
    self.sound = @"Moo";
    NSLog(@"This is the sound I make...%@", self.sound);
}

@end



int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        Cow *cow = [[Cow alloc] init];
        [cow makeSound];
        
    }
    return 0;
}

