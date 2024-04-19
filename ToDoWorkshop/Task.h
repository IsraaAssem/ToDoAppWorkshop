//
//  Task.h
//  ToDoWorkshop
//
//  Created by Israa Assem on 17/04/2024.
//

#ifndef Task_h
#define Task_h


#endif /* Task_h */
@interface Task : NSObject <NSCoding,NSSecureCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *priority;
@property (nonatomic, strong) NSString *taskDescription;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSDate *date;
-(void)encodeWithCoder:(NSCoder *)coder;
- (instancetype)initWithName:(NSString *)name priority:(NSString *)priority taskDescription:(NSString *)taskDescription state:(NSString *)state date:(NSDate *)date;
- (BOOL)isEqual:(id)object;

@end

