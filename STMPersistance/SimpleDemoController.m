//
//  SimpleDemoController.m
//  STMPersistance
//
//  Created by iosci on 2017/3/25.
//  Copyright © 2017年 secoo. All rights reserved.
//

#import "SimpleDemoController.h"

static NSString * const kMeetingClassName = @"Meeting";

@interface SimpleDemoController ()

@property (nonatomic, strong) NSArray<STMObject<id<Meeting>> *> *meetings;

@end

@implementation SimpleDemoController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self _fetchMeetings];
}

- (void)_fetchMeetings {
  [STMObject<id<Meeting>> asyncFetchAllFrom:kMeetingClassName completion:^(NSArray * _Nonnull lists) {
    self.meetings = lists;
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.tableView reloadData];
    });
  }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.meetings count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SimpleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Simple" forIndexPath:indexPath];
  cell.meeting = self.meetings[indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  STMObject<id<Meeting>> *meeting = self.meetings[indexPath.row];
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改" message:nil preferredStyle:UIAlertControllerStyleAlert];
  __block UITextField *timeField = nil;
  __block UITextField *placeField = nil;
  [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    timeField = textField;
    textField.text = [meeting.record time];
  }];
  [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    placeField = textField;
    textField.text = [meeting.record place];
  }];
  UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  }];
  UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [meeting.record setTime:timeField.text];
    [meeting.record setPlace:placeField.text];
    [meeting saveRecord];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self dismissViewControllerAnimated:YES completion:nil];
  }];
  [alert addAction:cancel];
  [alert addAction:save];
  [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
  __weak typeof(self) weakSelf = self;
  UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
    STMObject<id<Meeting>> *meeting = weakSelf.meetings[indexPath.row];
    NSMutableArray *arr = [NSMutableArray arrayWithArray:weakSelf.meetings];
    [arr removeObjectAtIndex:indexPath.row];
    weakSelf.meetings = [NSArray arrayWithArray:arr];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [meeting deleteRecord];
  }];
  return @[delete];
}

- (IBAction)_creatMeeting:(UIBarButtonItem *)sender {
  [self _creat];
  [self.tableView reloadData];
}

- (IBAction)_creatMany:(UIBarButtonItem *)sender {
  for (int i = 0; i < 10000; ++i) {
    [self _creat];
  }
  [self.tableView reloadData];
}

- (IBAction)_clear:(UIBarButtonItem *)sender {
  [STMObject deleteAllFrom:kMeetingClassName];
  self.meetings = nil;
  [self.tableView reloadData];
}

- (void)_creat {
  NSDate *date = [NSDate date];
  STMObject<id<Meeting>> *meeting = [[STMObject alloc] initWithClassName:kMeetingClassName];
  [meeting.record setTime:date.description];
  [meeting.record setPlace:@"宾利"];
  [meeting asyncSaveRecord:nil];
  self.meetings = [self.meetings arrayByAddingObject:meeting];
}

- (NSArray<STMObject<id<Meeting>> *> *)meetings {
  if (!_meetings) {
    _meetings = [NSArray array];
  }
  return _meetings;
}

@end

@implementation SimpleCell

- (void)setMeeting:(STMObject<id<Meeting>> *)meeting {
  if (_meeting != meeting) {
    _meeting = meeting;
    NSString *place = [_meeting.record place];
    self.textLabel.text = [_meeting.record time];
    if (place) {
      self.textLabel.text = [self.textLabel.text stringByAppendingFormat:@" | %@", place];
    }
  }
}

@end
