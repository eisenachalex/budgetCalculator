//
//  Book.h
//  Books
//
//  Created by Alex Eisenach on 12/17/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject
@property int year;
@property NSString *title;
@property NSString *author;
- (NSString *)bookInfo;

@end
