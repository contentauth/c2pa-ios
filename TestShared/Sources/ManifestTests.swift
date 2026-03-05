import C2PA
import Foundation

// Manifest tests - pure Swift implementation
public final class ManifestTests: TestImplementation {

    public init() {}

    public func testMinimal() -> TestResult {
        let manifest = ManifestDefinition(claimGeneratorInfo: [], title: "test")

        if manifest.claimVersion != 2 {
            return .failure("Manifest", "claimVersion != 2, got \(manifest.claimVersion)")
        }

        if manifest.format != "application/octet-stream" {
            return .failure("Manifest", "format != application/octet-stream, got \(manifest.format)")
        }

        if manifest.title != "test" {
            return .failure("Manifest", "title != test, got \(manifest.title)")
        }

        return cloneAndCompare(manifest)
    }

    public func testCreated() -> TestResult {
        let manifest = ManifestDefinition(
            assertions: [.actions(actions: [.init(action: .created, digitalSourceType: .digitalCapture)])],
            claimGeneratorInfo: [.init()],
            title: "test")

        guard case .actions(let actions) = manifest.assertions.first! else {
            return .failure("Manifest", "manifest.assertions.first != .actions")
        }

        guard let action = actions.first else {
            return .failure("Manifest", "actions.first == nil")
        }

        if action.action != "c2pa.created" {
            return .failure("Manifest", "action.action != c2pa.created, got \(action.action)")
        }

        if action.digitalSourceType != "http://cv.iptc.org/newscodes/digitalsourcetype/digitalCapture" {
            return .failure("Manifest", "action.digitalSourceType != http://cv.iptc.org/newscodes/digitalsourcetype/digitalCapture, got \(action.digitalSourceType ?? "(nil)")")
        }

        guard let info = manifest.claimGeneratorInfo.first else {
            return .failure("Manifest", "claimGeneratorInfo.first == nil")
        }

        if info.name != "xctest" {
            return .failure("Manifest", "claimGeneratorInfo.name != xctest, got \(manifest.claimGeneratorInfo.first?.name ?? "(nil)")")
        }

        guard let version = info.version else {
            return .failure("Manifest", "claimGeneratorInfo.version == nil")
        }

        let regex: NSRegularExpression

        do {
            regex = try NSRegularExpression(pattern: "^[\\d.]+$")
        } catch {
            return .failure("Manifest", "Error: \(error)")
        }

        guard let match = regex.firstMatch(in: version, range: .init(version.startIndex ..< version.endIndex, in: version)),
              match.range.lowerBound == 0 && match.range.upperBound == version.count
        else {
            return .failure("Manifest", "claimGeneratorInfo.version !~ /^[\\d.]+$/")
        }

        return cloneAndCompare(manifest)
    }

    public func testEnumRendering() -> TestResult {
        let shape = Shape(type: .rectangle, origin: .init(x: 10, y: 10), width: 80, height: 80, unit: .percent)

        do {
            let data = try JSONEncoder().encode(shape)
            let json = String(data: data, encoding: .utf8)

            let s2 = try JSONDecoder().decode(Shape.self, from: data)

            if shape == s2 {
                return .success("Manifest", "[PASS] enums rendered as expected.")
            } else {
                return .failure("Manifest", "JSON rendering unexpected: \(json ?? "(nil)")")
            }

        } catch {
            return .failure("Manifest", "Error: \(error)")
        }
    }

    public func testRegionOfInterest() -> TestResult {
        let rr = RegionRange(type: .frame)

        let roi1 = RegionOfInterest(region: [rr], type: .animal)
        let roi2 = RegionOfInterest(region: [rr], type: .animal)

        if roi1 == roi2 {
            return .success("Manifest", "[PASS] RegionOfInterests equal.")
        } else {
            return .failure("Manifest", "RegionOfInterests unexpectedly unequal.")
        }
    }

    public func testResourceRef() -> TestResult {
        let r1 = ResourceRef(format: "application/octet-string", identifier: "")

        do {
            let data = try JSONEncoder().encode(r1)

            let r2 = try JSONDecoder().decode(ResourceRef.self, from: data)

            if r1 == r2 {
                return .success("Manifest", "[PASS] ResourceRefs equal.")
            } else {
                return .failure("Manifest", "ResourceRefs unexpectedly unequal.")
            }
        } catch {
            return .failure("Manifest", "Error: \(error)")
        }
    }

    public func testHashedUri() -> TestResult {
        let hu1 = HashedUri(hash: [], url: "foo")

        do {
            let data = try JSONEncoder().encode(hu1)

            let hu2 = try JSONDecoder().decode(HashedUri.self, from: data)

            if hu1 == hu2 {
                return .success("Manifest", "[PASS] HashedUris equal.")
            } else {
                return .failure("Manifest", "HashedUris unexpectedly unequal.")
            }
        } catch {
            return .failure("Manifest", "Error: \(error)")
        }
    }

    public func testUriOrResource() -> TestResult {
        let uor1 = UriOrResource(alg: "foo")
        let uor2 = UriOrResource(alg: "foo")

        if uor1 == uor2 {
            return .success("Manifest", "[PASS] UriOrResources equal.")
        } else {
            return .failure("Manifest", "UriOrResources unexpectedly unequal.")
        }
    }

