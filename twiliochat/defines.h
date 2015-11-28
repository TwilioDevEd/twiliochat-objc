#ifndef defines_h
#define defines_h

#define M_CONC(A, B) M_CONC_(A, B)
#define M_CONC_(A, B) A##B

#define SINGLE_ORIENTATON_ON_IPHONE(orientation) \
- (BOOL)shouldAutorotate { return YES; } \
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { \
if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) return UIInterfaceOrientationMaskAll; \
return M_CONC(UIInterfaceOrientationMask,orientation); \
} \
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation { \
if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) return UIInterfaceOrientationPortrait; \
return M_CONC(UIInterfaceOrientation,orientation); \
}

#endif
