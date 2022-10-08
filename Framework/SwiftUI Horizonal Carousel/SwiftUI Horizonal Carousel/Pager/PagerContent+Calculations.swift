//

import Foundation

extension PagerContent {
    func realIndex(fromInternal internalIndex: Int) -> Int {
        if !settings.isInfinitePager {
            return internalIndex
        }

        var realIndex = 0

        let indexOffset = min(settings.itemsLoopingPaddingCount, originalDataCount)

        if internalIndex < indexOffset {
            realIndex = originalDataCount - (indexOffset - internalIndex)
        } else if internalIndex >= originalDataCount + indexOffset {
            realIndex = internalIndex - originalDataCount - indexOffset
        } else {
            realIndex = internalIndex - indexOffset
        }

        return realIndex
    }

    func calculateInternalIndex(fromReal realIndex: Int, isInfinitePager: Bool) -> Int {
        guard isInfinitePager else {
            return realIndex
        }

        var newInternalIndex = realIndex + pagerModel.settings.itemsLoopingPaddingCount
        let oldInternalIndex = internalIndex

        // internal index to match the last real index
        let trailingEdgeIndex = originalDataCount + pagerModel.settings.itemsLoopingPaddingCount - 1

        // need to handle real index looping and perform jump to appopriate internal index
        if newInternalIndex == settings.itemsLoopingPaddingCount,
           oldInternalIndex == trailingEdgeIndex {
            newInternalIndex = oldInternalIndex + 1
        } else if newInternalIndex == trailingEdgeIndex,
                  oldInternalIndex == settings.itemsLoopingPaddingCount {
            newInternalIndex = oldInternalIndex - 1
        }

        return newInternalIndex
    }
}
