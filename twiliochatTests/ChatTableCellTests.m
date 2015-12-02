#import <XCTest/XCTest.h>
#import "ChatTableCell.h"

@interface ChatTableCell (Test)
- (NSString *)formattedDate;
@end

@interface ChatTableCellTests : XCTestCase
@property (strong, nonatomic) ChatTableCell *cell;
@end

@implementation ChatTableCellTests

- (void)setUp {
    [super setUp];
    self.cell = [[ChatTableCell alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDateFormattingForToday {
    self.cell.date = [NSDate date];
    NSString *formatted = [[self.cell formattedDate] substringToIndex:8];
    XCTAssertEqualObjects(formatted, @"Today - ");
}

- (void)testDateFormattingForAnotherDay {
    self.cell.date = [NSDate dateWithTimeIntervalSinceNow:-10000];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = 2015;
    components.month = 11;
    components.day = 20;
    
    self.cell.date = [calendar dateFromComponents:components];
    NSString *formatted = [[self.cell formattedDate] substringToIndex:4];
    XCTAssertEqualObjects(formatted, @"Nov.");
}

@end
