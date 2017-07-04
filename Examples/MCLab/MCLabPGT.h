//
//  MCLabPGT.h
//  TreeStructure
//
//  Created by mCURA on 29/06/17.
//  Copyright © 2017 Madhu Naidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCLabTest.h"
#import "MCLabGroup.h"
#import "MCLabPackage.h"

@interface MCLabPGT : NSObject

@property (nonatomic, strong) NSArray *pkgs;

@property (nonatomic, strong) NSArray *grps;

@property (nonatomic, strong) NSArray *tsts;

@property (nonatomic, strong, readonly) NSArray *dataList;

- (NSArray *)filterForTest:(NSString *)searchTxt;

- (NSArray *)filterForGroup:(NSString *)searchTxt;

- (NSArray *)filterForPackage:(NSString *)searchTxt;

- (NSDictionary *)postJson;

@end
