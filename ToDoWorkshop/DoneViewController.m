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
@property (nonatomic, strong) NSMutableArray<Task *> *highPriorityTasks;
@property (nonatomic, strong) NSMutableArray<Task *> *mediumPriorityTasks;
@property (nonatomic, strong) NSMutableArray<Task *> *lowPriorityTasks;
@property BOOL isFiltered;
@end

@implementation DoneViewController
- (IBAction)filterBtn:(id)sender {
    if(_isFiltered==YES){
            _isFiltered=NO;
            NSLog(@"NO\n");
        }
        else{
            _isFiltered=YES;
            NSLog(@"YES\n");
        }
    [self.doneTasksTable reloadData];
}
- (void)viewWillAppear:(BOOL)animated{
        [self retrieveAndOrganizeTasks];
        [self.doneTasksTable reloadData];
        [self addBackground];
}
- (void)viewDidLoad {
    [self retrieveAndOrganizeTasks];
    [super viewDidLoad];
    _doneTasksTable.delegate=self;
    _doneTasksTable.dataSource=self;
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
        return @"Done tasks";
   
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
    return _doneTaskArray.count;
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
        detailVC.taskToView=[_doneTaskArray objectAtIndex:indexPath.row];
    }
    [self.navigationController pushViewController:detailVC animated:YES];
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
        }
   
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_isFiltered==YES)
       return 3;
    else return 1;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        //////////////////  start  alert
        UIAlertController *deleteAlert=
        [UIAlertController alertControllerWithTitle:@"Delete task!" message:@"Are you sure you want to delete this task!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction =[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            if(_isFiltered==YES){
                if(indexPath.section==0){
                    Task*taskToDelete=[_highPriorityTasks objectAtIndex:indexPath.row];
                    [self.highPriorityTasks removeObjectAtIndex:indexPath.row];
                    [_doneTaskArray removeObject:taskToDelete];
                }else if (indexPath.section==1){
                    Task*taskToDelete=[_mediumPriorityTasks objectAtIndex:indexPath.row];
                    [self.mediumPriorityTasks removeObjectAtIndex:indexPath.row];
                    [_doneTaskArray removeObject:taskToDelete];            
                }else{
                    Task*taskToDelete=[_lowPriorityTasks objectAtIndex:indexPath.row];
                    [self.lowPriorityTasks removeObjectAtIndex:indexPath.row];
                    [_doneTaskArray removeObject:taskToDelete];                 }
            }else{
                [self.doneTaskArray removeObjectAtIndex:indexPath.row];
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
- (void)addBackground{
    if(_doneTaskArray.count==0){
            UIView *backgroundView = [[UIView alloc] initWithFrame:self.doneTasksTable.bounds];
            backgroundView.backgroundColor = [UIColor clearColor];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:backgroundView.bounds];
            imageView.image = [UIImage imageNamed:@"doneBackground"];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [backgroundView addSubview:imageView];
            self.doneTasksTable.backgroundView = backgroundView;
        } else {
            self.doneTasksTable.backgroundView = nil;
        }
}
- (void)retrieveAndOrganizeTasks {
    self.doneTaskArray = [[self retrieveData] mutableCopy];
    self.highPriorityTasks = [NSMutableArray array];
    self.mediumPriorityTasks = [NSMutableArray array];
    self.lowPriorityTasks = [NSMutableArray array];
    
    for (Task *task in self.doneTaskArray) {
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

