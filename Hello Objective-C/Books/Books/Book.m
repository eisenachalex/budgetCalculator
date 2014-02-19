//
//  Book.m
//  Books
//
//  Created by Alex Eisenach on 12/17/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import "Book.h"

@implementation Book

    - (NSString *)bookInfo {
        NSString *bookInfo = [NSString stringWithFormat:@"%@ was written by %@ and published in %i", self.title, self.author,self.year];
        return bookInfo;
    }


@end
