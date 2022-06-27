//
//  ChatViewController.m
//  Parse Chat
//
//  Created by Jocelyn Tseng on 6/27/22.
//

#import "ChatViewController.h"
#import "ChatCell.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *messageField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL firstFetch;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstFetch = YES;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // setup timer
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:true];
}

- (void)fetchData:(int)limit {
    
    NSLog(@"fetching data");
    
    PFQuery *query = [PFQuery queryWithClassName:@"Message_FBU2021"];

    query.limit = limit;
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"user"];
    
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *msgs, NSError *error) {
        if (msgs != nil) {
            self.arrayOfMsgs = msgs;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (IBAction)didTapSend:(id)sender {
    PFObject *chatMessage = [PFObject objectWithClassName:@"Message_FBU2021"];
    chatMessage[@"text"] = self.messageField.text;
    chatMessage[@"user"] = PFUser.currentUser;
    
    if (chatMessage[@"user"] == nil) {
        NSLog(@"current user is nil");
    }

    [chatMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (succeeded) {
                NSLog(@"The message was saved!");
                self.messageField.text = @"";
            } else {
                NSLog(@"Problem saving message: %@", error.localizedDescription);
            }
        }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell"];
    
    PFObject* chatMessage = self.arrayOfMsgs[indexPath.row];
    
    PFUser *user = chatMessage[@"user"];
    if (user != nil) {
        // User found! update username label with username
        cell.usernameLabel.text = user.username;
//        NSLog(cell.usernameLabel.text);
        
    } else {
        // No user found, set default username
        cell.usernameLabel.text = @"🤖";
    }
    
    NSString* msgText = chatMessage[@"text"];
    if (msgText != nil) {
        // message found
        cell.msgLabel.text = msgText;
    } else {
        cell.msgLabel.text = @"No message";
    }
//
//    NSLog(@"PRINTING MSG AND USERNAME");
//    NSLog(cell.msgLabel.text);
//    NSLog(cell.usernameLabel.text);
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayOfMsgs.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)onTimer {
    if (self.firstFetch == YES) {
        [self fetchData:0];
        self.firstFetch = NO;
    }
    else {
        [self fetchData:20];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
