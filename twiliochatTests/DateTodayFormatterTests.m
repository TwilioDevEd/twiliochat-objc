#import <XCTest/XCTest.h>
#import "DateTodayFormatter.h"

@interface DateTodayFormatterTests : XCTestCase
@property (strong, nonatomic) DateTodayFormatter *formatter;
@end

@implementation DateTodayFormatterTests

- (void)setUp {
  [super setUp];
  self.formatter = [[DateTodayFormatter alloc] init];
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testDateFormattingForToday {
  NSDate *date = [NSDate date];
  NSString *formatted = [[self.formatter stringFromDate:date] substringToIndex:8];
  XCTAssertEqualObjects(formatted, @"Today - ");
}

- (void)testDateFormattingForAnotherDay {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDateComponents *components = [[NSDateComponents alloc] init];
  components.year = 2015;
  components.month = 11;
  components.day = 20;
  
  NSDate *date = [calendar dateFromComponents:components];
  NSString *formatted = [[self.formatter stringFromDate:date] substringToIndex:7];
  XCTAssertEqualObjects(formatted, @"Nov. 20");
}

@end
