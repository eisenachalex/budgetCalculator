//
//  AEIncomeViewController.m
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/3/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import "AEIncomeViewController.h"
#import "AEAddItemViewController.h"
@interface AEIncomeViewController ()
@property NSMutableArray *expenses;
@property NSMutableArray *items;
@property NSMutableArray *income;
@end

@implementation AEIncomeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        self.title = @"Income";
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"income.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"notincome.png"]];
        [self loadItems];
        [self getItems];
    }
    return self;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    
}

-(void)controller:(AEAddItemViewController *)controller didSaveItemWithName:(NSString *)name andPrice:(float)price
{
    NSLog(@"its happening");
    [self loadItems];
    NSNumber *finalPrice = [NSNumber numberWithFloat:price];
    NSMutableDictionary *dictionaryItem = [[NSMutableDictionary alloc] init];
    dictionaryItem[@"description"] = name;
    dictionaryItem[@"price"] = finalPrice;
    dictionaryItem[@"type"] = @"Income";
    NSMutableArray *newExpense = [[NSMutableArray alloc] init];
    [newExpense addObject:dictionaryItem];
    [self.expenses addObject:newExpense];
    [self getItems];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.items count] - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.expenses writeToFile:[self pathForItems] atomically:YES];
    NSLog(@"break");
    [self.tableView reloadData];
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.LeftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editItems:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addItem:(id)sender {
    // Initialize Add Item View Controller
    AEQuickAddViewController *quickAddViewController = [[AEQuickAddViewController alloc] initWithNibName:@"AEQuickAddViewController" bundle:nil];
    // Present View Controller
    [quickAddViewController setDelegate:self];
    
    [self presentViewController:quickAddViewController animated:YES completion:nil];
}

- (void)editItems:(id)sender {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    
}

- (void)loadItems {
    NSString *filePath = [self pathForItems];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.expenses = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.expenses = [NSMutableArray array];
    }
}

-(void)getItems {
    NSMutableArray *incomes = [[NSMutableArray alloc] init];
    for (int i=0; i< [self.expenses count]; i++){
        NSDictionary *dictionary = [self.expenses objectAtIndex:i];
        NSArray *arrayOfValues = [dictionary valueForKey:@"type"];
        NSString *value = [arrayOfValues objectAtIndex:0];
        NSString *income = @"Income";
        if([value isEqualToString:income] == 1){
            [incomes addObject:dictionary];
        }
    }
    self.items = incomes;
    
}


- (NSString *)pathForItems {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"expenses.plist"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Fetch Item
    NSDictionary *expenseDict = [self.items objectAtIndex:[indexPath row]];
    NSLog(@"whoo");
    for(int i = 0; i < [[cell.textLabel subviews] count]; i++){
        NSLog(@"here it is %@",[[cell.textLabel subviews] objectAtIndex:i]);
        UIView *currentView = [[cell.textLabel subviews] objectAtIndex:i];
        if([currentView isKindOfClass:[UILabel class]]){
            [currentView removeFromSuperview];
        }
    }
    NSLog(@"%@",expenseDict);
    NSArray *arrayOfValues = [expenseDict valueForKey:@"description"];
    NSArray *arrayOfPrices = [expenseDict valueForKey:@"price"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";
    NSString *expense = [arrayOfValues objectAtIndex:0];
    NSNumber *expensePrice = [arrayOfPrices objectAtIndex:0];
    NSString *numberString = [NSString stringWithFormat:@"$%.02f",[expensePrice floatValue]];
    CGRect expenseFrame = CGRectMake(10.0, 0.0, 280, 50);
    UILabel *subLabel = [[UILabel alloc] initWithFrame:expenseFrame];
    subLabel.textColor = [UIColor greenColor];
    NSString *formattedAmount = [formatter stringFromNumber:expensePrice];
    subLabel.text = [NSString stringWithFormat:@"%@",formattedAmount];    subLabel.textAlignment = NSTextAlignmentRight;
    //    // Configure Cell
    [cell.textLabel addSubview:subLabel];
    [cell.textLabel setText:expense];
                      
    return cell;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // your stuff goes here...
    [self loadItems];
    [self getItems];
    [self.tableView reloadData];
    
}


 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {

    
     return YES;
 }

-(void)itemsToExpenses:(NSDictionary *)deleteThis {
    [self loadItems];
    for (int i=0; i< [self.expenses count]; i++){
        NSArray *array = [self.expenses objectAtIndex:i];
//        NSLog(@"%@",deleteThis);
        NSDictionary *dictionary = [array objectAtIndex:0];
        NSLog(@"%@",dictionary);

        if([dictionary isEqual:deleteThis]){
            [self.expenses removeObjectAtIndex:i];
        }
        
    }
    [self.expenses writeToFile:[self pathForItems] atomically:YES];

//
}


 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
//         // Delete Item from Items'
         NSDictionary *dictionary = [[self.items objectAtIndex:[indexPath row]] objectAtIndex:0];
         [self itemsToExpenses:dictionary];

     [self.items removeObjectAtIndex:[indexPath row]];
         NSLog(@"nope");

//
//         // Update Table View
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];

//         // Save Changes to Disk
         [self loadItems];
         [self getItems];
     }
 }

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end