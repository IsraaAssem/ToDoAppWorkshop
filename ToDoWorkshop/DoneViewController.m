//
//  DoneViewController.m
//  ToDoWorkshop
//
//  Created by Israa Assem on 17/04/2024.
//

#import "DoneViewController.h"
#import "Task.h"
#import "DetailsViewController.h"
@interface DoneViewController ()
@property (nonatomic, strong) NSMutableArray<Task *> *doneTaskArray;
@property (weak, nonatomic) IBOutlet UITableView *doneTasksTable;

@end

@implementation DoneViewController


- (void)viewWillAppear:(BOOL)animated{
    _doneTaskArray = [[self retrieveData]mutableCopy] ;
    [self.doneTasksTable reloadData];
    [self addBackground];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _doneTasksTable.delegate=self;
    _doneTasksTable.dataSource=self;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Done tasks";
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _doneTaskArray.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailsViewController * detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.source=@"details";
    detailVC.taskToView=[_doneTaskArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.text = [_doneTaskArray objectAtIndex:indexPath.row].name;
        UIImage *image;
        if ([[_doneTaskArray objectAtIndex:indexPath.row].priority isEqualToString:@"High"]) {
            image = [UIImage imageNamed:@"highPriority"];
        } else if ([[_doneTaskArray objectAtIndex:indexPath.row].priority isEqualToString:@"Low"]) {
            image = [UIImage imageNamed:@"lowPriority"];
        } else {
            image = [UIImage imageNamed:@"mediumPriority"];
        }
        cell.imageView.image = image;
   
    return cell;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create a delete action
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        //////////////////  start  alert
        UIAlertController *deleteAlert=
        [UIAlertController alertControllerWithTitle:@"Delete task!" message:@"Are you sure you want to delete this task!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction =[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            [self.doneTaskArray removeObjectAtIndex:indexPath.row];  // Assuming self.tasks is your data source array
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // Update your data source such as UserDefaults here
            [self updateUserDefaults];
            [self addBackground];
        }];
        
        
        UIAlertAction *cancelAction =[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        
        [deleteAlert addAction:cancelAction];
        [deleteAlert addAction:deleteAction];
        
        [self presentViewController:deleteAlert animated:(YES) completion:nil];
        
    }];
    
    return @[deleteAction];
}
 
- (void)updateUserDefaults {
    NSData *tasksData = [NSKeyedArchiver archivedDataWithRootObject:self.doneTaskArray requiringSecureCoding:NO error:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tasksData forKey:@"Done"];
    [defaults synchronize];
}


- (NSArray<Task *> *)retrieveData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *retrievedData = [defaults objectForKey:@"Done"];
    
    if (!retrievedData) {
        NSLog(@"No data found in UserDefaults for key 'Done'");
        return nil;
    }
    NSError *unarchiveError = nil;
    NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class,NSDate.class]];
    
    NSArray<Task *> *retrievedTasksArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:retrievedData error:&unarchiveError];
    
    if (unarchiveError) {
        NSLog(@"Unarchive Error: %@", unarchiveError);
        return nil;
    }
    return retrievedTasksArray;
}
-(void)addBackground{
    if(_doneTaskArray.count==0){
       
            UIView *backgroundView = [[UIView alloc] initWithFrame:self.doneTasksTable.bounds];
            backgroundView.backgroundColor = [UIColor clearColor]; // Set the background color if needed
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:backgroundView.bounds];
            imageView.image = [UIImage imageNamed:@"doneBackground"];
            imageView.contentMode = UIViewContentModeScaleAspectFit; // Adjust content mode as needed
            
            [backgroundView addSubview:imageView];
            
            self.doneTasksTable.backgroundView = backgroundView;
        } else {
            self.doneTasksTable.backgroundView = nil;
        }
}

@end
