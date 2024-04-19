//
//  TestViewController.h
//  ToDoWorkshop
//
//  Created by Israa Assem on 17/04/2024.
//

#import <UIKit/UIKit.h>
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController<UITextFieldDelegate>
@property NSString *source;
@property Task*taskToView;
@end

NS_ASSUME_NONNULL_END
