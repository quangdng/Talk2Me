//
//  CornerButton.m
//  Talk2Me
//
//  Created by Tian Long on 13/10/2014.
//

#import "CornerButton.h"

@implementation CornerButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.cornerRadius = 10;
}

@end
