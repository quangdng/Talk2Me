//
//  BaseService.h
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//

#import <Foundation/Foundation.h>
#import "ServiceProtocol.h"

@interface BaseService : NSObject <ServiceProtocol>

@property (assign, nonatomic, getter = isActive) BOOL active;

- (void)start;
- (void)stop;

@end
