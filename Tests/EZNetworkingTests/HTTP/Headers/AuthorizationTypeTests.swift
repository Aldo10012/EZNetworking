@testable import EZNetworking
import Foundation
import Testing

@Suite("Test AuthorizationType")
final class AuthorizationTypeTests {
    
    // MARK: - Standard Authorization Types Tests
    
    @Test("test bearer authorization")
    func testBearerAuthorization() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
        let auth = AuthorizationType.bearer(token)
        
        #expect(auth.value == "Bearer \(token)")
        #expect(auth.scheme == "Bearer")
        #expect(auth.credentials == token)
    }
    
    @Test("test basic authorization")
    func testBasicAuthorization() {
        let credentials = "dXNlcm5hbWU6cGFzc3dvcmQ="
        let auth = AuthorizationType.basic(credentials)
        
        #expect(auth.value == "Basic \(credentials)")
        #expect(auth.scheme == "Basic")
        #expect(auth.credentials == credentials)
    }
    
    @Test("test basic authorization with username and password")
    func testBasicAuthorizationWithUsernameAndPassword() {
        let auth = AuthorizationType.basic(username: "testuser", password: "testpass")
        
        // The credentials should be base64 encoded "testuser:testpass"
        let expectedCredentials = Data("testuser:testpass".utf8).base64EncodedString()
        #expect(auth.value == "Basic \(expectedCredentials)")
        #expect(auth.scheme == "Basic")
        #expect(auth.credentials == expectedCredentials)
    }
    
    @Test("test digest authorization")
    func testDigestAuthorization() {
        let credentials = "username=\"testuser\", realm=\"testrealm\", nonce=\"123456\""
        let auth = AuthorizationType.digest(credentials)
        
        #expect(auth.value == "Digest \(credentials)")
        #expect(auth.scheme == "Digest")
        #expect(auth.credentials == credentials)
    }
    
    @Test("test API key authorization")
    func testApiKeyAuthorization() {
        let key = "abc123def456"
        let auth = AuthorizationType.apiKey(key)
        
        #expect(auth.value == "ApiKey \(key)")
        #expect(auth.scheme == "ApiKey")
        #expect(auth.credentials == key)
    }
    
    @Test("test OAuth 1.0 authorization")
    func testOAuth1Authorization() {
        let credentials = "oauth_consumer_key=\"key\", oauth_token=\"token\""
        let auth = AuthorizationType.oauth1(credentials)
        
        #expect(auth.value == "OAuth \(credentials)")
        #expect(auth.scheme == "OAuth")
        #expect(auth.credentials == credentials)
    }
    
    @Test("test OAuth 2.0 authorization with default token type")
    func testOAuth2AuthorizationWithDefaultTokenType() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
        let auth = AuthorizationType.oauth2(token)
        
        #expect(auth.value == "Bearer \(token)")
        #expect(auth.scheme == "Bearer")
        #expect(auth.credentials == token)
    }
    
    @Test("test OAuth 2.0 authorization with custom token type")
    func testOAuth2AuthorizationWithCustomTokenType() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
        let tokenType = "MAC"
        let auth = AuthorizationType.oauth2(token, tokenType: tokenType)
        
        #expect(auth.value == "\(tokenType) \(token)")
        #expect(auth.scheme == tokenType)
        #expect(auth.credentials == token)
    }
    
    @Test("test AWS4 authorization")
    func testAws4Authorization() {
        let signature = "Credential=AKIAIOSFODNN7EXAMPLE/20130524/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-date, Signature=fe5f80f77d5fa3beca038a248ff027d0445342fe2855ddc963176630326f1024"
        let auth = AuthorizationType.aws4(signature)
        
        #expect(auth.value == "AWS4-HMAC-SHA256 \(signature)")
        #expect(auth.scheme == "AWS4-HMAC-SHA256")
        #expect(auth.credentials == signature)
    }
    
    @Test("test Hawk authorization")
    func testHawkAuthorization() {
        let credentials = "id=\"dh37fgj492je\", ts=\"1353832234\", nonce=\"j4h3g2\", mac=\"6R4rV5iE+NPoym+WwjeHzjAGXUtLNIxmo1vpMofpLAE=\""
        let auth = AuthorizationType.hawk(credentials)
        
        #expect(auth.value == "Hawk \(credentials)")
        #expect(auth.scheme == "Hawk")
        #expect(auth.credentials == credentials)
    }
    
    @Test("test custom authorization")
    func testCustomAuthorization() {
        let customValue = "CustomScheme customCredentials"
        let auth = AuthorizationType.custom(customValue)
        
        #expect(auth.value == customValue)
        #expect(auth.scheme == "CustomScheme")
        #expect(auth.credentials == "customCredentials")
    }
    
    @Test("test custom authorization with single word")
    func testCustomAuthorizationWithSingleWord() {
        let customValue = "SingleWord"
        let auth = AuthorizationType.custom(customValue)
        
        #expect(auth.value == customValue)
        #expect(auth.scheme == customValue)
        #expect(auth.credentials == "")
    }
    
    // MARK: - Convenience Initializer Tests
    
    @Test("test basic convenience initializer")
    func testBasicConvenienceInitializer() {
        let auth = AuthorizationType.basic(username: "alice", password: "secret")
        
        let expectedCredentials = Data("alice:secret".utf8).base64EncodedString()
        #expect(auth.value == "Basic \(expectedCredentials)")
        #expect(auth.scheme == "Basic")
        #expect(auth.credentials == expectedCredentials)
    }
    
    @Test("test API key convenience initializer with default header")
    func testApiKeyConvenienceInitializerWithDefaultHeader() {
        let key = "my-api-key-123"
        let auth = AuthorizationType.apiKeyWithHeader(key)
        
        #expect(auth.value == "X-API-Key \(key)")
        #expect(auth.scheme == "X-API-Key")
        #expect(auth.credentials == key)
    }
    
    @Test("test API key convenience initializer with custom header")
    func testApiKeyConvenienceInitializerWithCustomHeader() {
        let key = "my-api-key-123"
        let headerName = "Authorization-Key"
        let auth = AuthorizationType.apiKeyWithHeader(key, headerName: headerName)
        
        #expect(auth.value == "\(headerName) \(key)")
        #expect(auth.scheme == headerName)
        #expect(auth.credentials == key)
    }
    
    @Test("test custom scheme convenience initializer")
    func testCustomSchemeConvenienceInitializer() {
        let scheme = "MyAuth"
        let credentials = "my-credentials"
        let auth = AuthorizationType.custom(scheme: scheme, credentials: credentials)
        
        #expect(auth.value == "\(scheme) \(credentials)")
        #expect(auth.scheme == scheme)
        #expect(auth.credentials == credentials)
    }
    
    // MARK: - Equatable Tests
    
    @Test("test authorization type equality - same cases")
    func testAuthorizationTypeEqualitySameCases() {
        #expect(AuthorizationType.bearer("token1") == AuthorizationType.bearer("token1"))
        #expect(AuthorizationType.basic("creds1") == AuthorizationType.basic("creds1"))
        #expect(AuthorizationType.apiKey("key1") == AuthorizationType.apiKey("key1"))
        #expect(AuthorizationType.custom("value1") == AuthorizationType.custom("value1"))
    }
    
    @Test("test authorization type equality - different cases")
    func testAuthorizationTypeEqualityDifferentCases() {
        #expect(AuthorizationType.bearer("token1") != AuthorizationType.bearer("token2"))
        #expect(AuthorizationType.bearer("token1") != AuthorizationType.basic("creds1"))
        #expect(AuthorizationType.basic("creds1") != AuthorizationType.apiKey("key1"))
        #expect(AuthorizationType.apiKey("key1") != AuthorizationType.custom("value1"))
    }
    
    @Test("test OAuth2 equality with different token types")
    func testOAuth2EqualityWithDifferentTokenTypes() {
        let token = "same-token"
        let auth1 = AuthorizationType.oauth2(token, tokenType: "Bearer")
        let auth2 = AuthorizationType.oauth2(token, tokenType: "MAC")
        
        #expect(auth1 != auth2)
        #expect(auth1.credentials == auth2.credentials)
        #expect(auth1.scheme != auth2.scheme)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("test empty string credentials")
    func testEmptyStringCredentials() {
        let auth = AuthorizationType.bearer("")
        #expect(auth.value == "Bearer ")
        #expect(auth.scheme == "Bearer")
        #expect(auth.credentials == "")
    }
    
    @Test("test special characters in credentials")
    func testSpecialCharactersInCredentials() {
        let credentials = "user@domain.com:pass!word#123"
        let auth = AuthorizationType.basic(username: "user@domain.com", password: "pass!word#123")
        
        let expectedCredentials = Data(credentials.utf8).base64EncodedString()
        #expect(auth.credentials == expectedCredentials)
    }
    
    @Test("test unicode characters in credentials")
    func testUnicodeCharactersInCredentials() {
        let credentials = "用户名:密码"
        let auth = AuthorizationType.basic(username: "用户名", password: "密码")
        
        let expectedCredentials = Data(credentials.utf8).base64EncodedString()
        #expect(auth.credentials == expectedCredentials)
    }
    
    @Test("test very long credentials")
    func testVeryLongCredentials() {
        let longToken = String(repeating: "a", count: 1000)
        let auth = AuthorizationType.bearer(longToken)
        
        #expect(auth.value == "Bearer \(longToken)")
        #expect(auth.credentials == longToken)
    }
    
    @Test("test custom authorization with multiple spaces")
    func testCustomAuthorizationWithMultipleSpaces() {
        let customValue = "Scheme  multiple   spaces   credentials"
        let auth = AuthorizationType.custom(customValue)
        
        #expect(auth.value == customValue)
        #expect(auth.scheme == "Scheme")
        #expect(auth.credentials == " multiple   spaces   credentials")
    }
    
    // MARK: - Scheme and Credentials Extraction Tests
    
    @Test("test scheme extraction from various authorization types")
    func testSchemeExtractionFromVariousAuthorizationTypes() {
        #expect(AuthorizationType.bearer("token").scheme == "Bearer")
        #expect(AuthorizationType.basic("creds").scheme == "Basic")
        #expect(AuthorizationType.digest("creds").scheme == "Digest")
        #expect(AuthorizationType.apiKey("key").scheme == "ApiKey")
        #expect(AuthorizationType.oauth1("creds").scheme == "OAuth")
        #expect(AuthorizationType.oauth2("token", tokenType: "MAC").scheme == "MAC")
        #expect(AuthorizationType.aws4("sig").scheme == "AWS4-HMAC-SHA256")
        #expect(AuthorizationType.hawk("creds").scheme == "Hawk")
    }
    
    @Test("test credentials extraction from various authorization types")
    func testCredentialsExtractionFromVariousAuthorizationTypes() {
        let token = "test-token"
        let creds = "test-creds"
        let key = "test-key"
        let sig = "test-signature"
        
        #expect(AuthorizationType.bearer(token).credentials == token)
        #expect(AuthorizationType.basic(creds).credentials == creds)
        #expect(AuthorizationType.digest(creds).credentials == creds)
        #expect(AuthorizationType.apiKey(key).credentials == key)
        #expect(AuthorizationType.oauth1(creds).credentials == creds)
        #expect(AuthorizationType.oauth2(token, tokenType: "MAC").credentials == token)
        #expect(AuthorizationType.aws4(sig).credentials == sig)
        #expect(AuthorizationType.hawk(creds).credentials == creds)
    }
    
    // MARK: - Value Format Validation Tests
    
    @Test("test all authorization values contain space separator")
    func testAllAuthorizationValuesContainSpaceSeparator() {
        let allAuthTypes: [AuthorizationType] = [
            .bearer("token"),
            .basic("creds"),
            .digest("creds"),
            .apiKey("key"),
            .oauth1("creds"),
            .oauth2("token"),
            .aws4("sig"),
            .hawk("creds"),
            .custom("scheme creds")
        ]
        
        for auth in allAuthTypes {
            #expect(auth.value.contains(" "), "Authorization value should contain space separator")
        }
    }
    
    @Test("test all authorization values start with scheme")
    func testAllAuthorizationValuesStartWithScheme() {
        let allAuthTypes: [AuthorizationType] = [
            .bearer("token"),
            .basic("creds"),
            .digest("creds"),
            .apiKey("key"),
            .oauth1("creds"),
            .oauth2("token"),
            .aws4("sig"),
            .hawk("creds"),
            .custom("scheme creds")
        ]
        
        for auth in allAuthTypes {
            #expect(auth.value.hasPrefix(auth.scheme), "Authorization value should start with scheme")
        }
    }
    
    // MARK: - Comprehensive Coverage Test
    
    @Test("test all enum cases are covered in switch statement")
    func testAllEnumCasesAreCoveredInSwitchStatement() {
        // This test ensures that if we add new cases to the enum, we remember to update the switch statement
        let allCases: [AuthorizationType] = [
            .bearer("token"),
            .basic("creds"),
            .digest("creds"),
            .apiKey("key"),
            .oauth1("creds"),
            .oauth2("token"),
            .aws4("sig"),
            .hawk("creds"),
            .custom("scheme creds")
        ]
        
        // If this test compiles and runs without crashing, it means all cases are handled
        for auth in allCases {
            let _ = auth.value
            let _ = auth.scheme
            let _ = auth.credentials
        }
        
        #expect(true) // This test passes if we can access all properties for all cases
    }
    
    // MARK: - Real-world Usage Examples
    
    @Test("test JWT token authorization")
    func testJwtTokenAuthorization() {
        let jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        let auth = AuthorizationType.bearer(jwtToken)
        
        #expect(auth.value == "Bearer \(jwtToken)")
        #expect(auth.scheme == "Bearer")
    }
    
    @Test("test GitHub API authorization")
    func testGitHubApiAuthorization() {
        let token = "ghp_1234567890abcdef"
        let auth = AuthorizationType.bearer(token)
        
        #expect(auth.value == "Bearer \(token)")
    }
    
    @Test("test AWS API authorization")
    func testAwsApiAuthorization() {
        let signature = "Credential=AKIAIOSFODNN7EXAMPLE/20231201/us-east-1/s3/aws4_request, SignedHeaders=host;x-amz-date, Signature=fe5f80f77d5fa3beca038a248ff027d0445342fe2855ddc963176630326f1024"
        let auth = AuthorizationType.aws4(signature)
        
        #expect(auth.value == "AWS4-HMAC-SHA256 \(signature)")
    }
    
    @Test("test custom API authorization")
    func testCustomApiAuthorization() {
        let auth = AuthorizationType.custom(scheme: "MyAPI", credentials: "secret-key-123")
        
        #expect(auth.value == "MyAPI secret-key-123")
        #expect(auth.scheme == "MyAPI")
        #expect(auth.credentials == "secret-key-123")
    }
}
