//
//  AgreementURLsConfigTests.swift
//
//  Created by Afzal Wali on 20/May/2018
//  OpenSource Contribution
//

import Foundation
import XCTest
@testable import edX

class AgreementURLsConfigTests : XCTestCase {

    func testAgreementURLsConfig() {
        // In case the configuration values are provided, they should be used instead of the
        // fallback values.
        let eulaUrl = "https://example-eula.com"
        let tosUrl = "https://example-tos.com"
        let privacyPolicyUrl = "https://example-policy.com"
        let cookieUrl = "https://example-cookie.com"
        let dataSellConsentUrl = "https://example-datasellconsent.com"
        let configDictionary = [
            "AGREEMENT_URLS" : [
                "EULA_URL": eulaUrl,
                "TOS_URL": tosUrl,
                "PRIVACY_POLICY_URL": privacyPolicyUrl,
                "COOKIE_POLICY_URL": cookieUrl,
                "DATA_SELL_CONSENT_URL": dataSellConsentUrl
            ]
        ]
        let config = OEXConfig(dictionary: configDictionary)

        XCTAssertNotNil(config.agreementURLsConfig)
        XCTAssertNotNil(config.agreementURLsConfig.eulaURL)
        XCTAssertNotNil(config.agreementURLsConfig.tosURL)
        XCTAssertNotNil(config.agreementURLsConfig.privacyPolicyURL)
        XCTAssertNotNil(config.agreementURLsConfig.cookiePolicyURL)
        XCTAssertNotNil(config.agreementURLsConfig.dataSellConsentURL)
        
        XCTAssertEqual(config.agreementURLsConfig.eulaURL?.absoluteString, eulaUrl)
        XCTAssertEqual(config.agreementURLsConfig.tosURL?.absoluteString, tosUrl)
        XCTAssertEqual(config.agreementURLsConfig.privacyPolicyURL?.absoluteString, privacyPolicyUrl)
        XCTAssertEqual(config.agreementURLsConfig.cookiePolicyURL?.absoluteString, cookieUrl)
        XCTAssertEqual(config.agreementURLsConfig.dataSellConsentURL?.absoluteString, dataSellConsentUrl)
    }

    func testAgreementURLsNoConfig() {
        // In the case where no config values are overridden, the AgreementURLsConfig should be
        // populated with fallback values
        let config = OEXConfig(dictionary:[:])
        XCTAssertNotNil(config.agreementURLsConfig)

        let eulaUrl = Bundle.main.url(forResource: "MobileAppEula", withExtension: "htm")
        let tosUrl = Bundle.main.url(forResource: "TermsOfServices", withExtension: "htm")
        let privacyPolicyUrl = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "htm")
        
        XCTAssertEqual(config.agreementURLsConfig.eulaURL, eulaUrl)
        XCTAssertEqual(config.agreementURLsConfig.tosURL, tosUrl)
        XCTAssertEqual(config.agreementURLsConfig.privacyPolicyURL, privacyPolicyUrl)
    }
    
    func testAgreementURLsPartialConfig() {
        // In the case where some of the config values are overridden, the AgreementURLsConfig
        // should be populated with fallback values for the remaining values.
        
        let eulaUrlOverride = "https://example-eula.com"
        let configDictionary = [
            "AGREEMENT_URLS" : [
                "EULA_URL": eulaUrlOverride
            ]
        ]
        let config = OEXConfig(dictionary: configDictionary)
        
        XCTAssertNotNil(config.agreementURLsConfig)
        XCTAssertEqual(config.agreementURLsConfig.eulaURL?.absoluteString, eulaUrlOverride)

        XCTAssertNil(config.agreementURLsConfig.tosURL)
        XCTAssertNil(config.agreementURLsConfig.privacyPolicyURL)
    }
}
