
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

#import "RATableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface RATableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *detailedLabel;
@property (weak, nonatomic) IBOutlet UILabel *customTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;

@end

@implementation RATableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectedBackgroundView = [UIView new];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selectButtonHidden = NO;
    self.rowSelected = NO;
}

- (void)setupWithTitle:(NSString *)title
            detailText:(NSString *)detailText
                 level:(NSInteger)level
                nature:(LabObjNature)nature
              selected:(BOOL)selected {
    
    self.customTitleLabel.text = title;
    self.detailedLabel.text = detailText;
    self.selectButton.selected = selected;
    self.customTitleLabel.textColor = [UIColor blackColor];
    self.leadingConstraint.constant = 10.0f + 20 * level;
    
    switch (nature) {
        case kLabObjNatureTest:
            self.customTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0f];
            break;
        case kLabObjNatureGroup:
            self.customTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:17.0f];
            break;
        case kLabObjNaturePackage:
            self.customTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0f];
            break;
        default:
            break;
    }
  
    if (level >= 2) {
        self.selectButton.hidden = true;
    }
}

#pragma mark - Properties

- (void)setRowSelected:(BOOL)rowSelected {
    [self setRowSelected:rowSelected animated:NO];
}

- (void)setRowSelected:(BOOL)rowSelected
              animated:(BOOL)animated {
    _rowSelected = rowSelected;
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        self.selectButton.selected = rowSelected;
    }];
}

- (void)setSelectButtonHidden:(BOOL)selectButtonHidden {
    [self setSelectButtonHidden:selectButtonHidden animated:NO];
}

- (void)setSelectButtonHidden:(BOOL)selectButtonHidden
                     animated:(BOOL)animated {
    _selectButtonHidden = selectButtonHidden;
    [UIView animateWithDuration:animated ? 0.2 : 0 animations:^{
        self.selectButton.hidden = selectButtonHidden;
    }];
}

#pragma mark - Actions

- (IBAction)selectButtonTapAction:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectRow:atIndex:)]) {
        [self.delegate didSelectRow:self atIndex:0];
    }
    
    if (self.selectButtonTapAction) {
        self.selectButtonTapAction(sender);
    }
}

@end
