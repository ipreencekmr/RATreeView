//
//  MCLabPackage.m
//  RATreeViewExamples
//
//  Created by mCURA on 26/06/17.
//  Copyright © 2017 com.Augustyniak. All rights reserved.
//

#define notNull(obj) (![obj isKindOfClass:[NSNull class]] && obj != nil)

#import "MCLabPackage.h"

#import "MCLabTest.h"
#import "MCLabGroup.h"
#import "RADataObject.h"

@implementation MCLabPackage

+ (MCLabPackage *)parseResponse:(NSDictionary *)response {
    MCLabPackage *pkg = [[MCLabPackage alloc] init];
    pkg.cost = notNull(response[@"cost"])?[response[@"cost"] stringValue]:@"0";
    pkg.packageId = notNull(response[@"pkgId"])?[response[@"pkgId"] stringValue]:@"0";
    pkg.packageName = notNull(response[@"pkgName"])?response[@"pkgName"]:@"";
    pkg.groupList = [MCLabGroup parseResponseList:response[@"groupList"]];
    pkg.testList = [MCLabTest parseResponseList:response[@"testList"]];
    return pkg;
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
    NSArray *groupChildren = [MCLabGroup parseToRAObjList:self.groupList];
    NSArray *testChildren = [MCLabTest parseToRAObjList:self.testList];
    NSArray *children = [groupChildren arrayByAddingObjectsFromArray:testChildren];
    
    RADataObject *obj = [RADataObject dataObjectWithName:self.packageName children:children];
    obj.labTestNature = kLabObjNaturePackage;
    obj.labTestId = self.packageId;
    obj.labTestCost = self.cost;
    return obj;
}

+ (NSArray *)parseToRAObjList:(NSArray *)parsedResponse {
    NSMutableArray *raObjList = [[NSMutableArray alloc] init];
    for (MCLabPackage *lpObj in parsedResponse) {
        [raObjList addObject:[lpObj raDataObj]];
    }
    return raObjList;
}

#pragma mark- Filter List

+ (NSArray *)filterList:(NSArray *)dataObjList
                forTest:(NSString *)searchTxt {
    
    //filter package matching testName on level3
    NSPredicate *subPredicate = [NSPredicate predicateWithFormat:@"ANY children.labTestName contains[c] %@", searchTxt];
    NSPredicate *searchPredicateLevel3 = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        RADataObject *rdpkgObj = (RADataObject *)evaluatedObject;
        NSArray *fList = [rdpkgObj.children filteredArrayUsingPredicate:subPredicate];
        return (fList.count > 0);
    }];
    NSArray *filteredArrayByLevel3 = [dataObjList filteredArrayUsingPredicate:searchPredicateLevel3];
    
    
    /*-- check if children has type group and groupName matches searchTxt 
         Filter package matching testName on level2
     --*/
    NSPredicate *searchPredicateLevel2 = [NSPredicate predicateWithFormat:@"SUBQUERY(children, $ch, $ch.labTestName contains[c] %@ AND $ch.labTestNature == %d).@count > 0", searchTxt, (long)kLabObjNatureTest];
    NSArray *filteredArrayByLevel2 = [dataObjList filteredArrayUsingPredicate:searchPredicateLevel2];
    
    
    /*-- Remove duplicate values --*/
    NSMutableSet *level3Set = [NSMutableSet setWithArray:filteredArrayByLevel3];
    NSMutableSet *level2Set = [NSMutableSet setWithArray:filteredArrayByLevel2];
    [level3Set unionSet:level2Set];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithSet:level3Set];

    return [orderedSet array];
}

+ (NSArray *)filterList:(NSArray *)dataObjList
               forGroup:(NSString *)searchTxt {
    /*-- check if children has type group and groupName matches searchTxt --*/
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(children, $ch, $ch.labTestName contains[c] %@ AND $ch.labTestNature == %d).@count > 0", searchTxt, (long)kLabObjNatureGroup];
    NSArray *filteredArray = [dataObjList filteredArrayUsingPredicate:searchPredicate];
    return filteredArray;
}

+ (NSArray *)filterList:(NSArray *)dataObjList
             forPackage:(NSString *)searchTxt {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.labTestName CONTAINS[c] %@", searchTxt];
    NSArray *filteredArray = [dataObjList filteredArrayUsingPredicate:searchPredicate];
    return filteredArray;
}

@end
