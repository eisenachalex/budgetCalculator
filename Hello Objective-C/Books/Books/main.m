//
//  main.m
//  Books
//
//  Created by Alex Eisenach on 12/17/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        NSLog(@"Hello, World!");
        Book *book1 = [[Book alloc] init];
        book1.title = @"The Hobbit";
        book1.author = @"JRR Tolkien";
        book1.year = 1937;
        
        Book *book2 = [[Book alloc] init];
        [book2 setTitle:@"The Fellowship of the Ring"];
        [book2 setAuthor: @"JRR Tolkien"];
        [book2 setYear: 1954];
        NSArray *books = [[NSArray alloc] initWithObjects:book1,book2,nil];
        
        if([books count] > 0 ) {
            for (int i = 0; i < [books count]; i++) {
                Book *aBook = [books objectAtIndex:i];
                NSLog(@"%@", [aBook bookInfo]);
            }
        }
    }
    
    return 0;
}

