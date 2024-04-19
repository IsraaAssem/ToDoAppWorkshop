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
@property (nonatomic, strong) NSMutableArray<Task *> *highPriorityTasks;
@property (nonatomic, strong) NSMutableArray<Task *> *mediumPriorityTasks;
@property (nonatomic, strong) NSMutableArray<Task *> *lowPriorityTasks;
@property BOOL isFiltered;

@end

@implementation DoingViewController
- (IBAction)filterBtn:(id)sender {
    if(_isFiltered==YES){
            _isFiltered=NO;
            NSLog(@"NO\n");
        }
        else{
            _isFiltered=YES;
            NSLog(@"YES\n");
        }
    [self.inProgressTasksTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
       
    [self retrieveAndOrganizeTasks];
    [self.inProgressTasksTable reloadData];
    [self addBackground];
}
- (void)viewDidLoad {
    [self retrieveAndOrganizeTasks];
    [super viewDidLoad];
    _inProgressTasksTable.delegate=self;
    _inProgressTasksTable.dataSource=self;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_isFiltered==YES){
    if (section == 0) {
        return _highPriorityTasks.count;
    } else if (section == 1) {
        return _mediumPriorityTasks.count;
    } else {
        return _lowPriorityTasks.count;
    }}
    return _inProgressTasksArray.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DetailsViewController * detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.source=@"details";
    if(_isFiltered==YES){
        if(indexPath.section==0)
            detailVC.taskToView=[_highPriorityTasks objectAtIndex:indexPath.row];
        else if (indexPath.section==1)
            detailVC.taskToView=[_mediumPriorityTasks objectAtIndex:indexPath.row];
        else
            detailVC.taskToView=[_lowPriorityTasks objectAtIndex:indexPath.row];
    }else{
        detailVC.taskToView=[_inProgressTasksArray objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:detailVC animated:YES];
  
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_isFiltered==YES)
       return 3;
    else return 1;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create a delete action
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        //////////////////  start  alert
        UIAlertController *deleteAlert=
        [UIAlertController alertControllerWithTitle:@"Delete task!" message:@"Are you sure you want to delete this task!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction =[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            if(_isFiltered==YES){
                if(indexPath.section==0){
                    Task*taskToDelete=[_highPriorityTasks objectAtIndex:indexPath.row];
                    [self.highPriorityTasks removeObjectAtIndex:indexPath.row];
                    [_inProgressTasksArray removeObject:taskToDelete];
                }else if (indexPath.section==1){
                    Task*taskToDelete=[_mediumPriorityTasks objectAtIndex:indexPath.row];
                    [self.mediumPriorityTasks removeObjectAtIndex:indexPath.row];
                    [_inProgressTasksArray removeObject:taskToDelete];
                }else{
                    Task*taskToDelete=[_lowPriorityTasks objectAtIndex:indexPath.row];
                    [self.lowPriorityTasks removeObjectAtIndex:indexPath.row];
                    [_inProgressTasksArray removeObject:taskToDelete];                 }
            }else{
                [self.inProgressTasksArray removeObjectAtIndex:indexPath.row];
            }
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self updateUserDefaults];
            [self retrieveAndOrganizeTasks];
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
    if(_isFiltered==YES){
    if (section == 0) {
        return @"High Priority tasks";
    } else if (section == 1) {
        return @"Medium Priority tasks";
    } else {
        return @"Low Priority tasks";
    }}
    return @"In progress tasks";
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if(_isFiltered==YES){
        if(indexPath.section==0){
            cell.textLabel.text = [_highPriorityTasks objectAtIndex:indexPath.row].name;
            UIImage *image;
            image = [UIImage imageNamed:@"highPriority"];
            cell.imageView.image = image;
        }else if (indexPath.section==1){
            cell.textLabel.text = [_mediumPriorityTasks objectAtIndex:indexPath.row].name;
            UIImage *image;
            image = [UIImage imageNamed:@"mediumPriority"];
            cell.imageView.image = image;
        }else{
            cell.textLabel.text = [_lowPriorityTasks objectAtIndex:indexPath.row].name;
            UIImage *image;
            image = [UIImage imageNamed:@"lowPriority"];
            cell.imageView.image = image;
        }
    } else{
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
        }
   
    return cell;
}
- (void)addBackground{
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
    Task *selectedTask;
    if(_isFiltered==YES){
        if(indexPath.section==0){
            selectedTask=self.highPriorityTasks[indexPath.row];
        }else if (indexPath.section==1){
            selectedTask=self.mediumPriorityTasks[indexPath.row];
        }else{
            selectedTask=self.lowPriorityTasks[indexPath.row];
        }
        
    }else{
        selectedTask= self.inProgressTasksArray[indexPath.row];
    }
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
- (void)retrieveAndOrganizeTasks {
    self.inProgressTasksArray = [[self retrieveData] mutableCopy];
    self.highPriorityTasks = [NSMutableArray array];
    self.mediumPriorityTasks = [NSMutableArray array];
    self.lowPriorityTasks = [NSMutableArray array];
    
    for (Task *task in self.inProgressTasksArray) {
        if ([task.priority isEqualToString:@"High"]) {
            [self.highPriorityTasks addObject:task];
        } else if ([task.priority isEqualToString:@"Medium"]) {
            [self.mediumPriorityTasks addObject:task];
        } else {
            [self.lowPriorityTasks addObject:task];
        }
    }
}
@end
