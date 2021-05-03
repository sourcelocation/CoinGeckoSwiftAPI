    import XCTest
    import CoinGeckoSwiftAPI
    
    @testable import CoinGeckoSwiftAPI

    final class CoinGeckoSwiftAPITests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            let cg = CoinGecko()
            
            let expectation1 = XCTestExpectation(description: "Coins")
            let expectation2 = XCTestExpectation(description: "Search")
            let expectation3 = XCTestExpectation(description: "History")
            
            cg.fetch(completion: {
                cg.coins { coins in
                    XCTAssertEqual(coins[0].name!, "Bitcoin")
                    expectation1.fulfill()
                    
                    cg.history(for: coins[0], from: Date().addingTimeInterval(-1000000000), to: Date()) { pricePoints in
                        XCTAssertGreaterThan(pricePoints.last!.price, 45000)
                        expectation3.fulfill()
                    }
                }
                
                cg.search(string: "Bitcoin", completion: { coins in
                    XCTAssertEqual(coins[1].name!, "Bitcoin Cash")
                    expectation2.fulfill()
                })
            })
            
            wait(for: [expectation1,expectation2,expectation3], timeout: 7.0)
        }
        
    }
