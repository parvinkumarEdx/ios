//
//  EnrolledCoursesFooterView.swift
//  edX
//
//  Created by Akiva Leffert on 12/23/15.
//  Copyright © 2015 edX. All rights reserved.
//

import Foundation

let EnrolledCoursesFooterViewHeight: CGFloat = 100

class EnrolledCoursesFooterView : UICollectionReusableView {
    static let identifier = "EnrolledCoursesFooterView"
    
    private let promptLabel = UILabel()
    private let findCoursesButton = UIButton(type:.system)
    
    private let container = UIView()
    
    var findCoursesAction : (() -> Void)?
    
    private var findCoursesTextStyle : OEXTextStyle {
        return OEXTextStyle(weight: .normal, size: .base, color: OEXStyles.shared().neutralXDark())
    }
    
    override init(frame: CGRect) {    
        super.init(frame: CGRect.zero)
        
        addSubview(container)
        container.addSubview(promptLabel)
        container.addSubview(findCoursesButton)
        
        self.promptLabel.attributedText = findCoursesTextStyle.attributedString(withText: Strings.EnrollmentList.findCoursesPrompt)
        self.promptLabel.textAlignment = .center
        
        self.findCoursesButton.applyButtonStyle(style: OEXStyles.shared().filledPrimaryButtonStyle, withTitle: Strings.EnrollmentList.findCourses.oex_uppercaseStringInCurrentLocale())
        
        container.backgroundColor = OEXStyles.shared().standardBackgroundColor()
        container.applyBorderStyle(style: BorderStyle())
        
        container.snp.makeConstraints { make in
            make.top.equalTo(self).offset(CourseCardCell.margin)
            make.bottom.equalTo(self)
            make.leading.equalTo(self).offset(CourseCardCell.margin)
            make.trailing.equalTo(self).offset(-CourseCardCell.margin)
        }
        
        self.promptLabel.snp.makeConstraints { make in
            make.leading.equalTo(container).offset(StandardHorizontalMargin)
            make.trailing.equalTo(container).offset(-StandardHorizontalMargin)
            make.top.equalTo(container).offset(StandardVerticalMargin)
        }
        
        self.findCoursesButton.snp.makeConstraints { make in
            make.leading.equalTo(promptLabel)
            make.trailing.equalTo(promptLabel)
            make.top.equalTo(promptLabel.snp.bottom).offset(StandardVerticalMargin)
            make.bottom.equalTo(container).offset(-StandardVerticalMargin)
        }
        
        findCoursesButton.oex_addAction({[weak self] _ in
            self?.findCoursesAction?()
            }, for: .touchUpInside)

        setAccessibilityIdentifiers()
    }

    private func setAccessibilityIdentifiers() {
        accessibilityIdentifier = "EnrolledCoursesFooterView:view"
        promptLabel.accessibilityIdentifier = "EnrolledCoursesFooterView:prompt-label"
        findCoursesButton.accessibilityIdentifier = "EnrolledCoursesFooterView:find-courses-button"
        container.accessibilityIdentifier = "EnrolledCoursesFooterView:container-view"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
