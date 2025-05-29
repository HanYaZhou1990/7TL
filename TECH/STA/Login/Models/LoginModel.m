//
//  LoginModel.m
//  TECH
//
//  Created by 韩亚周 on 2021/6/23.
//

#import "LoginModel.h"

@implementation LoginModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:YYD(@"STAUP")];
        NSLog(@"%@",dic);
        //self.username = @"admin";
        //self.password = @"piglet529";
        [self yy_modelSetWithDictionary:dic];
        if (!self.usercode) {
            self.usercode = @"";
        }
        if (!self.JSESSIONID) {
            self.JSESSIONID = @"";
        }
        self.clienttype = 2;
        _first = @"";
        _biology = @"close";
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"username":@"user.usercode",@"password":@"user.password"};
}

@end
