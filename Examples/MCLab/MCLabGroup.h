//
//  MCLabGroup.h
//  RATreeViewExamples
//
//  Created by mCURA on 26/06/17.
//  Copyright © 2017 com.Augustyniak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCLabGroup : NSObject

@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) NSString *groupName;

@property (nonatomic, strong) NSString *cost;

@property (nonatomic, strong) NSArray *testList;

+ (NSArray *)parseResponseList:(NSArray *)responseList;

+ (NSArray *)parseToRAObjList:(NSArray *)parsedResponse;

+ (NSArray *)filterList:(NSArray *)dataObjList
                forTest:(NSString *)searchTxt;

+ (NSArray *)filterList:(NSArray *)dataObjList
               forGroup:(NSString *)searchTxt;

@end
