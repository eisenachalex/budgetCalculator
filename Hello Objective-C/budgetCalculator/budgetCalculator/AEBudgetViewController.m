//
//  AEBudgetViewController.m
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/9/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import "AEBudgetViewController.h"
#import "AEAdjustIncomeViewController.h"
#import "AEEditViewController.h"

@interface AEBudgetViewController ()
@property NSMutableArray *categories;
@property NSMutableArray *expenses;
@property NSNumber *budgetIncome;
@property NSMutableArray *categoryValues;
@property UIView *sliderView;
@property NSMutableArray *budgetIncomeArray;

@end

@implementation AEBudgetViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    [self loadCurrentIncome];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.budgetIncome = [self.budgetIncomeArray objectAtIndex:0];
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Budget";
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"budget.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"notbudget.png"]];
        CGRect frame = CGRectMake(0.0, 75.0, 200.0, 75.0);
        UIView *headerView = [[UIView alloc] initWithFrame:frame];
        CGRect labelFrame = CGRectMake(30.0,50.0,150.0,75.0);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        UIButton *button  = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [button addTarget:self action:@selector(monthlyIncomeChanged:) forControlEvents:UIControlEventTouchUpInside];
        button.center = CGPointMake(200.0, 40.0);
        float incomeAnswer = [self.budgetIncome floatValue];
        NSLog(@"%.02f",incomeAnswer);
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
        formatter.currencyCode = @"USD";
        label.text = [NSString stringWithFormat:@"$%.02f",incomeAnswer];
        label.numberOfLines = 0;
        [label setBackgroundColor:[[UIColor alloc] initWithRed:204./255 green:213./255 blue:216./255 alpha:0.5]];
        [headerView addSubview:label];
        [headerView addSubview:button];

        [self.tableView setTableHeaderView:headerView];
        [self loadItems];
        [self loadCurrentIncome];
    }
    return self;
}

-(void)monthlyIncomeChanged:(UIButton*)sender{
    // Initialize Add Item View Controller
    AEAdjustIncomeViewController *adjustIncomeViewController = [[AEAdjustIncomeViewController alloc] initWithNibName:@"AEAdjustIncomeViewController" bundle:nil];
    // Present View Controller
    [adjustIncomeViewController setDelegate:self];
    [self presentViewController:adjustIncomeViewController animated:YES completion:nil];
}

-(void)controller:(AEAdjustIncomeViewController *)controller didSaveItemWithIncome:(float)income
{
    
    self.budgetIncome = [NSNumber numberWithFloat:income];
    [self.budgetIncomeArray replaceObjectAtIndex:0 withObject:self.budgetIncome];
    [self.budgetIncomeArray writeToFile:[self pathForIncome] atomically:YES];
    NSLog(@"damn");
    [self viewWillAppear:YES];
    

}

- (void)loadCurrentIncome {

    NSString *filePath = [self pathForIncome];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.budgetIncomeArray = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.budgetIncomeArray = [NSMutableArray array];
        [self.budgetIncomeArray addObject:[NSNumber numberWithInt:0]];
    }
}

-(void)controller:(AEEditViewController *)controller didUpdateItem:(NSString *)name andPrice:(float)price
{
}

-(void)controller:(AEAddItemViewController *)controller didSaveItemWithName:(NSString *)name andPrice:(float)price
{
    [self loadItems];
    NSMutableArray *newObject = [[NSMutableArray alloc] init];
    [newObject addObject:name];
    NSNumber *number = [NSNumber numberWithInt:price];
    [newObject addObject:number];
    [self.categories addObject:newObject];

    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.categories count] - 1) inSection:0];

    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.categories writeToFile:[self pathForItems] atomically:YES];
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
- (void)loadItems {
    NSString *filePath = [self pathForItems];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.categories = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.categories = [NSMutableArray array];
    }
    
}

- (void)loadExpenses {
    NSString *filePath = [self pathForExpenses];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.expenses = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.expenses = [NSMutableArray array];
    }
    
}

- (void)addItem:(id)sender {
    // Initialize Add Item View Controller
    AEAddItemViewController *addItemViewController = [[AEAddItemViewController alloc] initWithNibName:@"AEAddItemViewController" bundle:nil];
    // Present View Controller
    [addItemViewController setDelegate:self];
    
    [self presentViewController:addItemViewController animated:YES completion:nil];
}

