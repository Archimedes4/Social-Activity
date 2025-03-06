//
//  Tests.swift
//  Tests
//
//  Created by Andrew Mainella on 2025-03-05.
//

import Testing
@testable import Social_Activity

struct Tests {

    @Test func testGetDeviceTimeText() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
			#expect("Last updated January 28, 2025 at 2:19 PM" == getDeviceTimeText(time: 1738102744))
    }

}
