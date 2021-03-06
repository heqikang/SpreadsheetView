//
//  MergedCellTests.swift
//  SpreadsheetView
//
//  Created by Kishikawa Katsumi on 5/7/17.
//  Copyright © 2017 Kishikawa Katsumi. All rights reserved.
//

import XCTest
@testable import SpreadsheetView

class MergedCellTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func parameters(frozenColumns: Int = 0, frozenRows: Int = 0, circularScrolling: CircularScrollingConfiguration = CircularScrolling.Configuration.none) -> Parameters {
        let numberOfColumns = 60, numberOfRows = 60
        var mergedCells = [CellRange]()
        for column in (0..<numberOfColumns).filter({ $0 % 2 == 0 }) {
            for row in (0..<numberOfRows).filter({ $0 % 2 == 0 }) {
                mergedCells.append(CellRange(from: (column, row), to: (column + 1, row + 1)))
            }
        }
        return Parameters(numberOfColumns: numberOfColumns, numberOfRows: numberOfRows,
                          frozenColumns: frozenColumns, frozenRows: frozenRows,
                          circularScrolling: circularScrolling, mergedCells: mergedCells)
    }

    func testTableView() {
        let parameters = self.parameters()
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)

        verifyScrollToItem(spreadsheetView: spreadsheetView,
                           columns: (0, parameters.numberOfColumns),
                           rows: (0, parameters.numberOfRows),
                           scrollPosition: [.left, .top],
                           parameters: parameters)
        verifyScrollToItem(spreadsheetView: spreadsheetView,
                           columns: (0, parameters.numberOfColumns),
                           rows: (0, parameters.numberOfRows),
                           scrollPosition: [.left, .centeredVertically],
                           parameters: parameters)
        verifyScrollToItem(spreadsheetView: spreadsheetView,
                           columns: (0, parameters.numberOfColumns),
                           rows: (0, parameters.numberOfRows),
                           scrollPosition: [.left, .bottom],
                           parameters: parameters)

        verifyScrollToItem(spreadsheetView: spreadsheetView,
                           columns: (0, parameters.numberOfColumns),
                           rows: (0, parameters.numberOfRows),
                           scrollPosition: [.centeredHorizontally, .top],
                           parameters: parameters)
        verifyScrollToItem(spreadsheetView: spreadsheetView,
                           columns: (0, parameters.numberOfColumns),
                           rows: (0, parameters.numberOfRows),
                           scrollPosition: [.centeredHorizontally, .centeredVertically],
                           parameters: parameters)
        verifyScrollToItem(spreadsheetView: spreadsheetView,
                           columns: (0, parameters.numberOfColumns),
                           rows: (0, parameters.numberOfRows),
                           scrollPosition: [.centeredHorizontally, .bottom],
                           parameters: parameters)

        verifyScrollToItem(spreadsheetView: spreadsheetView,
                           columns: (0, parameters.numberOfColumns),
                           rows: (0, parameters.numberOfRows),
                           scrollPosition: [.right, .top],
                           parameters: parameters)
        verifyScrollToItem(spreadsheetView: spreadsheetView,
                           columns: (0, parameters.numberOfColumns),
                           rows: (0, parameters.numberOfRows),
                           scrollPosition: [.right, .centeredVertically],
                           parameters: parameters)
        verifyScrollToItem(spreadsheetView: spreadsheetView,
                           columns: (0, parameters.numberOfColumns),
                           rows: (0, parameters.numberOfRows),
                           scrollPosition: [.right, .bottom],
                           parameters: parameters)
    }

    func testColumnHeaderView() {
        let parameters = self.parameters(frozenColumns: 2)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func testRowHeaderView() {
        let parameters = self.parameters(frozenRows: 2)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func testColumnAndRowHeaderView() {
        let parameters = self.parameters(frozenColumns: 2, frozenRows: 2)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func testHorizontalCircularScrolling() {
        let parameters = self.parameters(circularScrolling: CircularScrolling.Configuration.horizontally)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func testVerticalCircularScrolling() {
        let parameters = self.parameters(circularScrolling: CircularScrolling.Configuration.vertically)
        let viewController = defaultViewController(parameters: parameters)

        showViewController(viewController: viewController)
        waitRunLoop()

        guard let _ = viewController.view else {
            XCTFail("fails to create root view controller")
            return
        }

        let spreadsheetView = viewController.spreadsheetView
        verify(view: spreadsheetView, parameters: parameters)
    }

    func verify(view spreadsheetView: SpreadsheetView, parameters: Parameters) {
        print("parameters: \(parameters)")

        XCTAssertEqual(spreadsheetView.visibleCells.count,
                       numberOfVisibleColumns(in: spreadsheetView, parameters: parameters) * numberOfVisibleRows(in: spreadsheetView, parameters: parameters))

        for (index, visibleCell) in spreadsheetView.visibleCells
            .sorted()
            .enumerated() {
                let column = index / numberOfVisibleRows(in: spreadsheetView, parameters: parameters)
                let row = index % numberOfVisibleRows(in: spreadsheetView, parameters: parameters)
                XCTAssertEqual(visibleCell.indexPath, IndexPath(row: row * 2, column: column * 2))
        }
    }

    func verifyScrollToItem(spreadsheetView: SpreadsheetView, columns: (from: Int, to: Int), rows: (from: Int, to: Int),
                            scrollPosition: ScrollPosition, parameters: Parameters) {
        print("parameters: \(parameters), scrollPosition: \(scrollPosition)")

        let frozenWidth = calculateWidth(range: 0..<parameters.frozenColumns, parameters: parameters)
        let frozenHeight = calculateHeight(range: 0..<parameters.frozenRows, parameters: parameters)

        var width = calculateWidth(range: 0..<columns.from, parameters: parameters)

        for column in (columns.from..<columns.to).filter({ $0 % 2 == 0 }) {
            var height = calculateHeight(range: 0..<rows.from, parameters: parameters)

            for row in (rows.from..<rows.to).filter({ $0 % 2 == 0 }) {
                let indexPath = IndexPath(row: row, column: column)
                spreadsheetView.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
                waitRunLoop()

                guard let cell = spreadsheetView.cellForItem(at: indexPath) else {
                    XCTFail("unknown error occurred")
                    return
                }

                let rect = cell.convert(cell.bounds, to: spreadsheetView)

                var actual = CGPoint.zero
                var expected = CGPoint.zero
                if scrollPosition.contains(.left) {
                    actual.x = rect.origin.x
                    if parameters.circularScrolling.options.direction.contains(CircularScrolling.Direction.horizontally) {
                        if width < frozenWidth {
                            expected.x = width + parameters.intercellSpacing.width
                        } else {
                            expected.x = frozenWidth + parameters.intercellSpacing.width
                        }
                    } else {
                        if width < frozenWidth {
                            expected.x = width + parameters.intercellSpacing.width
                        } else if width <= parameters.columnWidth - spreadsheetView.frame.width + frozenWidth {
                            expected.x = frozenWidth + parameters.intercellSpacing.width
                        } else {
                            expected.x = spreadsheetView.frame.width - (parameters.columnWidth - width) + parameters.intercellSpacing.width
                        }
                    }
                }
                if scrollPosition.contains(.centeredHorizontally) {
                    if parameters.circularScrolling.options.direction.contains(CircularScrolling.Direction.horizontally) {
                        if width < frozenWidth {
                            actual.x = rect.origin.x
                            expected.x = width + parameters.intercellSpacing.width
                        } else {
                            actual.x = cell.convert(cell.bounds, to: spreadsheetView).origin.x
                            expected.x = (spreadsheetView.frame.width + frozenWidth - (parameters.columns[column] + parameters.columns[column + 1] + parameters.intercellSpacing.width)) / 2
                        }
                    } else {
                        if width < frozenWidth {
                            actual.x = rect.origin.x
                            expected.x = width + parameters.intercellSpacing.width
                        } else if width + parameters.intercellSpacing.width + (parameters.columns[column] + parameters.columns[column + 1] + parameters.intercellSpacing.width) / 2 - frozenWidth <= (spreadsheetView.frame.width - frozenWidth) / 2 {
                            actual.x = rect.origin.x
                            expected.x = width + parameters.intercellSpacing.width
                        } else if width + parameters.intercellSpacing.width + (parameters.columns[column] + parameters.columns[column + 1] + parameters.intercellSpacing.width) / 2 >= parameters.columnWidth - (spreadsheetView.frame.width - frozenWidth) / 2 {
                            actual.x = rect.origin.x
                            expected.x = spreadsheetView.frame.width - (parameters.columnWidth - width) + parameters.intercellSpacing.width
                        } else {
                            actual.x = cell.convert(cell.bounds, to: spreadsheetView).origin.x
                            expected.x = (spreadsheetView.frame.width + frozenWidth - (parameters.columns[column] + parameters.columns[column + 1] + parameters.intercellSpacing.width)) / 2
                        }
                    }
                }
                if scrollPosition.contains(.right) {
                    if parameters.circularScrolling.options.direction.contains(CircularScrolling.Direction.horizontally) {
                        actual.x = rect.maxX + parameters.intercellSpacing.width
                        expected.x = spreadsheetView.frame.width
                    } else {
                        if width - frozenWidth + (parameters.columns[column] + parameters.columns[column + 1] + parameters.intercellSpacing.width) + parameters.intercellSpacing.width * 2 <= spreadsheetView.frame.width - frozenWidth {
                            actual.x = rect.origin.x
                            expected.x = width + parameters.intercellSpacing.width
                        } else {
                            actual.x = rect.maxX + parameters.intercellSpacing.width
                            expected.x = spreadsheetView.frame.width
                        }
                    }
                }

                if scrollPosition.contains(.top) {
                    actual.y = rect.origin.y
                    if parameters.circularScrolling.options.direction.contains(CircularScrolling.Direction.vertically) {
                        if height < frozenHeight {
                            expected.y = height + parameters.intercellSpacing.height
                        } else {
                            expected.y = frozenHeight + parameters.intercellSpacing.height
                        }
                    } else {
                        if height < frozenHeight {
                            expected.y = height + parameters.intercellSpacing.height
                        } else if height <= parameters.rowHeight - spreadsheetView.frame.height + frozenHeight {
                            expected.y = frozenHeight + parameters.intercellSpacing.height
                        } else {
                            expected.y = spreadsheetView.frame.height - (parameters.rowHeight - height) + parameters.intercellSpacing.height
                        }
                    }
                }
                if scrollPosition.contains(.centeredVertically) {
                    if parameters.circularScrolling.options.direction.contains(CircularScrolling.Direction.vertically) {
                        if height < frozenHeight {
                            actual.y = rect.origin.y
                            expected.y = height + parameters.intercellSpacing.height
                        } else {
                            actual.y = cell.convert(cell.bounds, to: spreadsheetView).origin.y
                            expected.y = (spreadsheetView.frame.height + frozenHeight - (parameters.rows[row] + parameters.rows[row + 1] + parameters.intercellSpacing.height)) / 2
                        }
                    } else {
                        if height < frozenHeight {
                            actual.y = rect.origin.y
                            expected.y = height + parameters.intercellSpacing.height
                        } else if height + parameters.intercellSpacing.height + (parameters.rows[row] + parameters.rows[row + 1] + parameters.intercellSpacing.height) / 2 - frozenHeight <= (spreadsheetView.frame.height - frozenHeight) / 2 {
                            actual.y = rect.origin.y
                            expected.y = height + parameters.intercellSpacing.height
                        } else if height + parameters.intercellSpacing.height + (parameters.rows[row] + parameters.rows[row + 1] + parameters.intercellSpacing.height) / 2 >= parameters.rowHeight - (spreadsheetView.frame.height - frozenHeight) / 2 {
                            actual.y = cell.convert(cell.bounds, to: spreadsheetView).origin.y
                            expected.y = spreadsheetView.frame.height - (parameters.rowHeight - height) + parameters.intercellSpacing.height
                        } else {
                            actual.y = cell.convert(cell.bounds, to: spreadsheetView).origin.y
                            expected.y = (spreadsheetView.frame.height + frozenHeight - (parameters.rows[row] + parameters.rows[row + 1] + parameters.intercellSpacing.height)) / 2
                        }
                    }
                }
                if scrollPosition.contains(.bottom) {
                    if parameters.circularScrolling.options.direction.contains(CircularScrolling.Direction.vertically) {
                        actual.y = rect.maxY + parameters.intercellSpacing.height
                        expected.y = spreadsheetView.frame.height
                    } else {
                        if height - frozenHeight + (parameters.rows[row] + parameters.rows[row + 1] + parameters.intercellSpacing.height) + parameters.intercellSpacing.height * 2 <= spreadsheetView.frame.height - frozenHeight {
                            actual.y = rect.origin.y
                            expected.y = height + parameters.intercellSpacing.height
                        } else {
                            actual.y = rect.maxY + parameters.intercellSpacing.height
                            expected.y = spreadsheetView.frame.height
                        }
                    }
                }
                XCTAssertEqual(actual.x, expected.x, accuracy: 1 / UIScreen.main.scale)
                XCTAssertEqual(actual.y, expected.y, accuracy: 1 / UIScreen.main.scale)
                height += parameters.rows[row] + parameters.intercellSpacing.height + parameters.rows[row + 1] + parameters.intercellSpacing.height
            }
            width += parameters.columns[column] + parameters.intercellSpacing.width + parameters.columns[column + 1] + parameters.intercellSpacing.width
        }
    }

    func numberOfVisibleColumns(in view: UIView, contentOffset: CGPoint = .zero, parameters: Parameters) -> Int {
        var columnCount = 0
        var width: CGFloat = 0
        for (index, columnWidth) in parameters.columns.enumerated() {
            width += columnWidth + parameters.intercellSpacing.width
            if width > contentOffset.x && index % 2 == 0 {
                columnCount += 1
            }
            if width + parameters.intercellSpacing.width > contentOffset.x + view.frame.width {
                break
            }
        }
        return columnCount
    }

    func numberOfVisibleRows(in view: UIView, contentOffset: CGPoint = .zero, parameters: Parameters) -> Int {
        var rowCount = 0
        var height: CGFloat = 0
        for (index, rowHeight) in parameters.rows.enumerated() {
            height += rowHeight + parameters.intercellSpacing.height
            if height > contentOffset.y && index % 2 == 0 {
                rowCount += 1
            }
            if height + parameters.intercellSpacing.height > contentOffset.y + view.frame.height {
                break
            }
        }
        return rowCount
    }
}
