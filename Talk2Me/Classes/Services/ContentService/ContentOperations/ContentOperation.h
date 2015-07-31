//
//  ContentOperation.h
//  Talk2Me
//
//  Created by Quang Nguyen on 26/08/2014.
//

#import <Foundation/Foundation.h>


typedef void(^TaskResultBlock)(id taskResult);

@interface ContentOperation : NSOperation <QBActionStatusDelegate>

@property (copy, nonatomic) ContentProgressBlock progressHandler;
@property (copy, nonatomic) id completionHandler;

@property (strong, nonatomic) NSObject<Cancelable>*cancelableOperation;

@end
