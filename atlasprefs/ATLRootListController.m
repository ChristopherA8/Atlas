#include "ATLRootListController.h"
#import "UIView+Constraints.h"

@implementation ATLRootListController

- (instancetype)init {
  self = [super init];

  if (self) {
    self.respringButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Respring"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(respring)];
    self.navigationItem.rightBarButtonItem = self.respringButton;
    self.navigationItem.titleView = [UIView new];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.text = @"Atlas";
    [self.navigationItem.titleView addSubview:self.titleLabel];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 140)];
    self.headerView.clipsToBounds = YES;
    self.headerImageView = [[UIImageView alloc] init];
    self.headerImageView.image = [UIImage
        imageWithContentsOfFile:
            @"/Library/PreferenceBundles/atlasprefs.bundle/iconSquare.png"];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerImageView.clipsToBounds = YES;
    self.headerImageView.layer.cornerRadius = 20;
    self.headerImageView.layer.cornerCurve = kCACornerCurveContinuous;
    self.headerLabel = [UILabel new];
    self.headerLabel.text = @"Atlas";
    self.headerLabel.textColor = UIColor.whiteColor;
    [self.headerLabel setTextAlignment:NSTextAlignmentLeft];
    [self.headerLabel setFont:[UIFont fontWithName:@"PingFangTC-Semibold"
                                              size:45.0f]];
    UILabel *version = [UILabel new];
    version.text = @"v1.0.1";
    version.textColor = [UIColor colorWithRed:0.75
                                        green:0.83
                                         blue:0.95
                                        alpha:1.00];
    [version setFont:[UIFont fontWithName:@"PingFangTC-Semibold" size:20.0f]];
    [version setTextAlignment:NSTextAlignmentCenter];

    [self.headerView addSubview:self.headerImageView];
    [self.headerView addSubview:self.headerLabel];
    [self.headerView addSubview:version];

    [self.headerImageView atlas_anchorTop:nil
                                  leading:self.headerView.leadingAnchor
                                   bottom:nil
                                 trailing:nil
                                  padding:UIEdgeInsetsMake(0, 40, 0, 0)
                                     size:CGSizeMake(80, 80)];
    [self.headerImageView.centerYAnchor
        constraintEqualToAnchor:self.headerView.centerYAnchor]
        .active = YES;

    [self.headerLabel atlas_anchorTop:self.headerImageView.topAnchor
                              leading:nil
                               bottom:nil
                             trailing:self.headerView.trailingAnchor
                              padding:UIEdgeInsetsMake(4, 10, 0, 10)
                                 size:CGSizeMake(150, 50)];
    // [self.headerLabel.centerYAnchor
    // constraintEqualToAnchor:self.headerView.centerYAnchor].active = YES;

    [version atlas_anchorTop:self.headerLabel.bottomAnchor
                     leading:self.headerLabel.leadingAnchor
                      bottom:self.headerImageView.bottomAnchor
                    trailing:self.headerLabel.trailingAnchor
                     padding:UIEdgeInsetsMake(1, 10, 4, 5)
                        size:CGSizeMake(0, 20)];

    [NSLayoutConstraint activateConstraints:@[
      [self.titleLabel.topAnchor
          constraintEqualToAnchor:self.navigationItem.titleView.topAnchor],
      [self.titleLabel.leadingAnchor
          constraintEqualToAnchor:self.navigationItem.titleView.leadingAnchor],
      [self.titleLabel.trailingAnchor
          constraintEqualToAnchor:self.navigationItem.titleView.trailingAnchor],
      [self.titleLabel.bottomAnchor
          constraintEqualToAnchor:self.navigationItem.titleView.bottomAnchor],
    ]];
  }
  return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  tableView.tableHeaderView = self.headerView;
  return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSArray *)specifiers {
  if (!_specifiers) {
    _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
  }

  return _specifiers;
}

- (void)respring {
  [HBRespringController respring];
}

- (void)discord {
  NSURL *discord = [NSURL URLWithString:@"https://discord.gg/zHN7yuGqYr"];
  [[UIApplication sharedApplication] openURL:discord
                                     options:@{}
                           completionHandler:nil];
}

- (void)paypal {
  NSURL *paypal = [NSURL URLWithString:@"https://paypal.me/chr1sdev"];
  [[UIApplication sharedApplication] openURL:paypal
                                     options:@{}
                           completionHandler:nil];
}

- (void)sourceCode {
  NSURL *source = [NSURL URLWithString:@"https://github.com/Chr1sDev/Atlas"];
  [[UIApplication sharedApplication] openURL:source
                                     options:@{}
                           completionHandler:nil];
}

@end
