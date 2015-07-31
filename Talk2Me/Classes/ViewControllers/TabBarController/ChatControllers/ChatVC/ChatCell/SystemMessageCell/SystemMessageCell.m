//
//  SystemMessageCell.m
//  Talk2Me
//
//  Created by Yepeng Fan on 12/09/2014.
//

#import "SystemMessageCell.h"

@interface SystemMessageCell()

@end

@implementation SystemMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    SystemMessageCell *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    cell.backgroundColor = [UIColor colorWithWhite:0.943 alpha:1.000];
    
    return cell;
}

@end
