//
//  ViewController.m
//  1-Http
//
//  Created by jameswatt on 16/1/18.
//  Copyright © 2016年 xuzhixiang. All rights reserved.
//

// IOS6 CFNet 最底层的网络框架（类库）
//  iOS 7 开始的  NSURLConnection
// iOS8的时候 出了一个新的 请求类 NSUrlSesstion

//ASIHttpRequest 11年以前(ASI)

//网络框架
//AFNetWorking（好用，简单）1.0（）----2.0(11-16年，其实就是对NSURLConnection的一个封装)------3.0（15年出的，其实就是对它的NSUrlSesstion一个封装）

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,NSURLConnectionDataDelegate>

@property (nonatomic ,strong) NSMutableArray *dataSource;
@property (nonatomic ,strong) UITableView *tableView;

@property (nonatomic ,strong) UIRefreshControl *refresh;

//请求的链接
@property (nonatomic ,strong) NSURLConnection *connection;
//存放请求回来的数据
@property (nonatomic ,strong) NSMutableData *data;

@end

@implementation ViewController


// main 程序的主线程，所有的UI操作都在主线程。

//同步的请求 如果请求持续的时间比较长（耗时操作），会卡死界面.(在主线程里面执行)
//异步的请求 做耗时操作时，不会卡死界面。（因为没有在主线程里面运行）


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //创建数组
    _dataSource = [NSMutableArray new];
    
    
    //先去请求数据
    [self loadDataSource];
    
    //创建tableview
    [self createTableView];
}

- (void)loadDataSource {
    //发起一个同步请求
    
    //    http://10.0.8.8/sns/my/user_list.php
    
    // 用 NSURl  来表示一个URL
    // http://jameswatt.local/world.jpg
    NSURL *url = [NSURL URLWithString:@"http://10.0.8.8/sns/my/user_list.php"];
    //第三个参数是 超时时间  移动网络下，超时时间 设置为60s
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    //代理的方式  也是异步
    _connection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self startImmediately:YES];
    //立即启动
    [_connection start];

    //如果是xcode7 会提示请求不安全  App Transport Security,苹果建议都用安全的https 请求。
    //http，安全的是https
    
    //解决方法
    //    1.    在Info.plist中添加NSAppTransportSecurity类型Dictionary。
    //    2.    在NSAppTransportSecurity下添加NSAllowsArbitraryLoads类型Boolean,值设为YES
    


}

//
- (void)createTableView {
    UITableView *tableVeiw = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    tableVeiw.delegate = self;
    tableVeiw.dataSource = self;
    [self.view addSubview:tableVeiw];
    
    self.tableView = tableVeiw;
    
    //增加下拉刷新
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    self.refresh = refresh;
    
}
- (void)refresh:(UIRefreshControl*)sender {
    //判断刷新控件的状态
    if (sender.isRefreshing) {
        //清空数据
        [self.dataSource removeAllObjects];
        //重新请求
        [self loadDataSource];

    }
    NSLog(@"下拉刷新");

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    //取出数据 model
    UserModel *user = self.dataSource[indexPath.row];
    
//    //拼出图片的地址
//    NSString *headImagUrlStr = [NSString stringWithFormat:@"http://10.0.8.8/sns%@",user.headimage];
//    //同步的请求
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:headImagUrlStr]];
//    cell.imageView.image = [UIImage imageWithData:data];
    
    cell.textLabel.text = user.username;
    

    
    
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response {
//    
//}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"收到响应");
    
    //初始化 二进制数据
    _data = [NSMutableData new];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"已经收到数据");
    // 这个方法有可能不止执行一次，数据量大的时候会执行很多次
    [self.data appendData:data];
}

//- (nullable NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request;
//- (void)connection:(NSURLConnection *)connection   didSendBodyData:(NSInteger)bytesWritten
// totalBytesWritten:(NSInteger)totalBytesWritten
//totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
//
//- (nullable NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"完成下载");
    //下载完成  解析数据
        //解析 数据
        NSDictionary * jsonObj = [NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"json解析数据 %@",jsonObj);
        //如果我们跟服务器人员交流的话，要要求他们返回什么样类型的数据
        NSNumber *count = jsonObj[@"count"];
        NSString *totalcount = jsonObj[@"totalcount"];
        NSArray *users = jsonObj[@"users"];
        NSLog(@"%ld",users.count);
        //加载数据源
        for (NSDictionary *dictItem in users) {
            UserModel *user = [UserModel new];
            user.username = dictItem[@"username"];
            user.headimage = dictItem [@"headimage"];
            user.uid = dictItem [@"uid"];
            [self.dataSource addObject:user];
        }
    //结束刷新
//    [sender endRefreshing];
    
    //刷新界面
    [self.tableView reloadData];
}


@end
