//
//  OEXCheckBox.swift
//  edX
//
//  Created by Michael Katz on 8/27/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

public class OEXCheckBox: UIButton {

    @objc public var name: String = ""

    @IBInspectable public var checked: Bool = false {
        didSet {
            updateState()
        }
    }
    
    private func _setup() {
        imageView?.contentMode = .scaleAspectFit
        addTarget(self, action: #selector(OEXCheckBox.tapped), for: .touchUpInside)
        updateState()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateState()
    }
    
    private func updateState() {
        let newIcon = checked ? Icon.CheckBox : Icon.CheckBoxBlank
        let image = newIcon.imageWithFontSize(size: 14)
        setImage(image, for: .normal)
        accessibilityLabel = checked ? Strings.accessibilityCheckboxChecked : Strings.accessibilityCheckboxUnchecked
        accessibilityHint = checked ? Strings.accessibilityCheckboxHintChecked : Strings.accessibilityCheckboxHintUnchecked
    }
    
    @objc func tapped() {
        checked = !checked
        sendActions(for: .valueChanged)

        // Same analytics won't be sent for all type of checkbox elements, only sending for marketing option
        guard name == RegistrationMarketingEmailsOptIn else { return }

        if checked {
            OEXAnalytics.shared().trackEvent(with: .RegistrationOptinTurnedOn, name: .RegistrationOptinTurnedOn)
        }
        else {
            OEXAnalytics.shared().trackEvent(with: .RegistrationOptinTurnedOff, name: .RegistrationOptinTurnedOff)
        }
    }
}