- (void)editItems:(id)sender {
    [self.tableView setEditing:![self.tableView isEditing] animated:YES];
    
}
- (NSString *)pathForItems {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"categories.plist"];
}
- (NSString *)pathForExpenses {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"expenses.plist"];
}
- (NSString *)pathForIncome {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"monthlyincome.plist"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.categories count];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect frame = CGRectMake(0.0, 75.0, 200.0, 100.0);
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    CGRect labelFrame = CGRectMake(0.0,0.0,320.0,75.0);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    CGRect actualFrame = CGRectMake(0.0,40.0,320.0,50.0);
    UILabel *actualAmountLabel = [[UILabel alloc] initWithFrame:actualFrame];
    actualAmountLabel.textColor = [UIColor greenColor];
    label.textAlignment = NSTextAlignmentCenter;
    actualAmountLabel.textAlignment = NSTextAlignmentCenter;

    UIButton *button  = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"TAP TO ADJUST" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(monthlyIncomeChanged:) forControlEvents:UIControlEventTouchUpInside];
    button.center = CGPointMake(160.0, 90.0);
    button.frame = CGRectMake(65.0,73.0,200.0,30.0);
    NSNumber *incomeAnswer = self.budgetIncome;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";
    NSString *formattedAmount = [formatter stringFromNumber:incomeAnswer];
    label.text = [NSString stringWithFormat:@"Expected Income"];
    actualAmountLabel.text = [NSString stringWithFormat:@"%@",formattedAmount];
    actualAmountLabel.font = [UIFont boldSystemFontOfSize:22.0];
    button.font = [UIFont systemFontOfSize:7.0];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    label.numberOfLines = 0;
    [headerView addSubview:label];
    [headerView addSubview:actualAmountLabel];
    [headerView addSubview:button];
    
    [self.tableView setTableHeaderView:headerView];
    [self loadItems];
    [self loadCurrentIncome];
    [self.tableView reloadData];


}

-(float)categoryExpenses:(NSString *)category{
    float answer = 0.0;
    [self loadExpenses];
    for (int i = 0; i < [self.expenses count]; i++){
        NSDictionary *expense = [self.expenses objectAtIndex:i];
        NSArray *arrayOfTypes = [expense valueForKey:@"type"];
        NSString *typeValue = [arrayOfTypes objectAtIndex:0];
        NSArray *arrayOfPrice = [expense valueForKey:@"price"];
        NSNumber *priceValue = [arrayOfPrice objectAtIndex:0];
        NSArray *arrayOfDescription = [expense valueForKey:@"description"];
        NSString *descriptionValue = [arrayOfDescription objectAtIndex:0];
        if(([typeValue isEqualToString:@"Expense"] == 1) && ([descriptionValue isEqualToString:category] == 1)){
             answer += [priceValue intValue];
        }
    }
    return answer;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    for(int i = 0; i < [[cell.textLabel subviews] count]; i++){
        UIView *currentView = [[cell.textLabel subviews] objectAtIndex:i];
        if([currentView isKindOfClass:[UILabel class]]){
            [currentView removeFromSuperview];
        }
        else if([currentView isKindOfClass:[UIButton class]]){
            [currentView removeFromSuperview];
        }
    }   
    NSArray *category = [self.categories objectAtIndex:[indexPath row]];
    NSString *realCategory =[category objectAtIndex:0];
    NSNumber *categoryAmount = [category objectAtIndex:1];
    [cell.textLabel setText:realCategory];
    CGRect amountFrame = CGRectMake(190.0,15.0,100.0,20.0);
    UILabel *amount = [[UILabel alloc] initWithFrame:amountFrame];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";
    amount.text =[formatter stringFromNumber:categoryAmount];
    amount.textAlignment = NSTextAlignmentRight;
    amount.font = [UIFont italicSystemFontOfSize:12.0];
    amount.textColor = [UIColor redColor];
    [cell.textLabel addSubview:amount];

    return cell;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    // Fetch Item
        NSMutableArray *categoryItem = [self.categories objectAtIndex:[indexPath row]];

    // Initialize Edit Item View Controller
    AEEditViewController *editViewController = [[AEEditViewController alloc] init];
    editViewController.categoryItem = categoryItem;
    editViewController.totalIncome = self.budgetIncome;
    editViewController.indexNumber = [NSNumber numberWithInt:[indexPath row]];
    // Push View Controller onto Navigation Stack
    [self.navigationController pushViewController:editViewController animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}



- (NSString *)pathForCategories {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"categories.plist"];
}


- (void)loadCategories {
    NSString *filePath = [self pathForCategories];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.categories = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.categories = [NSMutableArray array];
    }
}

//Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self.categories removeObject:[self.categories objectAtIndex:[indexPath row]]];
        [self.categories writeToFile:[self pathForItems] atomically:YES];
        [self loadItems];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
