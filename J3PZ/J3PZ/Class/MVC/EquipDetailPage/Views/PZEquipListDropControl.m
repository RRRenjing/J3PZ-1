//
//  PZEquipListDropControl.m
//  J3PZ
//
//  Created by 千锋 on 16/1/5.
//  Copyright © 2016年 1111111111. All rights reserved.
//

#import "PZEquipListDropControl.h"
#import "PZEquipModel.h"
#import "PZEquipViewController.h"
#import "PZNetworkingManager.h"
#import "PZEquipDetailViewController.h"
#define CELL_HEIGHT 25

@interface PZEquipListDropControl ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,weak)UIView * sView;
@property(nonatomic,strong)UIImageView * dropImageView;
@property(nonatomic,assign)CGRect imageFrame;
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)PZNetworkingManager * manager;
@property(nonatomic,strong)NSMutableArray * equipListArray;
@property(nonatomic,strong)NSString * xinfa;
@property(nonatomic,strong)NSString * pos;
@end


@implementation PZEquipListDropControl

-(PZNetworkingManager *)manager{
    if (!_manager) {
        _manager = [PZNetworkingManager manager];
    }
    return _manager;
}



-(instancetype)initWithInsideFrame:(CGRect)frame inView:(UIView *)view andXinfa:(NSString *)xinfa andPos:(NSString *)pos{
    
    if (self = [super init]) {
        self.frame = [UIScreen mainScreen].bounds;
        self.xinfa = xinfa;
        self.pos = pos;
        self.sView = view;
        self.imageFrame = frame;
        self.dropImageView = [[UIImageView alloc]init];
        self.dropImageView.frame = frame;
        self.dropImageView.image = [[UIImage imageNamed:@"popover_background"] stretchableImageWithLeftCapWidth:3 topCapHeight:10];
        [self addSubview:self.dropImageView];
        self.dropImageView.userInteractionEnabled = YES;

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self requestData];
        });
    
        [self createTableView];
    }
    
    return self;
}
#pragma mark -设置下拉框的弹出以及收回
-(void)show{
    [self.sView addSubview:self];
//    self.userInteractionEnabled = NO;
    //获取尺寸
    CGRect rect = self.imageFrame;
    //高度置为0
   
    rect.size.height = 0;
    self.dropImageView.frame = rect;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:6 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.dropImageView.frame =self.imageFrame;
    } completion:^(BOOL finished) {
        self.userInteractionEnabled =YES;
    }];
}
-(void)hide{
    CGRect rect = self.imageFrame;
    rect.size.height = 0;
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.dropImageView.frame = rect;
    }completion:^(BOOL finished) {
        [self dismiss];
        self.userInteractionEnabled = YES;
    }];
}
-(void)dismiss{
    [self removeFromSuperview];
}

#pragma mark - createTableView

-(void)createTableView{

    CGRect rect = CGRectMake(CGRectGetMinX(self.imageFrame), CGRectGetMinY(self.imageFrame), CGRectGetWidth(self.imageFrame), CGRectGetHeight(self.imageFrame));
    self.imageFrame = rect;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(5, 15, self.imageFrame.size.width - 10, self.imageFrame.size.height-20)];
    [self.dropImageView addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor  clearColor];
    self.tableView.clipsToBounds = YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%lu",self.equipListArray.count);
    return self.equipListArray.count;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    cell.backgroundColor = [UIColor clearColor];
    PZEquipModel * model = _equipListArray[indexPath.row];
    cell.textLabel.text = model.name;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PZEquipModel * model = _equipListArray[indexPath.row];
    NSLog(@"%@",model.name);
    if ([self.delegate respondsToSelector:@selector(sendEquipListID:)]) {
        [self.delegate sendEquipListID:model.Id];
    }
//    PZEquipDetailViewController * equipDetailVC = [[PZEquipDetailViewController alloc]init];
    
    [self hide];
    
}
#pragma mark - requestData
-(void)requestData{
    NSString * equipListPath = [[NSString alloc]initWithFormat:PZEquipURL,self.pos ,self.xinfa];
    
    [self.manager GET:equipListPath success:^(NSURLResponse *response, NSData *data) {
        NSArray * responseArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        if (!_equipListArray) {
            _equipListArray = [NSMutableArray array];
        }
        for (NSDictionary * equip in responseArray) {
            PZEquipModel * model = [[PZEquipModel alloc]init];
            [model setValuesForKeysWithDictionary:equip];
            [_equipListArray addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    } failure:^(NSURLResponse *response, NSError *error) {
        
    }];
//    NSString * enhanceListPath = [[NSString alloc]initWithFormat:PZEnhanceURL,_equipIndex,_xinfa];
//    [self.manager GET:enhanceListPath success:^(NSURLResponse *response, NSData *data) {
//        NSArray * responseArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        if (!_enhanceListArray) {
//            _enhanceListArray = [NSMutableArray array];
//        }
//        for (NSDictionary * equip in responseArray) {
//            PZEnhanceModel * model = [[PZEnhanceModel alloc]init];
//            [model setValuesForKeysWithDictionary:equip];
//            [_enhanceListArray addObject:model];
//        }
//    } failure:^(NSURLResponse *response, NSError *error) {
//        
//    }];
}




@end
