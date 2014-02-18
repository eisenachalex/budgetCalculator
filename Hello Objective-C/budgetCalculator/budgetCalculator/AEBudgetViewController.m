//
//  AEBudgetViewController.m
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/9/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import "AEBudgetViewController.h"
#import "AEAdjustIncomeViewController.h"

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
    self.budgetIncome = [self.budgetIncomeArray objectAtIndex:0];
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Budget";
        CGRect frame = CGRectMake(0.0, 75.0, 200.0, 75.0);
        UIView *headerView = [[UIView alloc] initWithFrame:frame];
        CGRect labelFrame = CGRectMake(0.0,0.0,150.0,75.0);
        UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
        UIButton *button  = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [button addTarget:self action:@selector(monthlyIncomeChanged:) forControlEvents:UIControlEventTouchUpInside];
        button.center = CGPointMake(200.0, 40.0);
        int incomeAnswer = [self.budgetIncome intValue];
        label.text = [NSString stringWithFormat:@"Monthly Income \n $%d", incomeAnswer];
        label.numberOfLines = 0;
    [label setBackgroundColor:[[UIColor alloc] initWithRed:204./255 green:213./255 blue:216./255 alpha:0.5]];
        [headerView addSubview:button];
        [headerView addSubview:label];

        [self.tableView setTableHeaderView:headerView];
        [self loadItems];
        [self loadCurrentIncome];
    }
    return self;
}

-(void)monthlyIncomeChanged:(UIButton*)sender{
    NSLog(@"whooeeeee");
    // Initialize Add Item View Controller
    AEAdjustIncomeViewController *adjustIncomeViewController = [[AEAdjustIncomeViewController alloc] initWithNibName:@"AEAdjustIncomeViewController" bundle:nil];
    // Present View Controller
    [adjustIncomeViewController setDelegate:self];
    
    [self presentViewController:adjustIncomeViewController animated:YES completion:nil];
}

-(void)controller:(AEAdjustIncomeViewController *)controller didSaveItemWithIncome:(float)income
{
    
    self.budgetIncome = [NSNumber numberWithInt:income];
    [self.budgetIncomeArray replaceObjectAtIndex:0 withObject:self.budgetIncome];
    [self.budgetIncomeArray writeToFile:[self pathForIncome] atomically:YES];
    NSLog(@"damn");
    

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
    
    CGRect frame = CGRectMake(0.0, 75.0, 200.0, 75.0);
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    CGRect labelFrame = CGRectMake(0.0,0.0,150.0,75.0);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    UIButton *button  = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [button addTarget:self action:@selector(monthlyIncomeChanged:) forControlEvents:UIControlEventTouchUpInside];
    button.center = CGPointMake(200.0, 40.0);
    int incomeAnswer = [self.budgetIncome intValue];
    label.text = [NSString stringWithFormat:@"Monthly Income \n $%d", incomeAnswer];
    label.numberOfLines = 0;
    [label setBackgroundColor:[[UIColor alloc] initWithRed:204./255 green:213./255 blue:216./255 alpha:0.5]];
    [headerView addSubview:button];
    [headerView addSubview:label];
    
    [self.tableView setTableHeaderView:headerView];
    [self loadItems];
    [self loadCurrentIncome];


}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell Identifier";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Fetch Item3
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell Identifier"];
    }
    for(int i = 0; i < [[cell.contentView subviews] count]; i++){
        NSLog(@"here it is %@",[[cell.contentView subviews] objectAtIndex:i]);
        UIView *currentView = [[cell.contentView subviews] objectAtIndex:i];
        if([currentView isKindOfClass:[UISlider class]]){
            [currentView removeFromSuperview];
        }
    }
    NSArray *category = [self.categories objectAtIndex:[indexPath row]];
    //    // Configure Cell
    NSString *realCategory =[category objectAtIndex:0];
    NSNumber *categoryAmount = [category objectAtIndex:1];
    [cell.textLabel setText:realCategory];
    CGRect frame = CGRectMake(10.0, 20.0, 200.0, 10.0);
    CGRect percentageFrame = CGRectMake(220,0.0,100.0,20.0);
    CGRect amountFrame = CGRectMake(220,30.0,100.0,20.0);
    UILabel *percentage = [[UILabel alloc] initWithFrame:percentageFrame];
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    UILabel *amount = [[UILabel alloc] initWithFrame:amountFrame];
    float equationNumber = [categoryAmount floatValue] / [[self.budgetIncomeArray objectAtIndex:0] floatValue];
    NSLog(@"%.1f",equationNumber);

    percentage.text = [NSString stringWithFormat:@"%.1f%%", (equationNumber * 100)];

    [slider setTag:indexPath.row];
    slider.maximumValue = [[self.budgetIncomeArray objectAtIndex:0] intValue];
    slider.minimumValue = 0;
    NSLog(@"%@",indexPath);
    slider.continuous = YES;
    slider.value = [categoryAmount intValue];
    amount.text = [NSString stringWithFormat:@"$%.0f",slider.value];
    [slider addSubview:percentage];
        [slider addSubview:amount];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

    [cell.contentView addSubview:slider];

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

-(void)sliderValueChanged:(UISlider*)sender{
    [self loadCategories];
    NSLog(@"%d", sender.tag);
    NSMutableArray *categoryArray = [self.categories objectAtIndex:sender.tag];
    NSLog(@"%@",categoryArray);
    NSArray *viewArray = [sender subviews];
    UILabel *label = [viewArray objectAtIndex:0];
    UILabel *amount = [viewArray objectAtIndex:1];
    label.text = [NSString stringWithFormat:@"%.f %%",(((float)sender.value / [[self.budgetIncomeArray objectAtIndex:0] intValue]) * 100)];

    amount.text = [NSString stringWithFormat:@"$%.0f", (float)sender.value];
    [categoryArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:sender.value]];
    [self.categories replaceObjectAtIndex:sender.tag withObject:categoryArray];
    [self.categories writeToFile:[self pathForCategories] atomically:YES];
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
