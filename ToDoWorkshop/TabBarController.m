//
//  TabBarController.m
//  ToDoWorkshop
//
//  Created by Israa Assem on 17/04/2024.
//

#import "TabBarController.h"
#import "DetailsViewController.h"
@interface TabBarController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *plusBtn;

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;

    // Do any additional setup after loading the view.
}
- (IBAction)goToAddScrean:(id)sender {
    DetailsViewController * detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    detailVC.source=@"add";
    [self.navigationController pushViewController:detailVC animated:YES];
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
        if (viewController == [tabBarController.viewControllers objectAtIndex:0]) {
            _plusBtn.hidden=NO;
        } else {
            _plusBtn.hidden=YES;
        }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
