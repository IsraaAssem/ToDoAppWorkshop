//
//  TestViewController.m
//  ToDoWorkshop
//
//  Created by Israa Assem on 17/04/2024.
//

#import "DetailsViewController.h"
#import "Task.h"
@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *taskName;
@property (weak, nonatomic) IBOutlet UITextField *taskDescription;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskPriority;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taskState;
@property (weak, nonatomic) IBOutlet UIDatePicker *taskDate;
@property NSString *state,*priority;
@property NSDate *date;
@property (weak, nonatomic) IBOutlet UIButton *addEditTaskBtn;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _taskDate.minimumDate = [NSDate date];
    _taskName.delegate = self;

}
- (void)viewWillAppear:(BOOL)animated{
    if ([_source isEqual:@"details"]) {
        _taskPriority.enabled = NO;
        _taskState.enabled = NO;

        _addEditTaskBtn.hidden = YES;
        _taskName.text=_taskToView.name;
        _taskDescription.text=_taskToView.taskDescription;
        _taskDate.date=_taskToView.date;
        NSString *segmentTitle ;
        for (int i = 0; i < _taskPriority.numberOfSegments; i++) {
           segmentTitle = [_taskPriority titleForSegmentAtIndex:i];
            if ([segmentTitle isEqualToString: _taskToView.priority]) {
                printf("%d",i);
                _taskPriority.selectedSegmentIndex = i;
                break;
            }
        
        }
        for (int i = 0; i < _taskState.numberOfSegments; i++) {
           segmentTitle = [_taskState titleForSegmentAtIndex:i];
            if ([segmentTitle isEqualToString: _taskToView.state]) {
                _taskState.selectedSegmentIndex = i;
                break;
            }
        }

    } else {
        _addEditTaskBtn.hidden = NO;
        if ([_source isEqual:@"add"]) {
            [_taskState setEnabled:NO forSegmentAtIndex:1];
            [_taskState setEnabled:NO forSegmentAtIndex:2];
            [_addEditTaskBtn setTitle:@"Add" forState:UIControlStateNormal];
        } else if ([_source isEqual:@"edit"]) {
            [_addEditTaskBtn setTitle:@"Save" forState:UIControlStateNormal];
            _taskName.text=_taskToView.name;
            _taskDescription.text=_taskToView.taskDescription;
            _taskDate.date=_taskToView.date;
            NSString *segmentTitle ;
            for (int i = 0; i < _taskPriority.numberOfSegments; i++) {
               segmentTitle = [_taskPriority titleForSegmentAtIndex:i];
                if ([segmentTitle isEqualToString: _taskToView.priority]) {
                    printf("%d",i);
                    _taskPriority.selectedSegmentIndex = i;
                    break;
                }
            
            }
            for (int i = 0; i < _taskState.numberOfSegments; i++) {
               segmentTitle = [_taskState titleForSegmentAtIndex:i];
                if ([segmentTitle isEqualToString: _taskToView.state]) {
                    _taskState.selectedSegmentIndex = i;
                    if(i==1){
                        [_taskState setEnabled:NO forSegmentAtIndex:0];
                    }
                    break;
                }
            }
            
        }
    }
}

