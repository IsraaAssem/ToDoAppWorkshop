//
//  DoingViewController.m
//  ToDoWorkshop
//
//  Created by Israa Assem on 17/04/2024.
//

#import "DoingViewController.h"
#import "Task.h"
#import "DetailsViewController.h"
@interface DoingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *inProgressTasksTable;
@property (nonatomic, strong) NSMutableArray<Task *> *inProgressTasksArray;

@end

@implementation DoingViewController


- (void)viewWillAppear:(BOOL)animated{
    _inProgressTasksArray= [[self retrieveData]mutableCopy] ;
    [self.inProgressTasksTable reloadData];
    [self addBackground];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _inProgressTasksTable.delegate=self;
    _inProgressTasksTable.dataSource=self;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _inProgressTasksArray.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailsViewController * detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.source=@"details";
    detailVC.taskToView=[_inProgressTasksArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}




- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create a delete action
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        //////////////////  start  alert
        UIAlertController *deleteAlert=
        [UIAlertController alertControllerWithTitle:@"Delete task!" message:@"Are you sure you want to delete this task!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction =[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            [self.inProgressTasksArray removeObjectAtIndex:indexPath.row];  // Assuming self.tasks is your data source array
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
UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {

        [self editTaskAtIndexPath:indexPath];
}];
editAction.backgroundColor = [UIColor greenColor];

return @[deleteAction, editAction];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"In progress tasks";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.text = [_inProgressTasksArray objectAtIndex:indexPath.row].name;
        UIImage *image;
        if ([[_inProgressTasksArray objectAtIndex:indexPath.row].priority isEqualToString:@"High"]) {
            image = [UIImage imageNamed:@"highPriority"];
        } else if ([[_inProgressTasksArray objectAtIndex:indexPath.row].priority isEqualToString:@"Low"]) {
            image = [UIImage imageNamed:@"lowPriority"];
        } else {
            image = [UIImage imageNamed:@"mediumPriority"];
        }
        cell.imageView.image = image;
   
    return cell;
}

-(void)addBackground{
    if(_inProgressTasksArray.count==0){
       
            UIView *backgroundView = [[UIView alloc] initWithFrame:self.inProgressTasksTable.bounds];
            backgroundView.backgroundColor = [UIColor clearColor];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:backgroundView.bounds];
            imageView.image = [UIImage imageNamed:@"inProgressBackground"];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [backgroundView addSubview:imageView];
            
            self.inProgressTasksTable.backgroundView = backgroundView;
        } else {
            self.inProgressTasksTable.backgroundView = nil;
        }
}
- (void)editTaskAtIndexPath:(NSIndexPath *)indexPath {
    Task *selectedTask = self.inProgressTasksArray[indexPath.row];
    DetailsViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.taskToView = selectedTask;
    detailVC.source=@"edit";
    [self.navigationController pushViewController:detailVC animated:YES];
}
- (void)updateUserDefaults {
    NSData *tasksData = [NSKeyedArchiver archivedDataWithRootObject:self.inProgressTasksArray requiringSecureCoding:NO error:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tasksData forKey:@"In progress"];
    [defaults synchronize];
}
- (NSArray<Task *> *)retrieveData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *retrievedData = [defaults objectForKey:@"In progress"];
    
    if (!retrievedData) {
        NSLog(@"No data found in UserDefaults for key 'In progress'");
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
@end
