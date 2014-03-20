//
//  AEHomeViewController.m
//  budgetCalculator
//
//  Created by Alex Eisenach on 2/9/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import "AEHomeViewController.h"
#import "AEAddItemViewController.h"
#import "AEIncomeViewController.h"
#import "AEQuickExpenseViewController.h"

@interface AEHomeViewController ()
@property NSMutableArray *expenses;
@property NSMutableArray *categories;
@property NSMutableArray *currentIncome;
@property NSMutableArray *onlyExpenses;
@property NSMutableArray *items;
@property NSNumber *dailyBudgetValue;
@property NSMutableArray *onlyIncomes;
@end

@implementation AEHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Home";
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"homehome.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"nothome.png"]];

    }
    [self calculateTotalCategories];
    return self;

    
    
}


- (void)loadItems {
    NSString *filePath = [self pathForItems];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.expenses = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.expenses = [NSMutableArray array];
    }
}

-(void)controller:(AEQuickAddViewController *)controller didSaveItemWithName:(NSString *)name andPrice:(float)price
{
    NSLog(@"its happening");
    [self loadItems];
    int newPrice = (int)price;
    NSNumber *finalPrice = [NSNumber numberWithFloat:newPrice];
    NSMutableDictionary *dictionaryItem = [[NSMutableDictionary alloc] init];
    dictionaryItem[@"description"] = name;
    dictionaryItem[@"price"] = finalPrice;
    dictionaryItem[@"type"] = @"Income";
    NSMutableArray *newExpense = [[NSMutableArray alloc] init];
    [newExpense addObject:dictionaryItem];
    [self.expenses addObject:newExpense];
    [self getItems];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.items count] - 1) inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.expenses writeToFile:[self pathForItems] atomically:YES];
    NSLog(@"break");
//    [self.tableView reloadData];
    
    
}

-(void)controller:(AEQuickExpenseViewController *)controller didSaveExpenseItemWithName:(NSString *)name andPrice:(float)price
{
    NSLog(@"its happening");
    [self loadItems];
    int newPrice = (int)price;
    NSNumber *finalPrice = [NSNumber numberWithFloat:newPrice];
    NSMutableDictionary *dictionaryItem = [[NSMutableDictionary alloc] init];
    dictionaryItem[@"description"] = name;
    dictionaryItem[@"price"] = finalPrice;
    dictionaryItem[@"type"] = @"Expense";
    NSMutableArray *newExpense = [[NSMutableArray alloc] init];
    [newExpense addObject:dictionaryItem];
    [self.expenses addObject:newExpense];
    [self getItems];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:([self.items count] - 1) inSection:0];
    //    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.expenses writeToFile:[self pathForItems] atomically:YES];
    NSLog(@"break");
    //    [self.tableView reloadData];
    
    
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self calculateDailyBudget];
    [self loadCategories];
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:date];
    NSInteger day = [dateComponents day];
    NSInteger month = [dateComponents month];
    NSString *monthString = [[NSString alloc] init];
    if (month == 1){
        
        monthString = @"January";
    }
    else if (month == 2){
        monthString = @"February";
    }
    else if (month == 3){
       monthString = @"March";
    }
    else if (month == 4){
        monthString = @"April";
    }
    else if (month == 5){
        monthString = @"May";
    }
    else if (month == 6){
       monthString = @"June";
    }
    else if (month == 7){
        monthString = @"July";
    }
    else if (month == 8){
        monthString = @"August";
    }
    else if (month == 9){
        monthString = @"September";
    }
    else if (month == 10){
        monthString = @"October";
    }
    else if (month == 11){
        monthString = @"November";
    }
    else if (month == 12){
        monthString = @"December";
    }
    self.month.text = [NSString stringWithFormat:@"For the remainder of %@",monthString];
}

-(int)calculateDay {
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:date];
    NSInteger day = [dateComponents day];
    NSInteger month = [dateComponents month];
    NSInteger totalDays = 0;
    if (month == 12 || month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10){
        totalDays = 31;
    }
    else if (month == 4 || month == 6 || month == 9 || month == 11){
        totalDays = 30;
    }
    else {
        totalDays = 28;
    }
    if((totalDays - day) == 0){
        return 1;
    }
    else{
        return (totalDays - day);
    }
}




