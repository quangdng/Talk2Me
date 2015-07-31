//
//  MainTabBarController.h
//  Talk2Me
//
//  Created by He Gui on 05/09/2014.
//

#import <UIKit/UIKit.h>

@protocol FriendsTabDelegate <NSObject>
@optional
- (void)friendsListTabWasTapped:(UITabBarItem *)tab;
@end


@interface MainTabBarController : UITabBarController <TabBarChatDelegate>

@property (nonatomic, weak) id <TabBarChatDelegate> chatDelegate;
@property (nonatomic, weak) id <FriendsTabDelegate> tabDelegate;

@end
