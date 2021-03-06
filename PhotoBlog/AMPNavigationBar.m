// .h

@interface AMPNavigationBar : UINavigationBar

@property (nonatomic, assign) CGFloat extraColorLayerOpacity UI_APPEARANCE_SELECTOR;

@end

// .m

@interface AMPNavigationBar ()

@property (nonatomic, strong) CALayer *extraColorLayer;

@end

static CGFloat const kDefaultColorLayerOpacity = 0.5f;

@implementation AMPNavigationBar

- (void)setBarTintColor:(UIColor *)barTintColor
{
  [super setBarTintColor:barTintColor];
	if (self.extraColorLayer == nil) {
		// this all only applies to 7.0 - 7.0.2
		if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0.3" options:NSNumericSearch] == NSOrderedAscending) {
			self.extraColorLayer = [CALayer layer];
			self.extraColorLayer.opacity = self.extraColorLayerOpacity;
			[self.layer addSublayer:self.extraColorLayer];
		}
	}
	self.extraColorLayer.backgroundColor = barTintColor.CGColor;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
	if (self.extraColorLayer != nil) {
		[self.extraColorLayer removeFromSuperlayer];
		self.extraColorLayer.opacity = self.extraColorLayerOpacity;
		[self.layer insertSublayer:self.extraColorLayer atIndex:1];
		CGFloat spaceAboveBar = self.frame.origin.y;
		self.extraColorLayer.frame = CGRectMake(0, 0 - spaceAboveBar, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) + spaceAboveBar);
	}
}

- (void)setExtraColorLayerOpacity:(CGFloat)extraColorLayerOpacity
{
  _extraColorLayerOpacity = extraColorLayerOpacity;
	[self setNeedsLayout];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _extraColorLayerOpacity = [[decoder decodeObjectForKey:@"extraColorLayerOpacity"] floatValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeObject:@(self.extraColorLayerOpacity) forKey:@"extraColorLayerOpacity"];
}

@end
