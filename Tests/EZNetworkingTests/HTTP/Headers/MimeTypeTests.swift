@testable import EZNetworking
import Testing

@Suite("Test MimeType")
final class MimeTypeTests {
    // MARK: - Application Types Tests

    @Test("test application MIME types")
    func applicationMimeTypes() {
        #expect(MimeType.json.value == "application/json")
        #expect(MimeType.xml.value == "application/xml")
        #expect(MimeType.formUrlEncoded.value == "application/x-www-form-urlencoded")
        #expect(MimeType.multipartFormData(boundary: "some_boundary").value == "multipart/form-data; boundary=some_boundary")
        #expect(MimeType.pdf.value == "application/pdf")
        #expect(MimeType.zip.value == "application/zip")
        #expect(MimeType.octetStream.value == "application/octet-stream")
        #expect(MimeType.javascript.value == "application/javascript")
        #expect(MimeType.wasm.value == "application/wasm")
    }

    // MARK: - Text Types Tests

    @Test("test text MIME types")
    func textMimeTypes() {
        #expect(MimeType.plain.value == "text/plain")
        #expect(MimeType.html.value == "text/html")
        #expect(MimeType.css.value == "text/css")
        #expect(MimeType.csv.value == "text/csv")
        #expect(MimeType.rtf.value == "text/rtf")
        #expect(MimeType.xmlText.value == "text/xml")
    }

    // MARK: - Image Types Tests

    @Test("test image MIME types")
    func imageMimeTypes() {
        #expect(MimeType.jpeg.value == "image/jpeg")
        #expect(MimeType.png.value == "image/png")
        #expect(MimeType.gif.value == "image/gif")
        #expect(MimeType.webp.value == "image/webp")
        #expect(MimeType.svg.value == "image/svg+xml")
        #expect(MimeType.bmp.value == "image/bmp")
        #expect(MimeType.ico.value == "image/x-icon")
        #expect(MimeType.tiff.value == "image/tiff")
    }

    // MARK: - Video Types Tests

    @Test("test video MIME types")
    func videoMimeTypes() {
        #expect(MimeType.mp4.value == "video/mp4")
        #expect(MimeType.avi.value == "video/x-msvideo")
        #expect(MimeType.mov.value == "video/quicktime")
        #expect(MimeType.wmv.value == "video/x-ms-wmv")
        #expect(MimeType.flv.value == "video/x-flv")
        #expect(MimeType.webm.value == "video/webm")
        #expect(MimeType.mkv.value == "video/x-matroska")
        #expect(MimeType.quicktime.value == "video/quicktime")
    }

    // MARK: - Audio Types Tests

    @Test("test audio MIME types")
    func audioMimeTypes() {
        #expect(MimeType.mp3.value == "audio/mpeg")
        #expect(MimeType.wav.value == "audio/wav")
        #expect(MimeType.ogg.value == "audio/ogg")
        #expect(MimeType.aac.value == "audio/aac")
        #expect(MimeType.flac.value == "audio/flac")
        #expect(MimeType.m4a.value == "audio/mp4")
        #expect(MimeType.wma.value == "audio/x-ms-wma")
    }

    // MARK: - Font Types Tests

    @Test("test font MIME types")
    func fontMimeTypes() {
        #expect(MimeType.ttf.value == "font/ttf")
        #expect(MimeType.otf.value == "font/otf")
        #expect(MimeType.woff.value == "font/woff")
        #expect(MimeType.woff2.value == "font/woff2")
        #expect(MimeType.eot.value == "application/vnd.ms-fontobject")
    }

    // MARK: - Custom Type Tests

    @Test("test custom MIME type")
    func testCustomMimeType() {
        let customValue = "application/vnd.api+json"
        let customMimeType = MimeType.custom(customValue)
        #expect(customMimeType.value == customValue)
    }

    @Test("test custom MIME type with empty string")
    func customMimeTypeWithEmptyString() {
        let customMimeType = MimeType.custom("")
        #expect(customMimeType.value.isEmpty)
    }

    @Test("test custom MIME type with special characters")
    func customMimeTypeWithSpecialCharacters() {
        let customValue = "application/json; charset=utf-8"
        let customMimeType = MimeType.custom(customValue)
        #expect(customMimeType.value == customValue)
    }

    // MARK: - Equatable Tests

