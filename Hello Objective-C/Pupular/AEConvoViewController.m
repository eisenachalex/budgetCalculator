//
//  AEConvoViewController.m
//  Pupular
//
//  Created by Alex Eisenach on 6/7/14.
//  Copyright (c) 2014 Free Swim. All rights reserved.
//
#define SCROLLVIEW_CONTENT_WIDTH  320
#import "AEConvoViewController.h"
#import "AEMenuViewController.h"
#import "AEActiveFriendsViewController.h"
#import "UIImageView+WebCache.h"
#import "AEMessagesViewController.h"



@interface AEConvoViewController ()

@end

@implementation AEConvoViewController
@synthesize tableView,scrollView,toolBar,navTitle,senderImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.senderImage = [UIImage imageNamed:@"filler_icon.png"];
        messagesArray = [[NSMutableArray alloc]init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadUserInfo];
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/conversation?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    // Do any additional setup after loading the view from its nib.
    self.messageResponse.delegate = self;
    _senderImageView.clipsToBounds = YES;
    _senderImageView.layer.cornerRadius = 30;
    _senderImageView.image = senderImage;


}

-(void)viewWillAppear:(BOOL)animated  {
    navTitle.title = self.dogHandle;
    scrollView.contentSize = CGSizeMake(320, 500);
    [super viewWillAppear:YES];
    [tableView reloadData];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.view bringSubviewToFront:scrollView];
    CGPoint bottomOffset = CGPointMake(0, tableView.contentSize.height - tableView.bounds.size.height);
    [scrollView setContentOffset:CGPointMake(0,self.toolBar.center.y-270) animated:NO];//you can set your  y cordinate as your req also
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view bringSubviewToFront:tableView];
    [textField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
    
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)cancel:(id)sender {
    if(_backToMenu){
        NSLog(@"get it");
        AEMessagesViewController *messagesView = [[AEMessagesViewController alloc] init];
        messagesView.locationController = _locationController;
        [self presentViewController:messagesView animated:NO completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:NO completion:nil];

    }
}

-(IBAction)sendMessage:(id)sender{

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/new_message?sender_id=%@&receiver_id=%@&message_type=message&body=%@",[userInfo valueForKey:@"dog_id"],_dogID,[self.messageResponse.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    NSURLRequest *db_request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vast-inlet-7785.herokuapp.com/conversation?dog_id=%@&friend_id=%@",[userInfo valueForKey:@"dog_id"],_dogID]]];
    NSURLConnection *db_conn = [[NSURLConnection alloc] initWithRequest:db_request delegate:self];
    
    [self.messageResponse resignFirstResponder];
    [self.messageResponse setText:@""];
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary *newJSON = [NSJSONSerialization JSONObjectWithData:_responseData
                                                            options:0
                                                            error:nil];
    
    if([newJSON objectForKey:@"total_convo"])
    {
        messagesArray = [[NSMutableArray alloc] init];

        for(int i = 0; i < [[newJSON objectForKey:@"total_convo"] count]; i++)
        {
            NSDictionary *messageObject = [newJSON objectForKey:@"total_convo"][i];
            [messagesArray addObject:messageObject];
        }

    }
    

    NSLog(@"MESASGAGDSAGSD %@",messagesArray);
    [self.tableView reloadData];
    [self.view bringSubviewToFront:tableView];

    if([messagesArray count] != 0){
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: [messagesArray count]-1 inSection: 1-1];
        [tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellText = @"Go get some text for your cell.";
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    return labelSize.height + 40;}

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
    cell.imageView.image = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [message valueForKey:@"body"];
    [cell.textLabel setFont:[UIFont fontWithName:@"Arial" size:15]];
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
    NSString *message_id = [message valueForKey:@"sender_id"];
    NSLog(@"message id %@",message_id);
    NSLog(@"and dog... id %@", [userInfo valueForKey:@"dog_id"]);

    if([message_id intValue] == [[userInfo valueForKey:@"dog_id"] intValue] )
    {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
    }
    else {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.imageView.image = self.senderImage;
    }
    cell.imageView.clipsToBounds = YES;
    cell.imageView.layer.cornerRadius = 25;
    return cell;
    
}

- (void)loadUserInfo {
    NSString *filePath = [self pathForUserInfo];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
        
    } else {
        userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setValue:@"empty" forKey:@"email"];
    }
    
}

- (NSString *)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    NSLog(@"path %@",paths);
    return [documents stringByAppendingPathComponent:@"userInfo.plist"];
}


@end
