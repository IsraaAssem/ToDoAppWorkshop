//
//  Task.m
//  ToDoWorkshop
//
//  Created by Israa Assem on 17/04/2024.
//

#import <Foundation/Foundation.h>
#import "Task.h"
@implementation Task
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.taskDescription forKey:@"taskDescription"];
    [encoder encodeObject:self.state forKey:@"state"];
    [encoder encodeObject:self.date forKey:@"date"];
    [encoder encodeObject:self.priority forKey:@"priority"];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    NSString *name = [aDecoder decodeObjectForKey:@"name"];
    NSString *taskDescription = [aDecoder decodeObjectForKey:@"taskDescription"];
    NSString *state = [aDecoder decodeObjectForKey:@"state"];
    NSDate *date = [aDecoder decodeObjectForKey:@"date"]; // Corrected to decode as NSDate
    NSString *priority = [aDecoder decodeObjectForKey:@"priority"];
    return [self initWithName:name priority:priority taskDescription:taskDescription state:state date:date];
}

- (instancetype)initWithName:(NSString *)name priority:(NSString *)priority taskDescription:(NSString *)taskDescription state:(NSString *)state date:(NSDate *)date {
    self = [super init];
    if (self) {
        _name = name;
        _state =state ;
        _taskDescription=taskDescription;
        _priority=priority;
        _date=date;
    }
    return self;
}


- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[Task class]]) {
        return NO;
    }
    Task *otherTask = (Task *)object;
    return [self.name isEqualToString:otherTask.name] &&
           [self.priority isEqualToString:otherTask.priority] &&
           [self.taskDescription isEqualToString:otherTask.taskDescription] &&
           [self.state isEqualToString:otherTask.state] &&
           [self.date isEqualToDate:otherTask.date];
}
- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + [self.name hash];
    result = prime * result + [self.priority hash];
    // Add other properties that contribute to equality

    return result;
}
@end

