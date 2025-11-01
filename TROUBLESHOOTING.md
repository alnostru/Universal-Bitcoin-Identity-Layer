# Troubleshooting Guide

> Common issues and solutions for HODLXXI Universal Bitcoin Identity Layer

## Table of Contents

- [Installation Issues](#installation-issues)
- [Configuration Problems](#configuration-problems)
- [Authentication Issues](#authentication-issues)
- [Bitcoin Core Issues](#bitcoin-core-issues)
- [Database Problems](#database-problems)
- [API Errors](#api-errors)
- [Performance Issues](#performance-issues)
- [WebSocket Issues](#websocket-issues)
- [Proof of Funds Issues](#proof-of-funds-issues)
- [Debug Mode](#debug-mode)
- [Log Analysis](#log-analysis)
- [Getting Help](#getting-help)

---

## Installation Issues

### Problem: `pip install` fails with dependency conflicts

**Symptoms:**
```
ERROR: Cannot install requirements
ERROR: ResolutionImpossible
```

**Solutions:**

1. **Update pip and setuptools:**
```bash
python -m pip install --upgrade pip setuptools wheel
```

2. **Use a fresh virtual environment:**
```bash
rm -rf venv/
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

3. **Install dependencies one by one to identify the conflict:**
```bash
pip install flask
pip install flask-socketio
# Continue...
```

---

### Problem: Docker build fails

**Symptoms:**
```
ERROR: failed to solve: process "/bin/sh -c pip install -r requirements.txt" did not complete successfully
```

**Solutions:**

1. **Clear Docker cache:**
```bash
docker system prune -a
docker-compose build --no-cache
```

2. **Check Docker daemon:**
```bash
docker info
# Ensure Docker is running
```

3. **Increase Docker resources:**
- Docker Desktop → Settings → Resources
- Increase Memory to at least 4GB
- Increase Disk space if needed

4. **Check Dockerfile syntax:**
```bash
docker build --progress=plain .  # See detailed output
```

---

## Configuration Problems

### Problem: Environment variables not loading

**Symptoms:**
```
KeyError: 'BITCOIN_RPC_USER'
Configuration error: Missing required environment variable
```

**Solutions:**

1. **Verify .env file exists:**
```bash
ls -la .env
# If not, copy from example:
cp .env.example .env
```

2. **Check .env file syntax:**
```bash
# Correct format:
BITCOIN_RPC_USER=your_username
BITCOIN_RPC_PASSWORD=your_password

# Incorrect (no quotes, no export):
export BITCOIN_RPC_USER="your_username"  # Wrong!
```

3. **Load .env manually:**
```bash
# Using python-dotenv
python -c "from dotenv import load_dotenv; load_dotenv(); import os; print(os.getenv('BITCOIN_RPC_USER'))"
```

4. **Check file permissions:**
```bash
chmod 600 .env  # Make readable only by owner
```

---

### Problem: Flask application won't start

**Symptoms:**
```
OSError: [Errno 48] Address already in use
```

**Solutions:**

1. **Find and kill process using port 5000:**
```bash
# On macOS/Linux:
lsof -i :5000
kill -9 <PID>

# On Windows:
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

2. **Change port in configuration:**
```bash
# In .env:
FLASK_PORT=5001
```

3. **Use a different port when running:**
```bash
python app/app.py --port 5001
```

---

## Authentication Issues

### Problem: OAuth2 authorization fails with "invalid_client"

**Symptoms:**
```json
{
  "error": "invalid_client",
  "error_description": "Client authentication failed"
}
```

**Solutions:**

1. **Verify client credentials:**
```bash
# Check client_id and client_secret are correct
# In your OAuth client registration
```

2. **Check client exists in database:**
```sql
SELECT * FROM oauth_clients WHERE client_id = 'your_client_id';
```

3. **Ensure client_secret is not hashed on the client side:**
```python
# Correct:
data = {
    'client_id': 'abc123',
    'client_secret': 'plaintext_secret'  # Not hashed
}
```

4. **Verify redirect URI matches exactly:**
```python
# Database has: http://localhost:3000/callback
# Request must use: http://localhost:3000/callback
# NOT: http://localhost:3000/callback/
#      http://127.0.0.1:3000/callback
```

---

### Problem: LNURL-Auth signature verification fails

**Symptoms:**
```json
{
  "status": "ERROR",
  "reason": "Invalid signature"
}
```

**Solutions:**

1. **Verify k1 challenge hasn't expired:**
```python
# Challenges expire after 5 minutes
# Generate new challenge and try again
```

2. **Check signature format:**
```bash
# Signature should be hex-encoded DER format
# Example: 3045022100...
```

3. **Verify public key format:**
```bash
# Should be 33 bytes (compressed) or 65 bytes (uncompressed)
# Hex-encoded
# Example: 02a1633cafcc01ebfb6d78e39f687a1f0995c62fc95f51ead10a02ee0be551b5dc
```

4. **Test signature generation:**
```python
from ecdsa import SigningKey, SECP256k1
import hashlib

# Your wallet should sign the k1 challenge like this:
k1 = "your_challenge_hex"
message_hash = hashlib.sha256(bytes.fromhex(k1)).digest()
signature = private_key.sign(message_hash)
```

---

### Problem: Session expires too quickly

**Symptoms:**
- User logged out after a few minutes
- "Session expired" errors

**Solutions:**

1. **Increase session timeout in configuration:**
```python
# In config.py or .env:
SESSION_TIMEOUT = 3600  # 1 hour in seconds
```

2. **Enable session refresh:**
```python
# Client should refresh session before expiry
# Use /oauth/token with refresh_token
```

3. **Check Redis session storage:**
```bash
redis-cli
> KEYS session:*
> TTL session:your_session_id  # Check time to live
```

---

## Bitcoin Core Issues

### Problem: Cannot connect to Bitcoin Core RPC

**Symptoms:**
```
ConnectionRefusedError: [Errno 111] Connection refused
bitcoin.rpc.JSONRPCError: -28: Loading block index...
```

**Solutions:**

1. **Verify Bitcoin Core is running:**
```bash
# Check if bitcoind is running
ps aux | grep bitcoind

# Start if not running:
bitcoind -daemon -server
```

2. **Check bitcoin.conf:**
```bash
# ~/.bitcoin/bitcoin.conf should have:
server=1
rpcuser=your_username
rpcpassword=your_password
rpcport=8332
rpcallowip=127.0.0.1
```

3. **Wait for blockchain sync:**
```bash
bitcoin-cli getblockchaininfo
# Check "blocks" vs "headers" - should be equal when synced
```

4. **Test RPC connection:**
```bash
bitcoin-cli -rpcuser=your_username -rpcpassword=your_password getblockchaininfo
```

5. **For regtest mode:**
```bash
bitcoind -regtest -daemon -server -rpcuser=test -rpcpassword=test
bitcoin-cli -regtest -rpcuser=test -rpcpassword=test getblockchaininfo
```

---

### Problem: Bitcoin wallet not found

**Symptoms:**
```
bitcoin.rpc.JSONRPCError: -18: Requested wallet does not exist or is not loaded
```

**Solutions:**

1. **List available wallets:**
```bash
bitcoin-cli listwallets
```

2. **Create new wallet:**
```bash
bitcoin-cli createwallet "hodlxxi_wallet"
```

3. **Load existing wallet:**
```bash
bitcoin-cli loadwallet "hodlxxi_wallet"
```

4. **Check wallet location:**
```bash
ls ~/.bitcoin/wallets/
# Or for regtest:
ls ~/.bitcoin/regtest/wallets/
```

---

### Problem: Insufficient funds for transactions

**Symptoms:**
```
bitcoin.rpc.JSONRPCError: -6: Insufficient funds
```

**Solutions:**

1. **Check wallet balance:**
```bash
bitcoin-cli getbalance
```

2. **For regtest, generate blocks to get coins:**
```bash
# Get new address
ADDRESS=$(bitcoin-cli getnewaddress)

# Generate 101 blocks (coinbase maturity)
bitcoin-cli generatetoaddress 101 $ADDRESS

# Check balance
bitcoin-cli getbalance
```

3. **For mainnet/testnet, receive coins:**
- Use a faucet for testnet
- Purchase or receive Bitcoin for mainnet

---

## Database Problems

### Problem: Database connection errors

**Symptoms:**
```
sqlalchemy.exc.OperationalError: (psycopg2.OperationalError) could not connect to server
```

**Solutions:**

1. **Verify PostgreSQL is running:**
```bash
# macOS:
brew services list | grep postgresql

# Linux:
systemctl status postgresql

# Start if not running:
brew services start postgresql  # macOS
sudo systemctl start postgresql  # Linux
```

2. **Check database exists:**
```bash
psql -l | grep hodlxxi
# Create if not exists:
createdb hodlxxi
```

3. **Test connection:**
```bash
psql -U your_username -d hodlxxi -h localhost
```

4. **Check DATABASE_URL format:**
```bash
# Correct format:
DATABASE_URL=postgresql://username:password@localhost:5432/hodlxxi

# Common mistakes:
# - Missing postgresql:// prefix
# - Wrong port (default is 5432)
# - Special characters in password not URL-encoded
```

---

### Problem: Database migrations fail

**Symptoms:**
```
alembic.util.exc.CommandError: Target database is not up to date
```

**Solutions:**

1. **Check migration status:**
```bash
flask db current  # or: alembic current
```

2. **Run pending migrations:**
```bash
flask db upgrade head  # or: alembic upgrade head
```

3. **Reset migrations (CAUTION - loses data):**
```bash
flask db downgrade base
flask db upgrade head
```

4. **Generate new migration:**
```bash
flask db migrate -m "Description of changes"
flask db upgrade
```

---

### Problem: Database locked (SQLite only)

**Symptoms:**
```
sqlite3.OperationalError: database is locked
```

**Solutions:**

1. **Close all connections:**
```python
# Ensure your code closes connections properly
db.session.close()
```

2. **Use PostgreSQL for production:**
```bash
# SQLite is not suitable for concurrent access
# Switch to PostgreSQL
```

3. **Increase timeout:**
```python
# In config:
SQLALCHEMY_ENGINE_OPTIONS = {
    'connect_args': {'timeout': 30}
}
```

---

## API Errors

### Problem: 429 Too Many Requests

**Symptoms:**
```json
{
  "error_code": "rate_limit_exceeded",
  "message": "Too many requests"
}
```

**Solutions:**

1. **Wait and retry:**
```python
import time
import requests

for i in range(3):
    response = requests.get(url)
    if response.status_code == 429:
        retry_after = int(response.headers.get('Retry-After', 60))
        time.sleep(retry_after)
        continue
    break
```

2. **Check rate limit configuration:**
```bash
# In .env:
RATE_LIMIT_DEFAULT=100/hour
RATE_LIMIT_AUTH=10/minute
```

3. **Use exponential backoff:**
```python
import time
import requests

def api_call_with_retry(url, max_retries=5):
    for i in range(max_retries):
        response = requests.get(url)
        if response.status_code != 429:
            return response
        wait_time = 2 ** i  # 1, 2, 4, 8, 16 seconds
        time.sleep(wait_time)
    raise Exception("Max retries exceeded")
```

---

### Problem: 401 Unauthorized

**Symptoms:**
```json
{
  "error_code": "invalid_token",
  "message": "Token is invalid or expired"
}
```

**Solutions:**

1. **Check token format:**
```bash
# Should be: Authorization: Bearer <token>
# NOT: Authorization: <token>
#      Bearer <token>
```

2. **Verify token hasn't expired:**
```python
import jwt

token = "your_token"
try:
    decoded = jwt.decode(token, options={"verify_signature": False})
    print(f"Expires at: {decoded['exp']}")
except jwt.ExpiredSignatureError:
    print("Token has expired")
```

3. **Refresh the token:**
```python
response = requests.post('/oauth/token', json={
    'grant_type': 'refresh_token',
    'refresh_token': your_refresh_token,
    'client_id': your_client_id,
    'client_secret': your_client_secret
})
new_access_token = response.json()['access_token']
```

---

### Problem: 500 Internal Server Error

**Symptoms:**
```json
{
  "error_code": "internal_server_error",
  "message": "An unexpected error occurred"
}
```

**Solutions:**

1. **Check server logs:**
```bash
# Docker:
docker-compose logs app

# Direct:
tail -f logs/app.log
```

2. **Enable debug mode (development only):**
```bash
# In .env:
FLASK_ENV=development
FLASK_DEBUG=1
```

3. **Common causes:**
   - Database connection lost
   - Bitcoin Core RPC timeout
   - Unhandled exception in code
   - Out of memory
   - Disk space full

---

## Performance Issues

### Problem: Slow API responses

**Symptoms:**
- API calls take >1 second
- Timeouts on requests

**Diagnostic:**

1. **Enable query logging:**
```python
# In config:
SQLALCHEMY_ECHO = True  # Development only
```

2. **Profile slow endpoints:**
```python
from flask import Flask, request
import time

@app.before_request
def start_timer():
    request.start_time = time.time()

@app.after_request
def log_response_time(response):
    if hasattr(request, 'start_time'):
        elapsed = time.time() - request.start_time
        if elapsed > 1.0:  # Log slow requests
            print(f"Slow request: {request.path} took {elapsed:.2f}s")
    return response
```

**Solutions:**

1. **Add database indexes:**
```sql
-- Example indexes
CREATE INDEX idx_users_bitcoin_pubkey ON users(bitcoin_pubkey);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_oauth_tokens_access_token ON oauth_tokens(access_token);
```

2. **Enable Redis caching:**
```python
from flask_caching import Cache

cache = Cache(config={'CACHE_TYPE': 'redis'})
cache.init_app(app)

@app.route('/api/users/profile')
@cache.cached(timeout=300)  # Cache for 5 minutes
def get_profile():
    # ...
```

3. **Use connection pooling:**
```python
# In config:
SQLALCHEMY_ENGINE_OPTIONS = {
    'pool_size': 10,
    'pool_recycle': 3600,
    'pool_pre_ping': True
}
```

4. **Optimize Bitcoin RPC calls:**
```python
# Batch RPC calls when possible
from bitcoinrpc.authproxy import AuthServiceProxy

rpc = AuthServiceProxy("http://user:pass@127.0.0.1:8332")

# Instead of:
for address in addresses:
    balance = rpc.getreceivedbyaddress(address)  # N calls

# Do:
balances = rpc.batch_(
    [("getreceivedbyaddress", address) for address in addresses]
)  # 1 batch call
```

---

### Problem: High memory usage

**Symptoms:**
```
MemoryError
OOM (Out of Memory) killer terminated process
```

**Diagnostic:**

```bash
# Monitor memory usage
docker stats  # For Docker
top  # For direct installation
htop  # Better visualization
```

**Solutions:**

1. **Limit message history:**
```python
# Don't store all messages in memory
# Use Redis with expiry or database with pagination
```

2. **Use generators for large queries:**
```python
# Instead of:
users = User.query.all()  # Loads all into memory

# Do:
for user in User.query.yield_per(1000):  # Batches of 1000
    process(user)
```

3. **Increase Docker memory limit:**
```yaml
# docker-compose.yml
services:
  app:
    mem_limit: 4g
    mem_reservation: 2g
```

---

## WebSocket Issues

### Problem: WebSocket connection fails

**Symptoms:**
```
WebSocket connection to 'wss://domain.com/socket.io/' failed
Connection refused
```

**Solutions:**

1. **Check WebSocket is enabled:**
```python
# In app initialization:
socketio = SocketIO(app, cors_allowed_origins="*")
```

2. **Verify reverse proxy configuration:**
```nginx
# Nginx configuration:
location /socket.io {
    proxy_pass http://app:5000/socket.io;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
}
```

3. **Check firewall rules:**
```bash
# Ensure WebSocket port is open
sudo ufw allow 5000/tcp
```

4. **Test WebSocket connection:**
```python
from socketio import Client

sio = Client()
try:
    sio.connect('http://localhost:5000')
    print("Connected successfully")
except Exception as e:
    print(f"Connection failed: {e}")
```

---

### Problem: Messages not being received

**Symptoms:**
- Client sends message but doesn't appear
- No errors in console

**Solutions:**

1. **Check event names match:**
```python
# Server:
@socketio.on('chat_message')
def handle_message(data):
    emit('new_message', data, broadcast=True)

# Client:
socket.emit('chat_message', {message: 'Hello'});  # Must match
socket.on('new_message', (data) => { /* ... */ });
```

2. **Verify authentication:**
```python
# Ensure user is authenticated before joining room
@socketio.on('join_room')
def handle_join(data):
    if not session.get('user_id'):
        return {'error': 'Not authenticated'}
    join_room(data['room'])
```

3. **Check room membership:**
```python
# User must be in room to receive broadcast
join_room('room_name')
emit('message', data, room='room_name')
```

---

## Proof of Funds Issues

### Problem: PSBT verification fails

**Symptoms:**
```json
{
  "verified": false,
  "error": "Invalid PSBT format"
}
```

**Solutions:**

1. **Verify PSBT format:**
```python
from bitcoin.core.serialize import Deserialize
import base64

try:
    psbt_bytes = base64.b64decode(psbt_base64)
    # Should start with 'psbt' magic bytes
    assert psbt_bytes[:4] == b'psbt'
except Exception as e:
    print(f"Invalid PSBT: {e}")
```

2. **Check PSBT is signed:**
```bash
# Use Bitcoin Core to inspect:
bitcoin-cli decodepsbt <psbt_base64>

# Verify signatures exist:
bitcoin-cli analyzepsbt <psbt_base64>
```

3. **Ensure UTXOs are still valid:**
```bash
# UTXOs might have been spent
bitcoin-cli gettxout <txid> <vout>
# Should return UTXO details, not null
```

4. **Verify challenge hasn't expired:**
```python
# Challenges expire after 5 minutes
# Generate new challenge if expired
```

---

## Debug Mode

### Enable Debug Mode (Development Only)

**⚠️ WARNING: Never enable debug mode in production!**

```bash
# In .env:
FLASK_ENV=development
FLASK_DEBUG=1
LOG_LEVEL=DEBUG
```

### Debug Endpoints

Access debug information:

```python
# Add debug routes (development only):
@app.route('/debug/config')
def debug_config():
    if app.config['ENV'] != 'development':
        abort(404)
    return jsonify({
        'database': app.config['SQLALCHEMY_DATABASE_URI'],
        'redis': app.config.get('REDIS_URL'),
        # Don't expose secrets!
    })

@app.route('/debug/health')
def debug_health():
    return jsonify({
        'database': db.session.execute('SELECT 1').scalar() == 1,
        'redis': cache.get('test') is not None,
        'bitcoin_rpc': test_bitcoin_connection()
    })
```

---

## Log Analysis

### Log Locations

```bash
# Application logs
logs/app.log
logs/error.log

# Docker logs
docker-compose logs -f app

# System logs
/var/log/nginx/access.log
/var/log/nginx/error.log
```

### Common Log Patterns

**Authentication failures:**
```bash
grep "authentication_failed" logs/app.log
```

**Rate limit violations:**
```bash
grep "rate_limit_exceeded" logs/app.log | wc -l
```

**Database errors:**
```bash
grep "DatabaseError" logs/error.log
```

**Bitcoin RPC errors:**
```bash
grep "JSONRPCError" logs/app.log
```

### Log Analysis Tools

```bash
# Real-time log monitoring
tail -f logs/app.log | grep ERROR

# Count error types
awk '/ERROR/ {print $NF}' logs/app.log | sort | uniq -c | sort -rn

# Extract slow queries
grep "Slow query" logs/app.log | awk '{print $NF}' | sort -n
```

---

## Getting Help

### Before Asking for Help

1. **Check this troubleshooting guide** thoroughly
2. **Search existing issues** on GitHub
3. **Review documentation** in `/app` directory
4. **Check logs** for error messages
5. **Reproduce the issue** in a clean environment

### How to Ask for Help

Include the following information:

1. **System Information:**
```bash
python --version
pip list | grep -i flask
psql --version
bitcoin-cli --version
cat /etc/os-release
```

2. **Configuration (redact secrets):**
```bash
# .env file (remove passwords!)
FLASK_ENV=production
DATABASE_URL=postgresql://user:****@localhost/hodlxxi
```

3. **Error Messages:**
- Full stack trace
- Relevant log entries
- Steps to reproduce

4. **What you've tried:**
- List solutions attempted
- Results of each attempt

### Support Channels

- **GitHub Issues**: [Create an issue](https://github.com/alnostru/Universal-Bitcoin-Identity-Layer/issues)
- **GitHub Discussions**: [Start a discussion](https://github.com/alnostru/Universal-Bitcoin-Identity-Layer/discussions)
- **Email**: support@hodlxxi.com
- **Documentation**: [app/README.md](app/README.md)

### Security Issues

**DO NOT** post security vulnerabilities publicly!

- **Email**: security@hodlxxi.com
- **PGP Key**: Available at https://hodlxxi.com/pgp.asc
- See [SECURITY.md](SECURITY.md) for responsible disclosure

---

## Quick Reference

### Health Check Commands

```bash
# Check all services
curl http://localhost:5000/health

# Check Bitcoin RPC
bitcoin-cli getblockchaininfo

# Check database
psql -U hodlxxi -d hodlxxi -c "SELECT 1"

# Check Redis
redis-cli ping

# Check logs
tail -n 100 logs/app.log
```

### Restart Services

```bash
# Docker
docker-compose restart

# Individual service
docker-compose restart app

# System service
sudo systemctl restart hodlxxi

# Development server
pkill -f "python app/app.py"
python app/app.py
```

---

**Last Updated**: October 31, 2025  
**Version**: 1.0.0  
**Maintainer**: HODLXXI Team

For additional help, please visit our [documentation](app/README.md) or contact support@hodlxxi.com.
