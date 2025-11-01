# HODLXXI API Complete Documentation

Welcome to the comprehensive documentation for the HODLXXI Bitcoin API. This documentation covers all aspects of the API, from development to production deployment.

## 📚 Documentation Files

### 1. [API Response Examples](./API_RESPONSE_EXAMPLES.md)
**17 KB** | Complete API endpoint reference with request/response examples

**Contents:**
- All API endpoints with examples
- Authentication endpoints (LNURL-auth, OAuth2/OIDC, Signature verification)
- Bitcoin wallet operations
- Chat and messaging
- Proof of Funds (PoF) system
- WebSocket events
- Rate limiting and pagination

**Use this when:**
- Integrating with the API
- Understanding endpoint behavior
- Debugging API calls
- Writing client applications

---

### 2. [Error Code Documentation](./ERROR_CODE_DOCUMENTATION.md)
**24 KB** | Complete error code reference and handling guide

**Contents:**
- All error codes (1000-7099) with descriptions
- HTTP status codes
- Error response formats
- Error handling best practices
- Client-side error handling examples
- Security considerations
- Monitoring and testing strategies

**Use this when:**
- Handling API errors
- Implementing error recovery
- Debugging issues
- Building robust clients
- Setting up monitoring

---

### 3. [Security Requirements and Best Practices](./SECURITY_REQUIREMENTS.md)
**31 KB** | Comprehensive security guide

**Contents:**
- Security architecture (defense in depth)
- Authentication security (cryptographic signatures, sessions, MFA)
- API security (rate limiting, input validation, CORS, CSRF)
- Bitcoin wallet security (RPC, encryption, cold storage)
- Network security (TLS, firewall, DDoS protection)
- Data protection (encryption at rest, secrets management)
- Monitoring and incident response
- Compliance and audit requirements

**Use this when:**
- Deploying to production
- Security audits
- Implementing authentication
- Configuring infrastructure
- Responding to incidents

---

### 4. [Token Expiration and Refresh Policies](./TOKEN_POLICIES.md)
**33 KB** | Complete token lifecycle management guide

**Contents:**
- All token types (access, refresh, OAuth codes, sessions, etc.)
- Expiration policies for each token type
- Token refresh mechanisms (automatic, rotation, silent)
- Security considerations (storage, leakage prevention, binding)
- Token revocation (manual, bulk, automatic)
- Complete client implementation examples
- Troubleshooting common token issues

**Use this when:**
- Implementing authentication
- Managing user sessions
- Handling token refresh
- Building OAuth2 clients
- Debugging authentication issues

---

### 5. [Production Deployment Guidelines](./PRODUCTION_DEPLOYMENT.md)
**29 KB** | Step-by-step production deployment guide

**Contents:**
- Infrastructure requirements
- Pre-deployment checklist
- Deployment architectures (single server, high availability)
- Environment configuration
- Database setup (PostgreSQL, SQLite)
- Bitcoin Core setup
- Application deployment with systemd
- Nginx reverse proxy configuration
- SSL/TLS setup with Let's Encrypt
- Monitoring and logging (Prometheus, Grafana, ELK)
- Backup and disaster recovery
- Scaling strategies
- Troubleshooting guide

**Use this when:**
- Deploying to production
- Setting up infrastructure
- Configuring services
- Scaling the application
- Planning disaster recovery

---

### 6. [OAuth2/OIDC and LNURL-Auth Specification](./OAUTH_LNURL_SPECIFICATION.md)
**48 KB** | Complete OAuth2, OpenID Connect, and LNURL-Auth technical specification

**Contents:**
- OAuth 2.0 implementation (RFC 6749 compliant)
- OpenID Connect (OIDC Core 1.0)
- Complete grant type flows (authorization_code, refresh_token, client_credentials)
- Detailed scope definitions (openid, profile, wallet:*, chat:*, pof:*, admin)
- Client registration specification with all fields
- LNURL-Auth complete implementation (LUD-04)
- Complete endpoint reference with parameters
- Integration examples (React, Python, service-to-service)
- PKCE implementation
- Token management
- Security best practices

**Use this when:**
- Implementing OAuth2 authentication
- Integrating LNURL-auth
- Registering OAuth clients
- Understanding scope permissions
- Building authentication flows
- Implementing Lightning wallet login

---

## 🚀 Quick Start Guide

### For Developers

1. **Start with** [OAuth2/OIDC and LNURL-Auth Specification](./OAUTH_LNURL_SPECIFICATION.md)
   - Understand OAuth flows
   - Learn LNURL-auth integration
   - Review scope definitions
   - See complete integration examples

2. **Reference** [API Response Examples](./API_RESPONSE_EXAMPLES.md)
   - Understand available endpoints
   - See request/response formats
   - Learn authentication flows

3. **Read** [Error Code Documentation](./ERROR_CODE_DOCUMENTATION.md)
   - Implement proper error handling
   - Understand error codes
   - Add retry logic

