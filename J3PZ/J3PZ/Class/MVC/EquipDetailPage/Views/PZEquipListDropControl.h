//
//  PZEquipListDropControl.h
//  J3PZ
//
//  Created by 千锋 on 16/1/5.
//  Copyright © 2016年 1111111111. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sendModelValue <NSObject>

-(void)sendEquipListID:(NSString *)equipListID;
-(void)sendEquipListName:(NSString *)equipListName;
@end




@interface PZEquipListDropControl : UIControl

@property(nonatomic,weak)id<sendModelValue>delegate;

-(void)show;
-(void)hide;

-(instancetype)initWithInsideFrame:(CGRect)frame inView:(UIView *)view andXinfa:(NSString *)xinfa andPos:(NSString *)pos;



@end