    public func testMassInit() -> TestResult {
        var testSteps: [String] = []

        // Test Ingredient default values
        let ingredient = Ingredient()
        guard ingredient.title == nil else {
            return .failure("Mass Init", "Ingredient.title should be nil by default")
        }
        testSteps.append("Ingredient: defaults verified")

        // Test StatusCodes with empty arrays
        let statusCodes = StatusCodes(failure: [], informational: [], success: [])
        guard statusCodes.failure.isEmpty && statusCodes.informational.isEmpty && statusCodes.success.isEmpty else {
            return .failure("Mass Init", "StatusCodes arrays should be empty")
        }
        testSteps.append("StatusCodes: empty arrays verified")

        // Test Metadata default
        let metadata = Metadata()
        guard metadata.dateTime == nil else {
            return .failure("Mass Init", "Metadata.dateTime should be nil by default")
        }
        testSteps.append("Metadata: defaults verified")

        // Test ValidationStatus with specific code
        let validationStatus = ValidationStatus(code: .algorithmUnsupported)
        guard validationStatus.code == .algorithmUnsupported else {
            return .failure("Mass Init", "ValidationStatus.code mismatch: expected .algorithmUnsupported, got '\(validationStatus.code)'")
        }
        testSteps.append("ValidationStatus: code verified")

        // Test Time default
        let time = Time()
        guard time.start == nil && time.end == nil else {
            return .failure("Mass Init", "Time.start and .end should be nil by default")
        }
        testSteps.append("Time: defaults verified")

        // Test TextSelector with fragment
        let textSelector = TextSelector(fragment: "test-fragment")
        guard textSelector.fragment == "test-fragment" else {
            return .failure("Mass Init", "TextSelector.fragment mismatch")
        }
        testSteps.append("TextSelector: fragment verified")

        // Test ReviewRating with values
        let reviewRating = ReviewRating(explanation: "test explanation", value: 5)
        guard reviewRating.explanation == "test explanation" && reviewRating.value == 5 else {
            return .failure("Mass Init", "ReviewRating values mismatch")
        }
        testSteps.append("ReviewRating: values verified")

        // Test DataSource with type
        let dataSource = DataSource(type: "test-type")
        guard dataSource.type == "test-type" else {
            return .failure("Mass Init", "DataSource.type mismatch")
        }
        testSteps.append("DataSource: type verified")

        // Test MetadataActor default
        let metadataActor = MetadataActor()
        guard metadataActor.identifier == nil else {
            return .failure("Mass Init", "MetadataActor.identifier should be nil by default")
        }
        testSteps.append("MetadataActor: defaults verified")

        // Test ValidationResults default
        let validationResults = ValidationResults()
        guard validationResults.activeManifest == nil else {
            return .failure("Mass Init", "ValidationResults.activeManifest should be nil by default")
        }
        testSteps.append("ValidationResults: defaults verified")

        // Test IngredientDeltaValidationResult
        let deltaResult = IngredientDeltaValidationResult(ingredientAssertionUri: "test-uri", validationDeltas: statusCodes)
        guard deltaResult.ingredientAssertionUri == "test-uri" else {
            return .failure("Mass Init", "IngredientDeltaValidationResult.ingredientAssertionUri mismatch")
        }
        testSteps.append("IngredientDeltaValidationResult: values verified")

        // Test Item with values
        let item = Item(identifier: "track_id", value: "2")
        guard item.identifier == "track_id" && item.value == "2" else {
            return .failure("Mass Init", "Item values mismatch")
        }
        testSteps.append("Item: values verified")

        // Test AssetType with type
        let assetType = AssetType(type: "image/jpeg")
        guard assetType.type == "image/jpeg" else {
            return .failure("Mass Init", "AssetType.type mismatch")
        }
        testSteps.append("AssetType: type verified")

        // Test Frame default
        let frame = Frame()
        guard frame.start == nil && frame.end == nil else {
            return .failure("Mass Init", "Frame.start and .end should be nil by default")
        }
        testSteps.append("Frame: defaults verified")

        // Test TextSelectorRange with selector
        let textSelectorRange = TextSelectorRange(selector: textSelector)
        guard textSelectorRange.selector.fragment == "test-fragment" else {
            return .failure("Mass Init", "TextSelectorRange.selector.fragment mismatch")
        }
        testSteps.append("TextSelectorRange: selector verified")

        // Test Text with selectors
        let text = Text(selectors: [textSelectorRange])
        guard text.selectors.count == 1 else {
            return .failure("Mass Init", "Text.selectors should have 1 element")
        }
        testSteps.append("Text: selectors count verified")

        return .success("Mass Init", testSteps.joined(separator: "\n"))
    }

    @MainActor
    public func runAllTests() async -> [TestResult] {
        return [
            testMinimal(),
            testCreated(),
            testEnumRendering(),
            testRegionOfInterest(),
            testResourceRef(),
            testHashedUri(),
            testUriOrResource(),
            testMassInit()
        ]
    }


    // MARK: Private Methods

    private func cloneAndCompare(_ manifest: ManifestDefinition) -> TestResult {
        guard let data = manifest.description.data(using: .utf8) else {
            return .failure("Manifest", "ManifestDefinition.description could not be decoded to UTF-8 Data!")
        }

        let m2: ManifestDefinition

        do {
            m2 = try JSONDecoder().decode(ManifestDefinition.self, from: data)
        } catch {
            return .failure("Manifest", "Error: \(error)")
        }

        if manifest == m2 {
            return .success("Manifest", "[PASS] Manifest rendered as expected.")
        }

        return .failure("Manifest", "Broken compiled manifest: \(manifest.description) != \(m2.description)")
    }
}