4. **Review** [Token Policies](./TOKEN_POLICIES.md)
   - Implement token refresh
   - Store tokens securely
   - Handle token expiration

### For DevOps/SysAdmins

1. **Start with** [Production Deployment Guidelines](./PRODUCTION_DEPLOYMENT.md)
   - Set up infrastructure
   - Configure services
   - Deploy application

2. **Review** [Security Requirements](./SECURITY_REQUIREMENTS.md)
   - Implement security measures
   - Configure firewalls
   - Set up monitoring

3. **Reference** [Error Code Documentation](./ERROR_CODE_DOCUMENTATION.md)
   - Set up alerting
   - Configure logging
   - Plan incident response

### For Security Teams

1. **Start with** [Security Requirements](./SECURITY_REQUIREMENTS.md)
   - Review security architecture
   - Audit implementation
   - Test security measures

2. **Review** [Token Policies](./TOKEN_POLICIES.md)
   - Audit token management
   - Review refresh mechanisms
   - Test revocation

3. **Check** [Production Deployment Guidelines](./PRODUCTION_DEPLOYMENT.md)
   - Verify secure configuration
   - Review backup procedures
   - Test disaster recovery

---

## 📋 Pre-Production Checklist

Use this checklist before going to production:

### Security
- [ ] Read [Security Requirements](./SECURITY_REQUIREMENTS.md) completely
- [ ] All secrets in environment variables
- [ ] SSL/TLS certificates configured
- [ ] Firewall rules configured
- [ ] Rate limiting enabled
- [ ] Bitcoin wallet encrypted
- [ ] Security audit completed

### Infrastructure
- [ ] Follow [Production Deployment Guidelines](./PRODUCTION_DEPLOYMENT.md)
- [ ] Bitcoin Core node synced
- [ ] Database configured and backed up
- [ ] Nginx reverse proxy configured
- [ ] Monitoring tools installed
- [ ] Log aggregation configured
- [ ] Backup system tested

### Application
- [ ] Reference [API Response Examples](./API_RESPONSE_EXAMPLES.md)
- [ ] All endpoints tested
- [ ] WebSocket connections tested
- [ ] Error handling implemented per [Error Code Documentation](./ERROR_CODE_DOCUMENTATION.md)
- [ ] Token refresh implemented per [Token Policies](./TOKEN_POLICIES.md)
- [ ] Health check responding
- [ ] Load testing completed

### Operations
- [ ] Monitoring dashboards configured
- [ ] Alerts set up
- [ ] Backup automation configured
- [ ] Disaster recovery plan documented
- [ ] Team trained on operations
- [ ] Runbooks created

---

## 🔧 Common Integration Patterns

### Pattern 1: Web Application with OAuth2

**Files needed:**
1. [OAuth2/OIDC Specification](./OAUTH_LNURL_SPECIFICATION.md) - OAuth flows
2. [API Response Examples](./API_RESPONSE_EXAMPLES.md) - API endpoints
3. [Token Policies](./TOKEN_POLICIES.md) - Token management
4. [Error Code Documentation](./ERROR_CODE_DOCUMENTATION.md) - Error handling

**Implementation steps:**
```javascript
// 1. Initialize OAuth service (from OAuth/LNURL Specification)
import OAuthService from './oauthService';
const oauth = new OAuthService({
  clientId: CLIENT_ID,
  redirectUri: REDIRECT_URI,
  baseUrl: API_BASE,
  scope: 'openid profile wallet:read'
});

// 2. Start OAuth flow
oauth.login(); // Redirects to authorization page

// 3. Handle callback
const tokens = await oauth.handleCallback();

// 4. Make authenticated API calls (from API Response Examples)
const balance = await oauth.apiRequest('/api/wallet/balance');
```

---

### Pattern 2: Lightning Wallet Authentication (LNURL-auth)

**Files needed:**
1. [OAuth2/OIDC Specification](./OAUTH_LNURL_SPECIFICATION.md) - LNURL-auth flow
2. [API Response Examples](./API_RESPONSE_EXAMPLES.md) - LNURL endpoints
3. [Token Policies](./TOKEN_POLICIES.md) - Token storage

**Implementation steps:**
```javascript
// 1. Create LNURL-auth session
const response = await fetch('/api/lnurl-auth/create', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
});
const { session_id, lnurl } = await response.json();

// 2. Display LNURL as QR code
displayQRCode(lnurl);

// 3. Poll for authentication (from OAuth/LNURL Specification)
const pollResult = await pollAuthStatus(session_id);

// 4. Store tokens securely (from Token Policies)
secureStorage.setItem('access_token', pollResult.access_token);
secureStorage.setItem('refresh_token', pollResult.refresh_token);
```

---

### Pattern 3: Mobile App Integration

