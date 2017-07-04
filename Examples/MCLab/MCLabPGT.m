//
//  MCLabPGT.m
//  TreeStructure
//
//  Created by mCURA on 29/06/17.
//  Copyright © 2017 Madhu Naidu. All rights reserved.
//

#import "MCLabPGT.h"
#import "RADataObject.h"

@implementation MCLabPGT

- (NSArray *)dataList {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [list addObjectsFromArray:self.pkgs];
    [list addObjectsFromArray:self.grps];
    [list addObjectsFromArray:self.tsts];
    return list;
}

- (NSArray *)filterForTest:(NSString *)searchTxt {
    MCLabPGT *pgt = [[MCLabPGT alloc] init];
    pgt.tsts = [MCLabTest filterList:self.tsts forTest:searchTxt];
    pgt.grps = [MCLabGroup filterList:self.grps forTest:searchTxt];
    pgt.pkgs = [MCLabPackage filterList:self.pkgs forTest:searchTxt];
    return pgt.dataList;
}

- (NSArray *)filterForGroup:(NSString *)searchTxt {
    MCLabPGT *pgt = [[MCLabPGT alloc] init];
    pgt.tsts = @[];
    pgt.grps = [MCLabGroup filterList:self.grps forGroup:searchTxt];
    pgt.pkgs = [MCLabPackage filterList:self.pkgs forGroup:searchTxt];
    return pgt.dataList;
}

- (NSArray *)filterForPackage:(NSString *)searchTxt {
    MCLabPGT *pgt = [[MCLabPGT alloc] init];
    pgt.tsts = @[];
    pgt.grps = @[];
    pgt.pkgs = [MCLabPackage filterList:self.pkgs forPackage:searchTxt];
    return pgt.dataList;
}

- (NSDictionary *)postJson {
    NSMutableDictionary *postJson = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *selectedTests = [[NSMutableArray alloc] init];
    NSMutableArray *selectedGroups = [[NSMutableArray alloc] init];
    NSMutableArray *selectedPackages = [[NSMutableArray alloc] init];
    
    NSString *testIdKey = @"testId";
    NSString *grpIdKey = @"grpId";
    NSString *pkgIdKey = @"pkgId";
    NSString *costKey = @"cost";
    
    for (RADataObject *test in self.tsts) {
        if (test.selected) {
            
            NSMutableDictionary *testJson = [[NSMutableDictionary alloc] init];
            
            [testJson setObject:test.labTestId forKey:testIdKey];
            [testJson setObject:test.labTestCost forKey:costKey];
            [testJson setObject:@"0" forKey:grpIdKey];
            [testJson setObject:@"0" forKey:pkgIdKey];
            
            [selectedTests addObject:testJson];
        }
    }
    
    for (RADataObject *group in self.grps) {
        if (group.selected) {
            
            NSMutableDictionary *grpJson = [[NSMutableDictionary alloc] init];
            
            [grpJson setObject:group.labTestId forKey:grpIdKey];
            [grpJson setObject:group.labTestCost forKey:costKey];
            [grpJson setObject:@"0" forKey:pkgIdKey];

            [selectedGroups addObject:grpJson];
        }else {
            for (RADataObject *test in group.children) {
                if (test.selected) { //only those test whose parent is not selected
                    
                    NSMutableDictionary *testJson = [[NSMutableDictionary alloc] init];
                    
                    [testJson setObject:test.labTestId forKey:testIdKey];
                    [testJson setObject:test.labTestCost forKey:costKey];
                    [testJson setObject:group.labTestId forKey:grpIdKey];
                    [testJson setObject:@"0" forKey:pkgIdKey];
                    
                    [selectedTests addObject:testJson];
                }
            }
        }
    }
    
    for (RADataObject *package in self.pkgs) {

        if (package.selected) {
            
            NSMutableDictionary *pkgJson = [[NSMutableDictionary alloc] init];
            [pkgJson setObject:package.labTestId forKey:pkgIdKey];
            [pkgJson setObject:package.labTestCost forKey:costKey];

            [selectedPackages addObject:pkgJson];
        }else {
            for (RADataObject *group in package.children) {
                
                if (group.selected) { //only those group whose parent is not selected
                 
                    NSMutableDictionary *grpJson = [[NSMutableDictionary alloc] init];
                    
                    [grpJson setObject:group.labTestId forKey:grpIdKey];
                    [grpJson setObject:group.labTestCost forKey:costKey];
                    [grpJson setObject:package.labTestId forKey:pkgIdKey];
                    
                    [selectedGroups addObject:grpJson];
                }
            }
        }
    }

    [postJson setObject:selectedTests forKey:@"labOrderTest"];
    [postJson setObject:selectedGroups forKey:@"labOrderGroup"];
    [postJson setObject:selectedPackages forKey:@"labOrderPackage"];
    [postJson setObject:@"268" forKey:@"userRoleId"];
    [postJson setObject:@"205" forKey:@"labFacilityId"];
    [postJson setObject:@"449" forKey:@"mrNo"];
    
    return postJson;
    
    /*
    {
        labFacilityId = 205;
        labOrderGroup =     (
                             {
                                 cost = 200;
                                 grpId = 176;
                                 pkgId = 0;
                             }
                             );
        labOrderPackage =     (
                               {
                                   cost = 200;
                                   pkgId = 71;
                               }
                               );
        labOrderTest =     (
                            {
                                cost = 200;
                                grpId = 0;
                                pkgId = 0;
                                testId = 526;
                            },
                            {
                                cost = 250;
                                grpId = 0;
                                pkgId = 0;
                                testId = 558;
                            },
                            {
                                cost = 250;
                                grpId = 177;
                                pkgId = 0;
                                testId = 558;
                            }
                            );
        mrNo = 449;
        userRoleId = 268;
    }
    */
    
    
    /*
    Req: mcuradev.dlinkddns.com/testtnmcura/health_dev.svc/Json/PostLabGrpTestOrder_v2
    POST:{
        "LabOrderTests" : [
                           {
                               "cost":"100";
                               "LabGrpId" : "156",
                               "TestId" : "145"
                           },
                           {
                               "LabGrpId" : "156",
                               "TestId" : "148"
                           }
                           ],
        "UserRoleID" : "268",
        "LabOrderGrps" : [
                          {
                              "LabGrpId" : "160"
                          }
                          ],
        "LabFacility" : "205",
        "Mrno" : "449"
    }
    */
    
}

@end