- (IBAction)addOrEditTask:(id)sender {
    
    _date= self.taskDate.date;
    NSLog(@"selected date: %@\n",_date);
    
    NSInteger selectedPriorityIndex = self.taskPriority.selectedSegmentIndex;
    
    switch (selectedPriorityIndex) {
        case 0:
            _priority=[self.taskPriority titleForSegmentAtIndex:0];
            break;
        case 1:
            _priority=[self.taskPriority titleForSegmentAtIndex:1];
            break;
        case 2:
            _priority=[self.taskPriority titleForSegmentAtIndex:2];
            break;
        default:
            _priority=NULL;
    }
    NSInteger selectedStateIndex = self.taskState.selectedSegmentIndex;
    
    switch (selectedStateIndex) {
        case 0:
            _state=[self.taskState titleForSegmentAtIndex:0];
            break;
        case 1:
            _state=[self.taskState titleForSegmentAtIndex:1];
            break;
        case 2:
            _state=[self.taskState titleForSegmentAtIndex:2];
            break;
        default:
            _state=NULL;
    }
    if ([_source isEqual:@"add"]) {
        if([_taskName.text isEqualToString:@""]){
            UIAlertController *alert=
            [UIAlertController alertControllerWithTitle:@"Invalid task!" message:@"Please enter a name for the task!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction =[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okAction];
            [self presentViewController:alert animated:(YES) completion:nil];
        }else{
            NSLog(@"Not nulll");
            [self updateTasksInUserDefaults:_state];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        //alert
        UIAlertController *deleteAlert=
        [UIAlertController alertControllerWithTitle:@"Save task!" message:@"Are you sure you want to Save changes!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteAction =[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            
            [self updateTasksInUserDefaults:self->_state];
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        UIAlertAction *cancelAction =[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        
        [deleteAlert addAction:cancelAction];
        [deleteAlert addAction:deleteAction];
        
        [self presentViewController:deleteAlert animated:(YES) completion:nil];
    }
}
-(void)updateTasksInUserDefaults:(NSString*)tasksType{
    if([_source isEqual:@"edit"]){
        NSLog(@"edit......\n");
        [self deleteTaskInUserDefaults:_taskToView.state];
      
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *retrievedData = [defaults objectForKey:tasksType];
    NSError *unarchiveError = nil;
    NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class,NSDate.class]];
    NSArray <Task*>*retrievedTasksArray;
    if (retrievedData) {
        retrievedTasksArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:retrievedData error:&unarchiveError];
    } else {
        NSLog(@"No data found in UserDefaults for key %@\n",tasksType);
    }
    if (unarchiveError) {
        NSLog(@"Unarchive Error: %@\n", unarchiveError);
    }

    if (retrievedTasksArray) {
        for (Task *task in retrievedTasksArray) {
            NSLog(@"Retrieved task: %@ with state: %@ priority: %@\n", task.name, task.state,task.priority);
        }
    } else {
        NSLog(@"Failed to retrieve tasks\n");
    }
    ///////////////////////////////////
    Task *task = [[Task alloc] initWithName:_taskName.text priority:_priority taskDescription:_taskDescription.text state:_state date:_date ];
    NSMutableArray *tasksArray;
    if (retrievedTasksArray) {
      tasksArray  = [retrievedTasksArray mutableCopy];
    }else{
        tasksArray=[NSMutableArray new];
    }
   
    [tasksArray addObject:task];
    NSData *encodedTasksArray = [NSKeyedArchiver archivedDataWithRootObject:tasksArray requiringSecureCoding:YES error:nil];
    [defaults setObject:encodedTasksArray forKey:tasksType];
    [defaults synchronize];
}

-(void)deleteTaskInUserDefaults:(NSString*)tasksType{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *retrievedData = [defaults objectForKey:tasksType];
    NSError *unarchiveError = nil;
    NSSet<Class> *allowedClasses = [NSSet setWithArray:@[NSArray.class, Task.class,NSDate.class]];
    NSArray <Task*>*retrievedTasksArray;
    if (retrievedData) {
        retrievedTasksArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses fromData:retrievedData error:&unarchiveError];
    } else {
        NSLog(@"No data found in UserDefaults for key %@\n",tasksType);
    }
    if (unarchiveError) {
        NSLog(@"Unarchive Error: %@\n", unarchiveError);
    }

    if (retrievedTasksArray) {
        for (Task *task in retrievedTasksArray) {
            NSLog(@"Retrieved task: %@ with state: %@ priority: %@\n", task.name, task.state,task.priority);
        }
    } else {
        NSLog(@"Failed to retrieve tasks\n");
    }
    ///////////////////////////////////
    NSMutableArray *tasksArray;
    if (retrievedTasksArray) {
        tasksArray = [retrievedTasksArray mutableCopy];
    } else {
        tasksArray = [NSMutableArray new];
    }
    NSUInteger index = [tasksArray indexOfObject:_taskToView];
    if (index != NSNotFound) {
      
        NSLog(@"Task deleted index %lu %@\n",(unsigned long)index,tasksArray[index]);
        [tasksArray removeObjectAtIndex:index];
    } else {
        NSLog(@"Task not found in tasksArray\n");
    }
   
    NSData *encodedTasksArray = [NSKeyedArchiver archivedDataWithRootObject:tasksArray requiringSecureCoding:YES error:nil];
    [defaults setObject:encodedTasksArray forKey:tasksType];
    [defaults synchronize];
}
@end