-(void)calculateDailyBudget
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";
    [self loadCurrentIncome];
    NSLog(@"total income: %i ",[self calculateTotalIncome]);


    int currentIncome = [[self.currentIncome objectAtIndex:0] intValue];

    self.dailyBudgetValue = [NSNumber numberWithInt:currentIncome + ([self calculateTotalIncome] - [self calculateTotalExpense] - [self calculateTotalCategories])];
    float dailyBudget = [self.dailyBudgetValue floatValue] / [self calculateDay];
    if (dailyBudget > 0.00){
        self.dailyBudget.textColor = [UIColor greenColor];
    }
    else {
        self.dailyBudget.textColor = [UIColor redColor];
    }
    self.dailyBudget.text = [formatter stringFromNumber:[NSNumber numberWithFloat:dailyBudget]];



}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString *)pathForIncome {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"monthlyincome.plist"];
}
- (NSString *)pathForExpenses {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"expenses.plist"];
}
- (NSString *)pathForCategories {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"categories.plist"];
}

- (void)loadExpenses {
    NSString *filePath = [self pathForExpenses];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.expenses = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.expenses = [NSMutableArray array];
    }
}

- (void)loadCategories {
    NSString *filePath = [self pathForCategories];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {

        self.categories = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.categories = [NSMutableArray array];
    }
}
- (void)loadCurrentIncome {
    NSString *filePath = [self pathForIncome];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        self.currentIncome = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.currentIncome = [NSMutableArray array];
        [self.currentIncome addObject:[NSNumber numberWithInt:0]];

    }
}

-(void)getExpenses {
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
    self.onlyExpenses = incomes;

}


-(void)getIncomes {
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
    self.onlyIncomes = incomes;
}

-(int)calculateTotalIncome{
    [self loadExpenses];
    [self getIncomes];
    int total = 0;
    for(int i = 0; i < [self.onlyIncomes count]; i++){
        NSDictionary *dictionary = [self.onlyIncomes objectAtIndex:i];
        NSArray *arrayOfValues = [dictionary valueForKey:@"price"];
        NSNumber *number = [arrayOfValues objectAtIndex:0];
        total += [number intValue];
    }

    return total;
    
}

-(int)calculateTotalExpense{
    [self loadExpenses];
    [self getExpenses];
    int total = 0;
    for(int i = 0; i < [self.onlyExpenses count]; i++){
        NSDictionary *dictionary = [self.onlyExpenses objectAtIndex:i];
        NSArray *arrayOfValues = [dictionary valueForKey:@"price"];
        NSNumber *number = [arrayOfValues objectAtIndex:0];
        total += [number intValue];
    }

    return total;

}

-(int)calculateTotalCategories{
    int total = 0;
    [self loadCategories];
    for(int i = 0; i < [self.categories count];i++){
        NSString *categoryString = [self.categories objectAtIndex:i][0];
        NSNumber *categoryAmount = [self.categories objectAtIndex:i][1];
        if([self totalCalculate:categoryString] < [categoryAmount intValue]){
            total += ([categoryAmount intValue] - [self totalCalculate:categoryString]);
        }
        else if([self totalCalculate:categoryString] > [categoryAmount intValue]){
            total += 0;
        }
    }
    return total;
    
}

-(int)totalCalculate:(NSString *)category{
    [self getExpenses];
    int total = 0;
    for(int i = 0; i < [self.onlyExpenses count];i++){
        NSDictionary *expenseDict = [self.onlyExpenses objectAtIndex:i];
        NSArray *arrayOfValues = [expenseDict valueForKey:@"description"];
        NSString *expenseCategory =[arrayOfValues objectAtIndex:0];
        NSArray *arrayOfPrices = [expenseDict valueForKey:@"price"];
        NSNumber *expenseNumber =[arrayOfPrices objectAtIndex:0];
        if([expenseCategory isEqualToString:category] == 1){
            total += [expenseNumber intValue];
        }
        
    }
    return total;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // your stuff goes here...
    [self loadCategories];
    [self loadCurrentIncome];

    [self calculateDailyBudget];
}


- (void)addItem:(id)sender {
    // Initialize Add Item View Controller
    AEQuickAddViewController *quickaddViewController = [[AEQuickAddViewController alloc] initWithNibName:@"AEQuickAddViewController" bundle:nil];
    // Present View Controller
    [quickaddViewController setDelegate:self];
    [self presentViewController:quickaddViewController animated:YES completion:nil];
}


- (void)addExpense:(id)sender {
    // Initialize Add Item View Controller
    AEQuickExpenseViewController *quickexpenseViewController = [[AEQuickExpenseViewController alloc] initWithNibName:@"AEQuickExpenseViewController" bundle:nil];
    // Present View Controller
    [quickexpenseViewController setDelegate:self];
    
    [self presentViewController:quickexpenseViewController animated:YES completion:nil];
}


@end
