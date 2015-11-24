#import <SLKTextViewController.h>
#import "StartViewController.h"
#import "SWRevealViewController.h"

@interface StartViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.revealViewController.rearViewRevealOverdraw = 0.f;
    
    if (self.revealViewController)
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        [self.revealViewController revealToggleAnimated:YES];
    }
}

@end
