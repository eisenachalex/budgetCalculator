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

@interface AEHomeViewController ()
@property NSMutableArray *expenses;
@property NSMutableArray *categories;
@property NSMutableArray *currentIncome;
@property NSMutableArray *onlyExpenses;
@property NSNumber *dailyBudgetValue;
@property NSMutableArray *onlyIncomes;
@end

@implementation AEHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Home";
        
    }
    
    return self;


    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self calculateDailyBudget];
    [self loadCategories];
   

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
    return (totalDays - day);
}

-(void)calculateDailyBudget
{   [self loadCurrentIncome];
    NSLog(@"today is %i",[self calculateDay]);
    int currentIncome = [[self.currentIncome objectAtIndex:0] intValue];

    self.dailyBudgetValue = [NSNumber numberWithInt:currentIncome + ([self calculateTotalIncome] - [self calculateTotalExpense] - [self categoryTotal])];
    self.dailyBudget.text = [NSString stringWithFormat:@"$%d",([self.dailyBudgetValue intValue] / [self calculateDay])];



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
        [self.currentIncome addObject:[NSNumber numberWithInt:54321]];

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


-(int)categoryTotal {
    int total = 0;
    for(int i = 0; i < [self.categories count]; i++){
        NSArray *array = [self.categories objectAtIndex:i];
        NSNumber *number = [array objectAtIndex:1];
        int intValue = [number intValue];
        total += intValue;
    }

    return total;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // your stuff goes here...
    [self loadCategories];
    [self loadCurrentIncome];
    [self categoryTotal];

    [self calculateDailyBudget];
}


- (IBAction)addItem:(id)sender {
    // Initialize Add Item View Controller
    AEAddItemViewController *addItemViewController = [[AEAddItemViewController alloc] initWithNibName:@"AEAddItemViewController" bundle:nil];
    // Present View Controller
    AEIncomeViewController *incomeView = [[AEIncomeViewController alloc] init];
    [addItemViewController setDelegate:self];
    
    
    [self presentViewController:addItemViewController animated:YES completion:nil];
}


@end
