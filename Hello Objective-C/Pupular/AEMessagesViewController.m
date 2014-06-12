//
//  AEMessagesViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//

#import "AEMessagesViewController.h"
#import "AEMenuViewController.h"
#import "AENewMessageViewController.h"
#import "AEActiveFriendsViewController.h"


@interface AEMessagesViewController ()

@end

@implementation AEMessagesViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        messagesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:3000/messages?dog_id=101"]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)menu:(id)sender{
    AEMenuViewController *menuView = [[AEMenuViewController alloc] init];
    [self presentViewController:menuView animated:NO completion:nil];
}

-(IBAction)newMessage:(id)sender{
    AENewMessageViewController *newMessage = [[AENewMessageViewController alloc] init];
    [self presentViewController:newMessage animated:YES completion:nil];
}

-(IBAction)list:(id)sender{
    AEActiveFriendsViewController *activeFriendsView = [[AEActiveFriendsViewController alloc] init];
    [self presentViewController:activeFriendsView animated:NO completion:nil];
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
    if([newJSON objectForKey:@"messages"])
    {
        for(int i = 0; i < [[newJSON objectForKey:@"messages"] count]; i++)
        {
        NSDictionary *messageObject = [newJSON objectForKey:@"messages"][i];
        [messagesArray addObject:messageObject];
        }
    }
    NSLog(@"MESASGAGDSAGSD %@",messagesArray);
    [self.tableView reloadData];

}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messagesArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    UITableViewCell *cell = (UITableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Display recipe in the table cell
    NSString *user = nil;
    NSDictionary *message = [messagesArray objectAtIndex:indexPath.row];
    
    //cell.thumbnailImageView.image = [UIImage imageNamed:recipe.image];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [message valueForKey:@"body"];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    return cell;
}





@end
