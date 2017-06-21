//
//  _DelegateProxy.h
//  Pods
//
//  Created by Millman YANG on 2017/6/21.
//
//

#import <Foundation/Foundation.h>

@interface _DelegateProxy : NSObject
@property (nonatomic, weak) id parent;
@property (nonatomic, weak, readonly) id _forwardToDelegate;
-(void)setForward:(id __nullable)forwardDelegate;
-(void)_methodInvoked:(SEL)selector;
@end
