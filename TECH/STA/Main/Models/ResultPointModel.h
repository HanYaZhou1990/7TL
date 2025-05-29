//
//  ResultPointModel.h
//  STA
//
//  Created by admin on 2024/12/26.
//

#import <Foundation/Foundation.h>
@class ResultParserDicModel;

NS_ASSUME_NONNULL_BEGIN

/*! 扫码就够 */
@interface ResultPointModel : NSObject

@property (nonatomic, strong) NSArray <NSDictionary *> *ResultPoint;
@property (nonatomic, strong) NSString *formatValue;
@property (nonatomic, strong) ResultParserDicModel *parserDic;

@end

@interface ResultParserDicModel : NSObject

@property (nonatomic, strong) NSString *result;

@end

NS_ASSUME_NONNULL_END
