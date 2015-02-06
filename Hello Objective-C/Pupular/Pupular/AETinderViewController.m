//
//  AETinderViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 10/28/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AETinderViewController.h"
#import "AEAppDelegate.h"
#import "UIImageView+WebCache.h"


@interface AETinderViewController ()

@end

@implementation AETinderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 80;
    [self.imageView.layer setBorderColor: [[UIColor groupTableViewBackgroundColor] CGColor]];
    [self.imageView.layer setBorderWidth: 3.0];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    AEAppDelegate *appDelegate = (AEAppDelegate *)[[UIApplication sharedApplication] delegate];
    _allDogs = appDelegate.allDogs;
    NSString *dogID = _dogID;
    _dog = [_allDogs objectForKey:[NSString stringWithFormat:@"%@",dogID]];
    [self buildProfile];
}

-(void)buildProfile{
    NSString *returnString = [[NSString alloc] init];
    returnString = [NSString stringWithFormat:@"Hi, my name is %@!", [_dog valueForKey:@"handle"]];
    NSDictionary *dog = [_dog valueForKey:@"profile"];
    if((([NSNull null] != [dog objectForKey:@"age"]) && (![[dog objectForKey:@"age"] isEqualToNumber:[NSNumber numberWithInt:0]])) || (([NSNull null] != [dog objectForKey:@"gender"]) && (![[dog valueForKey:@"gender"] isEqualToString:@""]) && (![[dog valueForKey:@"gender"] isEqualToString:@"(null)"])) || (([NSNull null] != [dog objectForKey:@"breed"]) && (![[dog valueForKey:@"breed"] isEqualToString:@"(null)"]) && (![[dog valueForKey:@"breed"] isEqualToString:@""]))){
        returnString = [NSString stringWithFormat:@"%@ I'm a", returnString];
    }
    
    
    if(([NSNull null] != [dog objectForKey:@"age"]) && (![[dog objectForKey:@"age"] isEqualToNumber:[NSNumber numberWithInt:0]]) ){
        returnString = [NSString stringWithFormat:@"%@ %@ year old",returnString,[dog valueForKey:@"age"]];
    }
    if([NSNull null] != [dog objectForKey:@"gender"]){
        if(![[dog valueForKey:@"gender"] isEqualToString:@""]){
            
            returnString = [NSString stringWithFormat:@"%@ %@",returnString, [dog valueForKey:@"gender"]];
        }
    }
    if([NSNull null] != [dog objectForKey:@"breed"]){
        if(![[dog valueForKey:@"breed"] isEqualToString:@"(null)"]){
            returnString = [NSString stringWithFormat:@"%@ %@",returnString, [dog valueForKey:@"breed"]];
        }
    }
    if(![returnString hasSuffix:@"!"]){
        returnString = [NSString stringWithFormat:@"%@.",returnString];
    }
    if([NSNull null] != [dog objectForKey:@"fertility"]){
        if(![[dog valueForKey:@"fertility"] isEqualToString:@""]){
            returnString = [NSString stringWithFormat:@"%@  I'm %@",returnString,[dog valueForKey:@"fertility"]];
        }
    }
    if([NSNull null] != [dog objectForKey:@"size"]){
        if(![[dog valueForKey:@"size"] isEqualToString:@""]){
            
            returnString = [NSString stringWithFormat:@"%@ and %@",returnString, [dog valueForKey:@"size"]];
        }
    }
    
    if([NSNull null] != [dog objectForKey:@"personality_type"]){
        if(![[dog valueForKey:@"personality_type"] isEqualToString:@""]){
            if([returnString hasSuffix:@"."]){
                returnString = [NSString stringWithFormat:@"%@ My pup friends say that I'm %@",returnString, [dog valueForKey:@"personality_type"]];           }
            else{
                returnString = [NSString stringWithFormat:@"%@. My pup friends say that I'm %@",returnString, [dog valueForKey:@"personality_type"]];
            }
        }
        
    }
    
    
    if([NSNull null] != [dog objectForKey:@"humans_name"]){
        if(![[dog valueForKey:@"humans_name"] isEqualToString:@""]){
            
            if([returnString hasSuffix:@"."]){
                returnString = [NSString stringWithFormat:@"%@ My human best friend is %@",returnString, [dog objectForKey:@"humans_name"]];            }
            else{
                returnString = [NSString stringWithFormat:@"%@. My human best friend is %@",returnString, [dog objectForKey:@"humans_name"]];            }
            
        }
    }
    if([NSNull null] != [dog objectForKey:@"location"]){
        
    }
    NSString *imageURL = [_dog valueForKey:@"photo_list"][0];
    [self.imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:imageURL]]
                   placeholderImage:[UIImage imageNamed:@"pupulardog_dog_avatar.png"]];
    if([returnString hasSuffix:@"."] || [returnString hasSuffix:@"!"]){
        returnString = [NSString stringWithFormat:@"%@",returnString];
    }
    else{
        returnString = [NSString stringWithFormat:@"%@.",returnString];
    }
    _label.text = returnString;
}

-(IBAction)sendRequest:(id)sender {
    [self.delegate sendRequest];
}

-(IBAction)decline:(id)sender {
    [self.delegate decline];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
