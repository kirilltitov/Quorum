import XCTest

import QuorumTests

var tests = [XCTestCaseEntry]()
tests += QuorumTests.allTests()
XCTMain(tests)