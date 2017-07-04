//
//  MCLabTest.h
//  RATreeViewExamples
//
//  Created by mCURA on 26/06/17.
//  Copyright © 2017 com.Augustyniak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCLabTest : NSObject

@property (nonatomic, strong) NSString *testId;

@property (nonatomic, strong) NSString *testName;

@property (nonatomic, strong) NSString *cost;

@property (nonatomic, strong) NSString *testInstId;

@property (nonatomic, strong) NSString *testInstruction;

+ (NSArray *)parseResponseList:(NSArray *)responseList;

+ (NSArray *)parseToRAObjList:(NSArray *)parsedResponse;

+ (NSArray *)filterList:(NSArray *)dataObjList
                forTest:(NSString *)searchTxt;

@end
