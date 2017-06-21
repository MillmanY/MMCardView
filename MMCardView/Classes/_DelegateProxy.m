//
//  _DelegateProxy.m
//  Pods
//
//  Created by Millman YANG on 2017/6/21.
//
//

#import "_DelegateProxy.h"

BOOL method_signature_void(NSMethodSignature * __nonnull methodSignature) {
    const char *methodReturnType = methodSignature.methodReturnType;
    return strcmp(methodReturnType, @encode(void)) == 0;
}


@interface _DelegateProxy () {
    id __weak __forwardToDelegate;
}
@end

@implementation _DelegateProxy

-(id)_forwardToDelegate {
    return __forwardToDelegate;
}

-(BOOL)respondsToSelector:(SEL)aSelector {
    
    return [self._forwardToDelegate respondsToSelector:aSelector] || [super respondsToSelector:aSelector];
}

-(void)setForward:(id __nullable)forwardDelegate {
    __forwardToDelegate = forwardDelegate;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (self.parent && [self.parent respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.parent];
    } else if (self._forwardToDelegate && [self._forwardToDelegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self._forwardToDelegate];
    }
}

-(void)_methodInvoked:(SEL)selector {
    
}
@end
