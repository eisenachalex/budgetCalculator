//
//  AEItem.h
//  Shopping List
//
//  Created by Alex Eisenach on 12/21/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AEItem : NSObject <NSCoding>
@property NSString *uuid;
@property NSString *name;
@property float price;
@property BOOL inShoppingList;
+ (AEItem *)createItemWithName:(NSString *)name andPrice:(float)price;

@end
