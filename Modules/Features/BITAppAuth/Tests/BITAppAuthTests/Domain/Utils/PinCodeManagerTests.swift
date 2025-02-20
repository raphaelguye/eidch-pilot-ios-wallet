import Foundation
import XCTest
@testable import BITAppAuth
@testable import BITCrypto
@testable import BITLocalAuthentication
@testable import BITTestingCore

// MARK: - ValidateBiometricUseCaseTests

final class PinCodeManagerTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    spyEncrypter = EncryptableSpy()
    spyPepperRepository = PepperRepositoryProtocolSpy()
    pinCodeManager = PinCodeManager(
      pinCodeSize: pinCodeSize,
      encrypter: spyEncrypter,
      pepperRepository: spyPepperRepository)
  }

  func testValidateRegistrationSuccess() throws {
    try pinCodeManager.validateRegistration("123456")
  }

  func testValidateLoginSuccess() throws {
    try pinCodeManager.validateLogin("123456")
  }

  func testValidateLoginSuccess_shortPin() throws {
    try pinCodeManager.validateLogin("12")
  }

  func testValidateLoginSuccess_specialCharsPinCode() throws {
    try pinCodeManager.validateLogin("aA#$_0")
  }

  func testValidateLoginSuccess_longPinCode() throws {
    try pinCodeManager.validateLogin("12345678901234567890")
  }

  func testValidateRegistrationError_pinEmpty() throws {
    do {
      try pinCodeManager.validateRegistration("")
      XCTFail("Should fail instead...")
    } catch AuthError.pinCodeIsEmpty { }
    catch {
      XCTFail("Unexpected error type")
    }
  }

  func testValidateLoginError_pinEmpty() throws {
    do {
      try pinCodeManager.validateLogin("")
      XCTFail("Should fail instead...")
    } catch AuthError.pinCodeIsEmpty { }
    catch {
      XCTFail("Unexpected error type")
    }
  }

  func testValidateRegistrationError_pinTooShort() throws {
    do {
      try pinCodeManager.validateRegistration("12345")
      XCTFail("Should fail instead...")
    } catch AuthError.pinCodeIsToShort { }
    catch {
      XCTFail("Unexpected error type")
    }
  }

  func testEncrypt() throws {
    let pinCode: PinCode = "123456"
    guard let pinCodeData = pinCode.data(using: .utf8) else { fatalError("Data conversion") }
    let mockPepperKey: SecKey = SecKeyTestsHelper.createPrivateKey()
    let mockInitialVector: Data = .init()
    let mockPinCodeEncrypted: Data = .init()
    spyPepperRepository.getPepperKeyReturnValue = mockPepperKey
    spyPepperRepository.getPepperInitialVectorReturnValue = mockInitialVector
    spyEncrypter.encryptWithDerivedKeyFromPrivateKeyDataInitialVectorReturnValue = mockPinCodeEncrypted

    let pinCodeEncrypted = try pinCodeManager.encrypt(pinCode)
    XCTAssertEqual(mockPinCodeEncrypted, pinCodeEncrypted)
    XCTAssertTrue(spyPepperRepository.getPepperKeyCalled)
    XCTAssertTrue(spyPepperRepository.getPepperInitialVectorCalled)
    XCTAssertTrue(spyEncrypter.encryptWithDerivedKeyFromPrivateKeyDataInitialVectorCalled)

    XCTAssertEqual(mockPepperKey, spyEncrypter.encryptWithDerivedKeyFromPrivateKeyDataInitialVectorReceivedArguments?.privateKey)
    XCTAssertEqual(pinCodeData, spyEncrypter.encryptWithDerivedKeyFromPrivateKeyDataInitialVectorReceivedArguments?.data)
    XCTAssertEqual(mockInitialVector, spyEncrypter.encryptWithDerivedKeyFromPrivateKeyDataInitialVectorReceivedArguments?.initialVector)
  }

  // MARK: Private

  private let pinCodeSize = 6

  // swiftlint:disable all
  private var spyEncrypter: EncryptableSpy!
  private var spyPepperRepository: PepperRepositoryProtocolSpy!
  private var pinCodeManager: PinCodeManagerProtocol!
  // swiftlint:enable all
}
