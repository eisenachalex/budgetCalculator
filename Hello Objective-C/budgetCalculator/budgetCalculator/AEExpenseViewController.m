//
//  AEExpenseViewController.m
//  budgetCalculator
//
//  Created by Alex Eisenach on 1/26/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import "AEExpenseViewController.h"
#import "AEAddItemViewController.h"
#import "AEQuickExpenseViewController.h"
@interface AEExpenseViewController ()
@property NSMutableArray *expenses;
@property NSMutableArray *items;
@end

@implementation AEExpenseViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Expense";
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"expense.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"notexpense.png"]];
        [self loadItems];
        [self getItems];
    }
    return self;
}

-(void)controller:(AEAddItemViewController *)controller didSaveExpenseItemWithName:(NSString *)name andPrice:(float)price
{

    
    [self loadItems];
    NSNumber *finalPrice = [NSNumber numberWithFloat:price];
    NSMutableDictionary *dictionaryItem = [[NSMutableDictionary alloc] init];
    dictionaryItem[@"description"] = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    dictionaryItem[@"price"] = finalPrice;
    dictionaryItem[@"type"] = @"Expense";
    NSMutableArray *newExpense = [[NSMutableArray alloc] init];
    [newExpense addObject:dictionaryItem];
    [self.expenses addObject:newExpense];
    [self getItems];

    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.items count] - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.expenses writeToFile:[self pathForItems] atomically:YES];
    NSLog(@"break");
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
    AEQuickExpenseViewController *addItemViewController = [[AEQuickExpenseViewController alloc] initWithNibName:@"AEQuickExpenseViewController" bundle:nil];
    // Present View Controller
    [addItemViewController setDelegate:self];
    [self presentViewController:addItemViewController animated:YES completion:nil];
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
        NSString *income = @"Expense";
        if([value isEqualToString:income] == 1){
            [incomes addObject:dictionary];
            
        }
    }
    self.items = incomes;
    NSLog(@"%@",[self pathForItems]);
}

//- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
//    NSIndexPath *lastPath = [NSIndexPath indexPathForRow:([self.items count]) inSection:(0)];
//    if (indexPath == lastPath){
//        NSLog(@"WHOOJOWNS");
//    }
//    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
//    NSLog(@"%@",indexPath);
//}

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
 
    return [self.items count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Fetch Item
    
    for(int i = 0; i < [[cell.textLabel subviews] count]; i++){
        NSLog(@"here it is %@",[[cell.textLabel subviews] objectAtIndex:i]);
        UIView *currentView = [[cell.textLabel subviews] objectAtIndex:i];
        if([currentView isKindOfClass:[UILabel class]]){
            [currentView removeFromSuperview];
        }
    }
    if([indexPath row] == [self.items count]){
        [cell.textLabel setText:@"Clear All"];
        cell.textColor = [[UIColor alloc] initWithRed:(240.0) / 255.0 green:(82.0) / 255.0 blue:94.0 / 255.0 alpha:1];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    else{
    
    

    NSDictionary *expenseDict = [self.items objectAtIndex:[indexPath row]];
    NSArray *arrayOfValues = [expenseDict valueForKey:@"description"];
    NSArray *arrayOfPrices = [expenseDict valueForKey:@"price"];
    NSString *expense = [arrayOfValues objectAtIndex:0];
    NSNumber *expensePrice = [arrayOfPrices objectAtIndex:0];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";
    CGRect expenseFrame = CGRectMake(10.0, 0.0, 280, 50);
    UILabel *subLabel = [[UILabel alloc] initWithFrame:expenseFrame];
//    subLabel.backgroundColor = [UIColor grayColor];
    subLabel.textColor = [[UIColor alloc] initWithRed:(240.0) / 255.0 green:(82.0) / 255.0 blue:94.0 / 255.0 alpha:1];
    subLabel.textAlignment = NSTextAlignmentRight;
    NSString *formattedAmount = [formatter stringFromNumber:expensePrice];
    subLabel.text = [NSString stringWithFormat:@"%@",formattedAmount];
    //    // Configure Cell
    [cell.textLabel addSubview:subLabel];
//    // Configure Cell
    [cell.textLabel setText:expense];
    }
    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    if([indexPath row] != [self.items count]){
        [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    }
    else{
        self.expenses = [[NSMutableArray alloc] init];
        [self.expenses writeToFile:[self pathForItems] atomically:YES];
        [self viewWillAppear:YES];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([indexPath row] == [self.items count]){
        return NO;
    }
    else{
    return YES;
    }
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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // your stuff goes here...
    [self loadItems];
    [self getItems];
    [self.tableView reloadData];
    
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
