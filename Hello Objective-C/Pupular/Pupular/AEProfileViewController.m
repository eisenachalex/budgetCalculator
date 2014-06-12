//
//  AEProfileViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 5/29/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEProfileViewController.h"
#import "AEMenuViewController.h"

@interface AEProfileViewController ()

@end

@implementation AEProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3000/profile?dog_id=100"]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
}- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    [self presentViewController:menuView animated:NO completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                              error:nil];
    NSLog(@"JSON %@",[newJSON objectForKey:@"profile"]);
    if([newJSON objectForKey:@"profile"])
    {
        profile = [newJSON objectForKey:@"profile"];
        self.location.text = [NSString stringWithFormat:@"Location: %@",[profile valueForKey:@"location"]];
        self.personality.text = [NSString stringWithFormat:@"Personality: %@",[profile valueForKey:@"personality_type"]];
        self.gender.text = [NSString stringWithFormat:@"Gender: %@",[profile valueForKey:@"gender"]];
        self.age.text = [NSString stringWithFormat:@"Age: %@",[profile valueForKey:@"age"]];
        self.owners_name.text = [NSString stringWithFormat:@"Owner's name: %@",[profile valueForKey:@"humans_name"]];
        self.breed.text = [NSString stringWithFormat:@"Breed: %@",[profile valueForKey:@"breed"]];
        self.size.text = [NSString stringWithFormat:@"Size: %@",[profile valueForKey:@"size"]];
        
          }
  
    
}





@end