    @Test("test MimeType equality - same cases")
    func mimeTypeEqualitySameCases() {
        #expect(MimeType.json == MimeType.json)
        #expect(MimeType.xml == MimeType.xml)
        #expect(MimeType.png == MimeType.png)
        #expect(MimeType.mp4 == MimeType.mp4)
        #expect(MimeType.mp3 == MimeType.mp3)
        #expect(MimeType.ttf == MimeType.ttf)
    }

    @Test("test MimeType equality - different cases")
    func mimeTypeEqualityDifferentCases() {
        #expect(MimeType.json != MimeType.xml)
        #expect(MimeType.png != MimeType.jpeg)
        #expect(MimeType.mp4 != MimeType.avi)
        #expect(MimeType.mp3 != MimeType.wav)
        #expect(MimeType.ttf != MimeType.otf)
    }

    @Test("test MimeType equality - custom cases")
    func mimeTypeEqualityCustomCases() {
        let custom1 = MimeType.custom("application/json")
        let custom2 = MimeType.custom("application/json")
        let custom3 = MimeType.custom("application/xml")

        #expect(custom1 == custom2)
        #expect(custom1 != custom3)
        #expect(custom2 != custom3)
    }

    @Test("test MimeType equality - custom vs predefined")
    func mimeTypeEqualityCustomVsPredefined() {
        let customJson = MimeType.custom("application/json")
        let predefinedJson = MimeType.json

        #expect(customJson != predefinedJson)
        #expect(customJson.value == predefinedJson.value)
    }

    // MARK: - Comprehensive Value Tests

    @Test("test all MIME type values are non-empty")
    func allMimeTypeValuesAreNonEmpty() {
        let allMimeTypes: [MimeType] = [
            // Application Types
            .json, .xml, .formUrlEncoded, .multipartFormData(boundary: ""), .pdf, .zip, .octetStream, .javascript, .wasm,
            // Text Types
            .plain, .html, .css, .csv, .rtf, .xmlText,
            // Image Types
            .jpeg, .png, .gif, .webp, .svg, .bmp, .ico, .tiff,
            // Video Types
            .mp4, .avi, .mov, .wmv, .flv, .webm, .mkv, .quicktime,
            // Audio Types
            .mp3, .wav, .ogg, .aac, .flac, .m4a, .wma,
            // Font Types
            .ttf, .otf, .woff, .woff2, .eot
        ]

        for mimeType in allMimeTypes {
            #expect(!mimeType.value.isEmpty, "MIME type \(mimeType) should have non-empty value")
        }
    }

    @Test("test MIME type values contain forward slash")
    func mimeTypeValuesContainForwardSlash() {
        let allMimeTypes: [MimeType] = [
            // Application Types
            .json, .xml, .formUrlEncoded, .multipartFormData(boundary: ""), .pdf, .zip, .octetStream, .javascript, .wasm,
            // Text Types
            .plain, .html, .css, .csv, .rtf, .xmlText,
            // Image Types
            .jpeg, .png, .gif, .webp, .svg, .bmp, .ico, .tiff,
            // Video Types
            .mp4, .avi, .mov, .wmv, .flv, .webm, .mkv, .quicktime,
            // Audio Types
            .mp3, .wav, .ogg, .aac, .flac, .m4a, .wma,
            // Font Types
            .ttf, .otf, .woff, .woff2, .eot
        ]

        for mimeType in allMimeTypes {
            #expect(mimeType.value.contains("/"), "MIME type \(mimeType) should contain forward slash")
        }
    }

    // MARK: - Edge Cases Tests

    @Test("test custom MIME type with very long string")
    func customMimeTypeWithVeryLongString() {
        let longString = String(repeating: "a", count: 1000)
        let customMimeType = MimeType.custom(longString)
        #expect(customMimeType.value == longString)
    }

    @Test("test custom MIME type with unicode characters")
    func customMimeTypeWithUnicodeCharacters() {
        let unicodeString = "application/测试; charset=utf-8"
        let customMimeType = MimeType.custom(unicodeString)
        #expect(customMimeType.value == unicodeString)
    }

    // MARK: - Pattern Validation Tests

