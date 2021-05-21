#import "ATLSwitchCell.h"

@implementation ATLSwitchCell

-(id)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier { //init method
	self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier]; //call the super init method
	if (self) {
		[((UISwitch *)[self control]) setOnTintColor:[UIColor colorWithRed: 0.25 green: 0.74 blue: 1.00 alpha: 1.00]]; //change the switch color
	}
	return self;
}

@end