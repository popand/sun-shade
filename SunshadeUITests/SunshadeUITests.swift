//
//  SunshadeUITests.swift
//  SunshadeUITests
//
//  Created by Andrei Pop on 2025-06-23.
//

import XCTest

final class SunshadeUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testAppStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launch()

        // 1. Dashboard
        sleep(3) // Let weather data load
        saveScreenshot(app, name: "01_Dashboard")

        // 2. Scroll down on dashboard to show more content
        app.swipeUp()
        sleep(1)
        saveScreenshot(app, name: "02_DashboardMore")

        // 3. Timer tab
        app.tabBars.buttons["Timer"].tap()
        sleep(1)
        saveScreenshot(app, name: "03_SafetyTimer")

        // 4. Profile tab
        app.tabBars.buttons["Profile"].tap()
        sleep(1)
        saveScreenshot(app, name: "04_Profile")

        // 5. Back to Dashboard, find Education section and tap into it
        app.tabBars.buttons["Dashboard"].tap()
        sleep(1)
        // Scroll to find education cards
        app.swipeUp()
        sleep(1)
        app.swipeUp()
        sleep(1)
        saveScreenshot(app, name: "05_Education")
    }

    private func saveScreenshot(_ app: XCUIApplication, name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
