//
//  ToDoViewController.m
//  ToDoWorkshop
//
//  Created by Israa Assem on 17/04/2024.
//

#import "ToDoViewController.h"
#import"Task.h"
#import"DetailsViewController.h"
@interface ToDoViewController ()<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myToDoTable;
@property (nonatomic, strong) NSMutableArray<Task *> *taskArray;
@property (nonatomic, strong) NSMutableArray<Task *> *filteredTasks;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ToDoViewController
- (void)viewWillAppear:(BOOL)animated{
    _taskArray = [[self retrieveData]mutableCopy] ;
    [self.myToDoTable reloadData];
    [self addBackground];
    self.filteredTasks = [NSMutableArray arrayWithArray:self.taskArray];
    self.searchBar.text=NULL;
    [self.myToDoTable reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _myToDoTable.delegate=self;
    _myToDoTable.dataSource=self;
    self.searchBar.delegate=self;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return self.filteredTasks.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"To do tasks";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailsViewController * detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.source=@"details";
    NSLog(@"rowwwww%ld\n",(long)indexPath.row);
    detailVC.taskToView=[_taskArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            cell.textLabel.text = [_filteredTasks objectAtIndex:indexPath.row].name;
        UIImage *image;
        if ([[_taskArray objectAtIndex:indexPath.row].priority isEqualToString:@"High"]) {
            image = [UIImage imageNamed:@"highPriority"];
        } else if ([[_taskArray objectAtIndex:indexPath.row].priority isEqualToString:@"Low"]) {
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
              
               Task *taskToDelete = [self.filteredTasks objectAtIndex:indexPath.row];
               [self.filteredTasks removeObjectAtIndex:indexPath.row];
               [self.taskArray removeObject:taskToDelete];               
               [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

- (void)editTaskAtIndexPath:(NSIndexPath *)indexPath {
    Task *selectedTask = self.taskArray[indexPath.row];
    DetailsViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.taskToView = selectedTask;
    detailVC.source=@"edit";
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)updateUserDefaults {
    NSData *tasksData = [NSKeyedArchiver archivedDataWithRootObject:self.taskArray requiringSecureCoding:NO error:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:tasksData forKey:@"To do"];
    [defaults synchronize];
}


- (NSArray<Task *> *)retrieveData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *retrievedData = [defaults objectForKey:@"To do"];
    
    if (!retrievedData) {
        NSLog(@"No data found in UserDefaults for key 'To do'");
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
    if(_taskArray.count==0){
       
            UIView *backgroundView = [[UIView alloc] initWithFrame:self.myToDoTable.bounds];
            backgroundView.backgroundColor = [UIColor clearColor];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:backgroundView.bounds];
            imageView.image = [UIImage imageNamed:@"todoBackground"];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [backgroundView addSubview:imageView];
            
            self.myToDoTable.backgroundView = backgroundView;
        } else {
            self.myToDoTable.backgroundView = nil;
        }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.filteredTasks = [NSMutableArray arrayWithArray:self.taskArray];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
        self.filteredTasks = [NSMutableArray arrayWithArray:[self.taskArray filteredArrayUsingPredicate:predicate]];
    }
    [self.myToDoTable reloadData];
}


@end