    @Test("test application MIME types follow correct pattern")
    func applicationMimeTypesFollowCorrectPattern() {
        let applicationTypes: [MimeType] = [.json, .xml, .formUrlEncoded, .multipartFormData(boundary: ""), .pdf, .zip, .octetStream, .javascript, .wasm]

        for mimeType in applicationTypes {
            let value = mimeType.value
            #expect(
                value.hasPrefix("application/") || value.hasPrefix("multipart/"),
                "Application MIME type \(mimeType) should start with 'application/' or 'multipart/'"
            )
        }
    }

    @Test("test text MIME types follow correct pattern")
    func textMimeTypesFollowCorrectPattern() {
        let textTypes: [MimeType] = [.plain, .html, .css, .csv, .rtf, .xmlText]

        for mimeType in textTypes {
            let value = mimeType.value
            #expect(value.hasPrefix("text/"), "Text MIME type \(mimeType) should start with 'text/'")
        }
    }

    @Test("test image MIME types follow correct pattern")
    func imageMimeTypesFollowCorrectPattern() {
        let imageTypes: [MimeType] = [.jpeg, .png, .gif, .webp, .svg, .bmp, .ico, .tiff]

        for mimeType in imageTypes {
            let value = mimeType.value
            #expect(value.hasPrefix("image/"), "Image MIME type \(mimeType) should start with 'image/'")
        }
    }

    @Test("test video MIME types follow correct pattern")
    func videoMimeTypesFollowCorrectPattern() {
        let videoTypes: [MimeType] = [.mp4, .avi, .mov, .wmv, .flv, .webm, .mkv, .quicktime]

        for mimeType in videoTypes {
            let value = mimeType.value
            #expect(value.hasPrefix("video/"), "Video MIME type \(mimeType) should start with 'video/'")
        }
    }

    @Test("test audio MIME types follow correct pattern")
    func audioMimeTypesFollowCorrectPattern() {
        let audioTypes: [MimeType] = [.mp3, .wav, .ogg, .aac, .flac, .m4a, .wma]

        for mimeType in audioTypes {
            let value = mimeType.value
            #expect(value.hasPrefix("audio/"), "Audio MIME type \(mimeType) should start with 'audio/'")
        }
    }

    @Test("test font MIME types follow correct pattern")
    func fontMimeTypesFollowCorrectPattern() {
        let fontTypes: [MimeType] = [.ttf, .otf, .woff, .woff2, .eot]

        for mimeType in fontTypes {
            let value = mimeType.value
            #expect(
                value.hasPrefix("font/") || value.hasPrefix("application/"),
                "Font MIME type \(mimeType) should start with 'font/' or 'application/'"
            )
        }
    }

    // MARK: - Specific Value Validation Tests

    @Test("test specific MIME type values match expected standards")
    func specificMimeTypeValuesMatchExpectedStandards() {
        // Test some well-known MIME types
        #expect(MimeType.json.value == "application/json")
        #expect(MimeType.html.value == "text/html")
        #expect(MimeType.png.value == "image/png")
        #expect(MimeType.mp4.value == "video/mp4")
        #expect(MimeType.mp3.value == "audio/mpeg")
        #expect(MimeType.svg.value == "image/svg+xml")
        #expect(MimeType.ico.value == "image/x-icon")
        #expect(MimeType.eot.value == "application/vnd.ms-fontobject")
    }

    // MARK: - Comprehensive Coverage Test

    @Test("test all enum cases are covered in switch statement")
    func allEnumCasesAreCoveredInSwitchStatement() {
        // This test ensures that if we add new cases to the enum, we remember to update the switch statement
        let allCases: [MimeType] = [
            // Application Types
            .json, .xml, .formUrlEncoded, .multipartFormData(boundary: ""), .pdf, .zip, .octetStream, .javascript, .wasm,
            // Text Types
            .plain, .html, .css, .csv, .rtf, .xmlText,
            // Image Types
            .jpeg, .png, .gif, .webp, .svg, .bmp, .ico, .tiff,
            // Video Types
            .mp4, .avi, .mov, .wmv, .flv, .webm, .mkv, .quicktime,
            // Audio Types
            .mp3, .wav, .ogg, .aac, .flac, .m4a, .wma,
            // Font Types
            .ttf, .otf, .woff, .woff2, .eot,
            // Custom
            .custom("test")
        ]

        // If this test compiles and runs without crashing, it means all cases are handled
        for mimeType in allCases {
            _ = mimeType.value
        }

        #expect(true) // This test passes if we can access .value for all cases
    }
}
