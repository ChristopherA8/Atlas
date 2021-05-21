@interface PSTableCell : UITableViewCell
@end
@interface PSControlTableCell : PSTableCell
- (UIControl *)control;
@end
@interface PSSwitchTableCell : PSControlTableCell
- (id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier;
@end

@interface ATLSwitchCell : PSSwitchTableCell
@end