
//The MIT License (MIT)
//
//Copyright (c) 2014 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "RAViewController.h"
#import "RADataObject.h"
#import "RATableViewCell.h"
#import "MCLabTest.h"
#import "MCLabGroup.h"
#import "MCLabPackage.h"

@interface RAViewController () <RATreeViewDelegate, RATreeViewDataSource, UISearchBarDelegate, RASelectCellAction>

@property (nonatomic, strong) NSArray *data;

@property (nonatomic, strong) NSArray *filteredList;

@property (nonatomic, strong) UIBarButtonItem *editButton;

@property (nonatomic, strong) MCLabPGT *pgt;

@property (nonatomic, assign) BOOL isSearchOn;

@end

@implementation RAViewController

- (void)viewDidLoad {
    
  [super viewDidLoad];
  
  [self loadData];
  
  self.searchBar.delegate = self;
  self.treeView.delegate = self;
  self.treeView.dataSource = self;
  self.treeView.treeFooterView = [UIView new];
  self.treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    self.treeView.separatorColor = UIColorFromRGB(0xcccccc);

  UIRefreshControl *refreshControl = [UIRefreshControl new];
  [refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
  [self.treeView.scrollView addSubview:refreshControl];
  
  [self.navigationController setNavigationBarHidden:NO];
  self.navigationItem.title = NSLocalizedString(@"Things", nil);
  
  [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([RATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RATableViewCell class])];
    
  [self.treeView reloadData];
  [self.treeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  int systemVersion = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue];
  if (systemVersion >= 7 && systemVersion < 8) {
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
    self.treeView.scrollView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
    self.treeView.scrollView.contentOffset = CGPointMake(0.0, -heightPadding);
  }
}

#pragma mark - Actions 

- (void)refreshControlChanged:(UIRefreshControl *)refreshControl {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [refreshControl endRefreshing];
  });
}

#pragma mark TreeView Delegate methods

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
   return 44;
}

- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item {
   return YES;
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
  //RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
  //RADataObject *parent = [self.treeView parentForItem:item];
  //[cell setSelectButtonHidden:YES animated:YES];
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item {
  //RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
  //[cell setSelectButtonHidden:NO animated:YES];
}

#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item {
  
    RADataObject *dataObject = item;

    NSInteger level = [self.treeView levelForCellForItem:item];
    NSInteger numberOfChildren = [dataObject.children count];

    NSString *detailText = @"";
    if (dataObject.labTestNature == kLabObjNatureTest) {
        detailText = dataObject.labTestInstruction;
    }else {
        detailText = [NSString localizedStringWithFormat:@"(%@)", [@(numberOfChildren) stringValue]];
    }
   
    //BOOL expanded = [self.treeView isCellForItemExpanded:item];

    RATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([RATableViewCell class])];
    [cell setupWithTitle:dataObject.labTestName detailText:detailText level:level nature:dataObject.labTestNature selected:dataObject.selected];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;

    return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item {
    
  if (item == nil) {
    return (self.isSearchOn)?[self.filteredList count]:[self.data count];
  }
  
  RADataObject *data = item;
  return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item {
    
  if (item == nil) {
      return (self.isSearchOn)?[self.filteredList objectAtIndex:index]:[self.data objectAtIndex:index];
  }
  
  RADataObject *data = item;
  return data.children[index];
}

#pragma mark - Helpers 

- (void)loadData {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"LAB" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                             options:kNilOptions error:nil];
    
    NSDictionary *responseData = response[@"data"];
    NSArray *parsedPackageList = [MCLabPackage parseResponseList:responseData[@"package"]];
    NSArray *parsedGroupList = [MCLabGroup parseResponseList:responseData[@"group"]];
    NSArray *parsedTestList = [MCLabTest parseResponseList:responseData[@"test"]];
   
    NSArray *raDataList1 = [MCLabPackage parseToRAObjList:parsedPackageList];
    NSArray *raDataList2 = [MCLabGroup parseToRAObjList:parsedGroupList];
    NSArray *raDataList3 = [MCLabTest parseToRAObjList:parsedTestList];
    
    self.pgt = [[MCLabPGT alloc] init];
    self.pgt.pkgs = raDataList1;
    self.pgt.grps = raDataList2;
    self.pgt.tsts = raDataList3;

    NSLog(@"response %@",response);

    self.data = self.pgt.dataList; //[NSArray arrayWithObjects:package1,package2,group6,group7,nil];
}

#pragma mark- UISearchBar delegate

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *searchTxt = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    [self searchInSearchBar:searchBar forSearchTxt:searchTxt];
    return true;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    NSString *searchTxt = searchBar.text;
    [self searchInSearchBar:searchBar forSearchTxt:searchTxt];
}

- (void)searchInSearchBar:(UISearchBar *)searchBar
             forSearchTxt:(NSString *)searchTxt {
    
    switch (searchBar.selectedScopeButtonIndex) {
        case 0: { //Search Test
            self.filteredList = [self.pgt filterForTest:searchTxt];
        }
            break;
        case 1: { //Search Group
            self.filteredList = [self.pgt filterForGroup:searchTxt];
        }
            break;
        case 2: { //Search package
            self.filteredList = [self.pgt filterForPackage:searchTxt];
        }
            break;
    }
    
    [self.treeView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.isSearchOn = true;
    [searchBar setShowsCancelButton:true animated:true];
    return true;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.isSearchOn = false;
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:false animated:true];
    [self.treeView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark- RowSelect delegate

-(void)didSelectRow:(RATableViewCell *)cell
            atIndex:(NSInteger)index {
    
    RADataObject *dataObject = (RADataObject *)[self.treeView itemForCell:cell];
    
    NSInteger level = [self.treeView levelForCellForItem:dataObject];
    
    dataObject.selected = !dataObject.selected;
    [cell setRowSelected:dataObject.selected];
    
    switch (dataObject.labTestNature) {
        case kLabObjNaturePackage:{
            [self selectChildrenObjAtCell:cell
                                  ForItem:dataObject];
        }
            break;
        case kLabObjNatureGroup:{
            switch (level) {
                case 0:{
                    [self selectChildrenObjAtCell:cell
                                          ForItem:dataObject];
                }
                    break;
                case 1:{
                    [self selectParentObjForItem:dataObject];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case kLabObjNatureTest:{
            switch (level) {
                case 0:
                    break;
                case 1:
                    [self selectParentObjForItem:dataObject];
                    break;
                case 2:
                    [self selectParentObjForItem:dataObject];
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    NSLog(@"selected %d",cell.rowSelected);
}

-(void)selectParentObjForItem:(RADataObject *)dataObject{
    BOOL isAllSelected = true;
    
    RADataObject *parentObj = [self.treeView parentForItem:dataObject];
    for(RADataObject *obj in parentObj.children){
        if(![obj selected])
            isAllSelected = false;
    }
    
    RATableViewCell *cellObj =  (RATableViewCell *)[self.treeView cellForItem:parentObj];
    
    parentObj.selected = isAllSelected;
    [cellObj setRowSelected:parentObj.selected];
}

-(void)selectChildrenObjAtCell:(RATableViewCell *)cell
                       ForItem:(RADataObject *)dataObject{
    for(RADataObject *obj in dataObject.children){
        obj.selected = dataObject.selected;
        
        RATableViewCell *cellObj =  (RATableViewCell *)[self.treeView cellForItem:obj];
        
        if([self.treeView isCellExpanded:cell]){
            [cellObj setRowSelected:obj.selected];
        }
    }
}


- (IBAction)printPost:(id)sender {
    NSLog(@" postJson %@",[self.pgt postJson]);
}

@end
