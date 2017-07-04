
//
//  MCLabGroup.m
//  RATreeViewExamples
//
//  Created by mCURA on 26/06/17.
//  Copyright © 2017 com.Augustyniak. All rights reserved.
//

#define notNull(obj) (![obj isKindOfClass:[NSNull class]] && obj != nil)

#import "MCLabGroup.h"
#import "MCLabTest.h"
#import "RADataObject.h"

@implementation MCLabGroup

+ (MCLabGroup *)parseResponse:(NSDictionary *)response {
    MCLabGroup *group = [[MCLabGroup alloc] init];
    group.cost = notNull(response[@"cost"])?[response[@"cost"] stringValue]:@"0";
    group.groupId = notNull(response[@"grpId"])?[response[@"grpId"] stringValue]:@"0";
    group.groupName = notNull(response[@"grpName"])?response[@"grpName"]:@"";
    group.testList = [MCLabTest parseResponseList:response[@"testList"]];
    return group;
}

+ (NSArray *)parseResponseList:(NSArray *)responseList {
    NSMutableArray *parsedResponse = [[NSMutableArray alloc] init];
    for (NSDictionary *response in responseList) {
        [parsedResponse addObject:[self parseResponse:response]];
    }
    return parsedResponse;
}

#pragma mark- Getting RADataObj

- (RADataObject *)raDataObj {
    NSArray *parsedChildren = [MCLabTest parseToRAObjList:self.testList];
    RADataObject *obj = [RADataObject dataObjectWithName:self.groupName
                                                children:parsedChildren];
    obj.labTestNature = kLabObjNatureGroup;
    obj.labTestId = self.groupId;
    obj.labTestCost = self.cost;
    return obj;
}

+ (NSArray *)parseToRAObjList:(NSArray *)parsedResponse {
    NSMutableArray *raObjList = [[NSMutableArray alloc] init];
    for (MCLabGroup *lgObj in parsedResponse) {
        [raObjList addObject:[lgObj raDataObj]];
    }
    return raObjList;
}

#pragma mark- Filter List

+ (NSArray *)filterList:(NSArray *)dataObjList
                forTest:(NSString *)searchTxt {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"ANY SELF.children.labTestName contains[c] %@", searchTxt];
    NSArray *filteredArray = [dataObjList filteredArrayUsingPredicate:searchPredicate];
    return filteredArray;
}

+ (NSArray *)filterList:(NSArray *)dataObjList
               forGroup:(NSString *)searchTxt {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.labTestName CONTAINS[c] %@", searchTxt];
    NSArray *filteredArray = [dataObjList filteredArrayUsingPredicate:searchPredicate];
    return filteredArray;
}

@end
