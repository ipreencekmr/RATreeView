//
//  MCLabTest.m
//  RATreeViewExamples
//
//  Created by mCURA on 26/06/17.
//  Copyright © 2017 com.Augustyniak. All rights reserved.
//

#define notNull(obj) (![obj isKindOfClass:[NSNull class]] && obj != nil)

#import "MCLabTest.h"
#import "RADataObject.h"

@implementation MCLabTest

+ (MCLabTest *)parseResponse:(NSDictionary *)response {
    MCLabTest *labTest = [[MCLabTest alloc] init];
    labTest.cost = notNull(response[@"cost"])?[response[@"cost"] stringValue]:@"0";
    labTest.testId = notNull(response[@"testId"])?[response[@"testId"] stringValue]:@"0";
    labTest.testInstId = notNull(response[@"testInsId"])?[response[@"testInsId"] stringValue]:@"0";
    labTest.testName = notNull(response[@"testName"])?response[@"testName"]:@"";
    labTest.testInstruction = notNull(response[@"testInstruction"])?response[@"testInstruction"]:@"";
    return labTest;
}

+ (NSArray *)parseResponseList:(NSArray *)responseList {
    NSMutableArray *parsedResponse = [[NSMutableArray alloc] init];
    for (NSDictionary *response in responseList) {
        [parsedResponse addObject:[MCLabTest parseResponse:response]];
    }
    return parsedResponse;
}

#pragma mark- Getting RADataObj

- (RADataObject *)raDataObj {
    RADataObject *obj = [RADataObject dataObjectWithName:self.testName children:nil];
    obj.labTestNature = kLabObjNatureTest;
    obj.labTestId = self.testId;
    obj.labTestInsId = self.testInstId;
    obj.labTestInstruction = self.testInstruction;
    obj.labTestCost = self.cost;
    return obj;
}

+ (NSArray *)parseToRAObjList:(NSArray *)parsedResponse {
    NSMutableArray *raObjList = [[NSMutableArray alloc] init];
    for (MCLabTest *ltObj in parsedResponse) {
        [raObjList addObject:[ltObj raDataObj]];
    }
    return raObjList;
}

#pragma mark- Filter List

+ (NSArray *)filterList:(NSArray *)dataObjList
                forTest:(NSString *)searchTxt {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.labTestName CONTAINS[c] %@", searchTxt];
    NSArray *filteredArray = [dataObjList filteredArrayUsingPredicate:searchPredicate];
    return filteredArray;
}

@end
