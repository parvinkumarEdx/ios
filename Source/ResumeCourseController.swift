//
//  ResumeCourseController.swift
//  edX
//
//  Created by Ehmad Zubair Chughtai on 03/07/2015.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

public protocol ResumeCourseControllerDelegate : AnyObject {
    func resumeCourseControllerDidFetchResumeCourseItem(item : ResumeCourseItem?)
}

public class ResumeCourseController: NSObject {
   
    private let resumeCourseLoader = BackedStream<(CourseBlock, ResumeCourseItem)>()
    private let blockID : CourseBlockID?
    private let dataManager : DataManager
    private let networkManager : NetworkManager
    private let courseQuerier : CourseOutlineQuerier
    private let resumeCourseProvider : ResumeCourseProvider?
    private let courseOutlineMode : CourseOutlineMode
    
    private var courseID : String {
        return courseQuerier.courseID
    }
    
    public weak var delegate : ResumeCourseControllerDelegate?
    
    /// Strictly a test variable used as a trigger flag. Not to be used out of the test scope
    private var t_hasTriggeredSetResumeCourse = false
    
    
    public init(blockID : CourseBlockID?, dataManager: DataManager, networkManager: NetworkManager, courseQuerier: CourseOutlineQuerier, resumeCourseProvider: ResumeCourseProvider? = nil, forMode mode: CourseOutlineMode) {
        self.blockID = blockID
        self.dataManager = dataManager
        self.networkManager = networkManager
        self.courseQuerier = courseQuerier
        self.resumeCourseProvider = resumeCourseProvider ?? dataManager.interface
        courseOutlineMode = mode
        super.init()
        
        addListener()
    }
    
    fileprivate var canShowResumeCourse : Bool {
        // We only show at the root level
        return blockID == nil && courseOutlineMode == .full
    }
    
    fileprivate var canUpdateResumeCourse: Bool {
        return blockID != nil && courseOutlineMode == .full
    }
    
    public func loadResumeCourse(forMode mode: CourseOutlineMode) {
        if !canShowResumeCourse {
            return
        }
                
        if let firstLoad = resumeCourseProvider?.getResumeCourseBlock(for: courseID) {
            let blockStream = expandAccessStream(stream: OEXStream(value : firstLoad), forMode: mode)
            resumeCourseLoader.backWithStream(blockStream)
        }
        let request = UserAPI.requestResumeCourseBlock(for: courseID)
        let resumeCourse = networkManager.streamForRequest(request)
        resumeCourseLoader.backWithStream(expandAccessStream(stream: resumeCourse, forMode: mode))
    }
    
    func addListener() {
        resumeCourseLoader.listen(self) { [weak self] info in
            switch info {
            case .success((let block, let resumeCourseItem)):
                self?.resumeCourseProvider?.setResumeCourseBlock(with: resumeCourseItem.lastVisitedBlockID, lastVisitedBlockName: block.displayName, courseID: self?.courseID, timeStamp: DateFormatting.serverString(withDate: NSDate()) ?? "")
                self?.delegate?.resumeCourseControllerDidFetchResumeCourseItem(item: resumeCourseItem)
                
                break
            case .failure:
                self?.delegate?.resumeCourseControllerDidFetchResumeCourseItem(item: nil)
                
                break
            }
        }
    }

    private func expandAccessStream(stream: OEXStream<ResumeCourseItem>, forMode mode: CourseOutlineMode = .full) -> OEXStream<(CourseBlock, ResumeCourseItem)> {
        return stream.transform { [weak self] resumeCourse in
            return joinStreams((self?.courseQuerier.blockWithID(id: resumeCourse.lastVisitedBlockID, mode: mode)) ?? OEXStream<CourseBlock>(), OEXStream(value: resumeCourse))
        }
    }
}

extension ResumeCourseController {

    public func t_saveResumeCourse(item: ResumeCourseItem) {
        resumeCourseProvider?.setResumeCourseBlock(with: item.lastVisitedBlockID, lastVisitedBlockName: item.lastVisitedBlockName, courseID: courseID, timeStamp: DateFormatting.serverString(withDate: NSDate()) ?? "")
        t_hasTriggeredSetResumeCourse = true
    }
    
    public func t_getResumeCourseFor(courseID: String) -> ResumeCourseItem? {
        return resumeCourseProvider?.getResumeCourseBlock(for: courseID)
    }
    
    public func t_canShowResumeCourse() -> Bool{
        return canShowResumeCourse
    }
    
    public func t_canUpdateResumeCourse() -> Bool{
        return canUpdateResumeCourse
    }
}
