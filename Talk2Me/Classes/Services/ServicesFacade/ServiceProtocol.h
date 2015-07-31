//
//  ServiceProtocol.h
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//

@protocol ServiceProtocol <NSObject>

@property (assign, nonatomic, getter = isActive) BOOL active;

- (void)start;
- (void)stop;

@end