**Files needed:**
1. [OAuth2/OIDC Specification](./OAUTH_LNURL_SPECIFICATION.md) - LNURL-auth + OAuth
2. [Token Policies](./TOKEN_POLICIES.md) - Mobile token storage
3. [Security Requirements](./SECURITY_REQUIREMENTS.md) - Mobile security

**Implementation steps:**
```javascript
// 1. Use LNURL-auth for Lightning wallet authentication
const session = await createLNURLAuthSession();
// Display LNURL QR code to user
// Poll for authentication completion

// 2. Store tokens securely (Token Policies)
await SecureStore.setItemAsync('access_token', tokens.access_token);
await SecureStore.setItemAsync('refresh_token', tokens.refresh_token);

// 3. Implement background token refresh
setupTokenRefresh();
```

---

### Pattern 3: Backend Service Integration

**Files needed:**
1. [API Response Examples](./API_RESPONSE_EXAMPLES.md) - Service-to-service auth
2. [Security Requirements](./SECURITY_REQUIREMENTS.md) - API security
3. [Production Deployment Guidelines](./PRODUCTION_DEPLOYMENT.md) - Service deployment

**Implementation steps:**
```python
# 1. Service account authentication
client_credentials = {
    'grant_type': 'client_credentials',
    'client_id': SERVICE_CLIENT_ID,
    'client_secret': SERVICE_CLIENT_SECRET
}

# 2. Make authenticated requests
response = requests.post('/oauth/token', json=client_credentials)
access_token = response.json()['access_token']

# 3. Use token for API calls
headers = {'Authorization': f'Bearer {access_token}'}
balance = requests.get('/api/wallet/balance', headers=headers)
```

---

## 🐛 Troubleshooting Guide

### Issue: Token Expired Errors

**Relevant docs:**
- [Token Policies](./TOKEN_POLICIES.md) - Section on "Troubleshooting Common Issues"
- [Error Code Documentation](./ERROR_CODE_DOCUMENTATION.md) - Error code 2003

**Solution:**
1. Implement automatic token refresh
2. Check for clock skew
3. Verify refresh token is valid

---

### Issue: RPC Connection Failed

**Relevant docs:**
- [Production Deployment Guidelines](./PRODUCTION_DEPLOYMENT.md) - "Bitcoin Core Setup" section
- [Error Code Documentation](./ERROR_CODE_DOCUMENTATION.md) - Error code 4000

**Solution:**
1. Verify Bitcoin Core is running: `systemctl status bitcoind`
2. Check RPC credentials
3. Verify RPC is bound to correct interface

---

### Issue: Rate Limit Exceeded

**Relevant docs:**
- [API Response Examples](./API_RESPONSE_EXAMPLES.md) - "Rate Limiting" section
- [Error Code Documentation](./ERROR_CODE_DOCUMENTATION.md) - Error code 1006
- [Security Requirements](./SECURITY_REQUIREMENTS.md) - "API Security" section

**Solution:**
1. Implement exponential backoff
2. Respect Retry-After header
3. Consider request batching

---

### Issue: OAuth Invalid Redirect URI

**Relevant docs:**
- [OAuth2/OIDC Specification](./OAUTH_LNURL_SPECIFICATION.md) - "Client Registration" section
- [Error Code Documentation](./ERROR_CODE_DOCUMENTATION.md) - OAuth errors

**Solution:**
1. Ensure redirect_uri exactly matches registered URI
2. Check for trailing slashes
3. Verify HTTPS (required in production)

---

### Issue: LNURL-Auth QR Code Not Working

**Relevant docs:**
- [OAuth2/OIDC Specification](./OAUTH_LNURL_SPECIFICATION.md) - "LNURL-Auth Specification"
- [API Response Examples](./API_RESPONSE_EXAMPLES.md) - LNURL endpoints

**Solution:**
1. Verify LNURL is properly encoded
2. Check session hasn't expired (5 min timeout)
3. Ensure Lightning wallet supports LNURL-auth
4. Test with compatible wallet (Zeus, Breez, BlueWallet)

---

## 📞 Support

For additional help:

**Documentation Issues:**
- File an issue on GitHub
- Contact: docs@yourdomain.com

**Security Issues:**
- Email: security@yourdomain.com
- PGP key available at: https://yourdomain.com/security.pgp

**Technical Support:**
- Email: support@yourdomain.com
- Forum: https://forum.yourdomain.com

---

## 📝 Document Revision History

| Date | Version | Changes |
|------|---------|---------|
| 2024-10-29 | 1.0.0 | Initial comprehensive documentation release |

---

**Last Updated:** October 29, 2024

**Documentation Coverage:**
- ✅ Complete API reference
- ✅ All error codes documented
- ✅ Security requirements
- ✅ Token management
- ✅ Production deployment
- ✅ OAuth2/OIDC flows
- ✅ LNURL-Auth implementation
- ✅ Scope definitions
- ✅ Client registration
- ✅ Troubleshooting guides
- ✅ Integration examples

**Total Documentation:** 190 KB across 6 comprehensive files
