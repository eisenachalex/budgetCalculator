//
//  AEItem.m
//  Shopping List
//
//  Created by Alex Eisenach on 12/21/13.
//  Copyright (c) 2013 Alex Eisenach. All rights reserved.
//

#import "AEItem.h"

@implementation AEItem

- (void)encodeWithCoder: (NSCoder *)coder {
    [coder encodeObject:self.uuid forKey:@"uuid"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeFloat:self.price forKey:@"price"];
    [coder encodeBool:self.inShoppingList forKey:@"inShoppingList"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        [self setUuid:[decoder decodeObjectForKey:@"uuid"]];
        [self setName:[decoder decodeObjectForKey:@"name"]];
        [self setPrice:[decoder decodeFloatForKey:@"price"]];
        [self setInShoppingList:[decoder decodeBoolForKey:@"inShoppingList"]];
    }
    return self;
}

+ (AEItem *)createItemWithName:(NSString *)name andPrice:(float)price {
    AEItem *item = [[AEItem alloc] init];
    [item setName:name];
    [item setPrice:price];
    [item setInShoppingList:NO];
    [item setUuid:[[NSUUID UUID] UUIDString]];
    return item;
}

@end
