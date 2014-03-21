//
//  AEEditViewController.m
//  budgetCalculator
//
//  Created by Alex Eisenach on 3/3/14.
//  Copyright (c) 2014 Alex Eisenach. All rights reserved.
//

#import "AEEditViewController.h"

@interface AEEditViewController ()
@property (weak) id<AEEditViewControllerDelegate> delegate;
@property NSMutableArray *categories;
@property NSMutableArray *expenses;
@end

@implementation AEEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // your stuff goes here...
    [self loadCategories];
    [self loadExpenses];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";
    NSNumber *number = [NSNumber numberWithFloat:[self categoryExpenses:[self.categoryItem objectAtIndex:0]]];
    NSLog(@"HERE WE GO %@",number);
    self.currentPrice.text = [formatter stringFromNumber:number];
                              
    self.price.text = [formatter stringFromNumber:[self.categoryItem objectAtIndex:1]];
    self.progress.progress = ([self categoryExpenses:[self.categoryItem objectAtIndex:0]] / self.slider.value);
    NSLog(@"HEYYYY UUU HARRY %@",self.labelText);

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.category.text = [self.categoryItem objectAtIndex:0];
    self.price.text = [NSString stringWithFormat:@"$%@",[self.categoryItem objectAtIndex:1]];
     [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.slider.maximumValue = [self.totalIncome intValue];
    self.slider.minimumValue = 0;
    self.slider.continuous = YES;
    self.slider.value = [[self.categoryItem objectAtIndex:1] intValue];
    self.currentPrice.textColor = self.labelColor;
}



- (void)loadCategories {
    NSString *filePath = [self pathForCategories];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        self.categories = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        self.categories = [NSMutableArray array];
    }
}
- (NSString *)pathForCategories {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"categories.plist"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)save:(id)sender {
    float price = [[self.price text] floatValue];
    NSString *categoryItem = [self.category text];
    // Update Item
    for(int i = 0; i < [self.categories count]; i++){
        NSMutableArray *category = [self.categories objectAtIndex:i];
        NSString *categoryName = [category objectAtIndex:0];
        if([categoryName isEqualToString:categoryItem] == 1){
        }
        
    }
    // Notify Delegate
    
    // Pop View Controller
    [self.categories writeToFile:[self pathForCategories] atomically:YES];

    [self.navigationController popViewControllerAnimated:YES];
}


-(id)initWithItem:(NSMutableArray *)categoryItem andDelegate:(id<AEEditViewControllerDelegate>)delegate{
    self = [super initWithNibName:@"AEEditViewController" bundle:nil];
    
    if(self){
        self.categoryItem = categoryItem;
        self.delegate = delegate;
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

- (NSString *)pathForExpenses {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths lastObject];
    return [documents stringByAppendingPathComponent:@"expenses.plist"];
}

-(float)categoryExpenses:(NSString *)category{
    float answer = 0.00;
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
            answer += [priceValue floatValue];
        }
    }
    return answer;
}

-(void)sliderValueChanged:(UISlider*)sender{
    [self loadCategories];
    NSMutableArray *categoryArray = [self.categories objectAtIndex:[self.indexNumber intValue]];
    NSArray *viewArray = [sender subviews];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"USD";

    self.price.text = [formatter stringFromNumber:[NSNumber numberWithInt:sender.value]];
// UIProgressView *progress = [viewArray objectAtIndex:2];
 [categoryArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:sender.value]];
    [self.categories replaceObjectAtIndex:[self.indexNumber intValue] withObject:categoryArray];
//    [self loadCurrentIncome];
    self.progress.progress = ([self categoryExpenses:[categoryArray objectAtIndex:0]] / sender.value);
    if (self.progress.progress >= 1.0) {
        self.progress.progressTintColor = [UIColor redColor];
    }
    else{
        self.progress.progressTintColor = [UIColor blueColor];

    }

}

@end
