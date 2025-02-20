import BITCore
import BITCredential
import Foundation
import Spyable

@Spyable
public protocol GeneratePresentationMetadataUseCaseProtocol {
  func execute(forCredential credential: RawCredential, requiredfields: [CodableValue]) throws -> PresentationMetadata
}
