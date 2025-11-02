# HODLXXI Production Deployment - Option A

**Minimal Production Setup (4-6 hours)**

This guide will take your HODLXXI application from development to production-ready with:
- ✅ SSL/TLS encryption (HTTPS)
- ✅ Nginx reverse proxy
- ✅ Security hardening (firewall, fail2ban)
- ✅ Automated daily backups
- ✅ Non-root application user
- ✅ Systemd service hardening

---

## 📋 Prerequisites

Before starting, ensure:

1. **VPS Access**
   - SSH access as root or sudo user
   - Ubuntu 20.04+ or Debian 11+

2. **Application Status**
   - ✅ Application already running on VPS
   - ✅ PostgreSQL database configured and working
   - ✅ Redis configured and working
   - ✅ `/health` endpoint responding

3. **DNS Configuration** ⚠️ **CRITICAL**
   - Domain pointing to your VPS IP address
   - A record: `hodlxxi.com` → `213.111.146.201`
   - A record: `www.hodlxxi.com` → `213.111.146.201`
   - DNS propagation complete (check: `dig hodlxxi.com`)

4. **Port Access**
   - Port 80 (HTTP) - Required for Let's Encrypt
   - Port 443 (HTTPS) - Required for production traffic
   - Port 22 (SSH) - Keep open for access

---

## 🚀 Quick Start (Automated Deployment)

### Option 1: One-Command Deployment

If everything is ready and DNS is configured:

```bash
# On your VPS as root
cd /srv/chat
git pull origin claude/audit-production-readiness-011CUhkaP74L7sLirhV5Mnds
cd deployment
sudo bash deploy-production.sh
```

This single script will:
1. ✅ Install and configure Nginx
2. ✅ Obtain SSL certificate from Let's Encrypt
3. ✅ Configure UFW firewall
4. ✅ Install and configure Fail2ban
5. ✅ Create dedicated `hodlxxi` user
6. ✅ Harden systemd service
7. ✅ Set up automated daily backups
8. ✅ Restart application with new configuration

**Estimated time:** 10-15 minutes

---

### Option 2: Step-by-Step Manual Deployment

If you prefer to run each step manually or troubleshoot:

#### Step 1: Pull Latest Deployment Files

```bash
cd /srv/chat
git pull origin claude/audit-production-readiness-011CUhkaP74L7sLirhV5Mnds
cd deployment
```

#### Step 2: Review Configuration

Edit Nginx configuration if needed:
```bash
nano nginx-hodlxxi.conf
# Review domain, ports, security headers
```

#### Step 3: Run Security Hardening

```bash
sudo bash security-hardening.sh
```

This configures:
- UFW firewall (ports 22, 80, 443)
- Fail2ban for SSH and Nginx protection
- File permissions
- Dedicated `hodlxxi` user
- Hardened systemd service

#### Step 4: Install Nginx and SSL

```bash
# Install Nginx
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx

# Copy configuration
sudo cp nginx-hodlxxi.conf /etc/nginx/sites-available/hodlxxi
sudo ln -s /etc/nginx/sites-available/hodlxxi /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Create certbot directory
sudo mkdir -p /var/www/certbot

# Test configuration
sudo nginx -t
```

#### Step 5: Obtain SSL Certificate

```bash
# Stop Nginx temporarily
sudo systemctl stop nginx

# Obtain certificate
sudo certbot certonly --nginx \
    -d hodlxxi.com \
    -d www.hodlxxi.com \
    --non-interactive \
    --agree-tos \
    --email admin@hodlxxi.com

# Enable auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

#### Step 6: Start Nginx

```bash
# Test configuration with SSL
sudo nginx -t

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

#### Step 7: Set Up Automated Backups

```bash
sudo bash setup-automated-backups.sh
```

This creates:
- Backup script: `/usr/local/bin/hodlxxi-backup.sh`
- Restore script: `/usr/local/bin/hodlxxi-restore.sh`
- Cron job: Daily backup at 2:00 AM
- Backup directory: `/backup/hodlxxi/`

#### Step 8: Restart Application

```bash
sudo systemctl daemon-reload
sudo systemctl restart app
```

---

## 🧪 Verification

### Test Endpoints

```bash
# Test application directly (should work)
curl http://127.0.0.1:5000/health

# Test through Nginx HTTP (should redirect to HTTPS)
curl -I http://hodlxxi.com/health

# Test through Nginx HTTPS (should work)
curl https://hodlxxi.com/health
```

### Check Services

```bash
# Check all services
sudo systemctl status app nginx postgresql redis-server fail2ban

# Check firewall
sudo ufw status

# Check SSL certificate
sudo certbot certificates

# Check backups
ls -lh /backup/hodlxxi/
```

### Test OAuth Flow

```bash
# Get OAuth status
curl -s https://hodlxxi.com/oauthx/status | jq

# Test OAuth registration
curl -X POST https://hodlxxi.com/oauth/register \
    -H 'Content-Type: application/json' \
    -d '{"redirect_uris":["http://localhost:3000/callback"]}' | jq
```

---

## 📊 What Gets Configured

### 1. Nginx Reverse Proxy

**Configuration:** `/etc/nginx/sites-available/hodlxxi`

Features:
- SSL/TLS termination with modern ciphers (TLS 1.2, 1.3)
- HTTP to HTTPS redirect
- Security headers (HSTS, X-Frame-Options, CSP, etc.)
- Rate limiting:
  - API endpoints: 100 requests/minute
  - Auth endpoints: 20 requests/minute
- WebSocket proxy for `/socket.io`
- Connection pooling
- OCSP stapling
- HTTP/2 support

### 2. SSL/TLS Certificate

**Provider:** Let's Encrypt
**Location:** `/etc/letsencrypt/live/hodlxxi.com/`
**Auto-renewal:** Twice daily via systemd timer

Includes:
- `fullchain.pem` - Certificate + intermediate chain
- `privkey.pem` - Private key
- `chain.pem` - Intermediate certificates

### 3. UFW Firewall

**Allowed ports:**
- `22/tcp` - SSH
- `80/tcp` - HTTP (for Let's Encrypt + redirect)
- `443/tcp` - HTTPS

**Default policy:** Deny all incoming, allow all outgoing

### 4. Fail2ban

**Protected services:**
- SSH (3 failed attempts → 1 hour ban)
- Nginx HTTP auth
- Nginx rate limit violations
- Nginx bot searches

**Configuration:** `/etc/fail2ban/jail.local`

### 5. Application User

**User:** `hodlxxi` (non-root)
**Home:** `/home/hodlxxi`
**Owns:** `/srv/chat`, `/var/log/hodlxxi`

### 6. Systemd Service Hardening

**Service:** `/etc/systemd/system/app.service`

Security features:
- Runs as `hodlxxi:hodlxxi` (not root)
- `NoNewPrivileges=true` - Cannot escalate privileges
- `PrivateTmp=true` - Isolated /tmp directory
- `ProtectSystem=strict` - Read-only system directories
- `ProtectHome=true` - No access to user home directories
- Resource limits (65535 file descriptors, 4096 processes)

### 7. Automated Backups

**Script:** `/usr/local/bin/hodlxxi-backup.sh`
**Schedule:** Daily at 2:00 AM
**Location:** `/backup/hodlxxi/`
**Retention:** 30 days

Backs up:
- PostgreSQL database (compressed)
- Redis data (RDB file)
- Application configuration (.env, systemd service, nginx config)

---

## 🔧 Maintenance & Operations

### Daily Operations

**Check application logs:**
```bash
sudo journalctl -u app -f
```

**Check Nginx logs:**
```bash
sudo tail -f /var/log/nginx/hodlxxi-access.log
sudo tail -f /var/log/nginx/hodlxxi-error.log
```

**Check service status:**
```bash
sudo systemctl status app nginx postgresql redis-server
```

### Manual Backup

```bash
sudo /usr/local/bin/hodlxxi-backup.sh
```

### Restore from Backup

```bash
# List available backups
ls -lh /backup/hodlxxi/

# Restore specific backup
sudo /usr/local/bin/hodlxxi-restore.sh /backup/hodlxxi/hodlxxi_db_20251102_020000.sql.gz
```

### SSL Certificate Management

**Check certificate:**
```bash
sudo certbot certificates
```

**Renew manually (normally automatic):**
```bash
sudo certbot renew
```

**Test renewal:**
```bash
sudo certbot renew --dry-run
```

### Firewall Management

**Check status:**
```bash
sudo ufw status verbose
```

**Add rule:**
```bash
sudo ufw allow 8333/tcp comment 'Bitcoin P2P'
```

**Remove rule:**
```bash
sudo ufw delete allow 8333/tcp
```

### Fail2ban Management

**Check status:**
```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

**Unban IP:**
```bash
sudo fail2ban-client set sshd unbanip 1.2.3.4
```

---

## 🚨 Troubleshooting

### Issue: SSL Certificate Failed to Obtain

**Symptoms:**
- Certbot error during deployment
- "Failed to obtain certificate"

**Solutions:**

1. **Check DNS:**
   ```bash
   dig hodlxxi.com
   # Should return your VPS IP: 213.111.146.201
   ```

2. **Check port 80 is accessible:**
   ```bash
   sudo ufw status | grep 80
   sudo netstat -tlnp | grep :80
   ```

3. **Manual certificate request:**
   ```bash
   sudo systemctl stop nginx
   sudo certbot certonly --standalone -d hodlxxi.com -d www.hodlxxi.com
   sudo systemctl start nginx
   ```

### Issue: Application Won't Start

**Symptoms:**
- `systemctl status app` shows failed

**Solutions:**

1. **Check logs:**
   ```bash
   sudo journalctl -u app -n 100 --no-pager
   ```

2. **Check permissions:**
   ```bash
   ls -la /srv/chat
   # Should be owned by hodlxxi:hodlxxi
   ```

3. **Fix permissions:**
   ```bash
   sudo chown -R hodlxxi:hodlxxi /srv/chat
   sudo systemctl restart app
   ```

4. **Test manually:**
   ```bash
   sudo -u hodlxxi /srv/chat/venv/bin/gunicorn -k eventlet -w 1 -b 127.0.0.1:5000 wsgi:app
   ```

### Issue: Nginx Shows 502 Bad Gateway

**Symptoms:**
- HTTPS works but shows 502 error

**Solutions:**

1. **Check application is running:**
   ```bash
   sudo systemctl status app
   curl http://127.0.0.1:5000/health
   ```

2. **Check Nginx logs:**
   ```bash
   sudo tail -n 50 /var/log/nginx/hodlxxi-error.log
   ```

3. **Restart services:**
   ```bash
   sudo systemctl restart app
   sudo systemctl restart nginx
   ```

### Issue: Firewall Locked Me Out

**⚠️ CRITICAL:** If you lose SSH access:

**Prevention:**
- Always keep SSH port 22 open
- Test firewall rules before logging out

**Recovery:**
- Access via VPS console (DigitalOcean, Linode, etc.)
- Disable firewall: `sudo ufw disable`
- Reconfigure and re-enable

### Issue: Backup Failed

**Check backup logs:**
```bash
sudo tail -n 100 /var/log/hodlxxi/backup.log
```

**Test backup manually:**
```bash
sudo /usr/local/bin/hodlxxi-backup.sh
```

**Common causes:**
- PostgreSQL not running
- Insufficient disk space
- Permission issues

---

## 📈 Next Steps (Optional Enhancements)

After successful deployment, consider:

### 1. External Monitoring

Set up uptime monitoring:
- **UptimeRobot** (free tier): https://uptimerobot.com
- **Pingdom** (paid): https://www.pingdom.com
- **StatusCake** (free tier): https://www.statuscake.com

Monitor:
- `https://hodlxxi.com/health` every 5 minutes
- Alert via email/Slack on downtime

### 2. Prometheus + Grafana

For detailed metrics and dashboards:

```bash
# Install node exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xzf node_exporter-1.6.1.linux-amd64.tar.gz
sudo cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
```

### 3. Log Aggregation

For centralized logging:
- Loki + Grafana (lightweight)
- ELK Stack (full-featured)
- Cloud solution (AWS CloudWatch, Datadog)

### 4. Performance Testing

Benchmark your deployment:

```bash
# Install Apache Bench
sudo apt install apache2-utils

# Test performance
ab -n 10000 -c 100 https://hodlxxi.com/health

# Install wrk for advanced testing
git clone https://github.com/wg/wrk.git
cd wrk
make
sudo cp wrk /usr/local/bin/
wrk -t4 -c100 -d30s https://hodlxxi.com/health
```

### 5. Database Optimization

Tune PostgreSQL for your workload:

```bash
# Edit PostgreSQL config
sudo nano /etc/postgresql/*/main/postgresql.conf

# Recommended for 8GB RAM:
shared_buffers = 2GB
effective_cache_size = 6GB
work_mem = 64MB
maintenance_work_mem = 512MB
```

### 6. Horizontal Scaling

Add more application servers:

1. Deploy app to multiple servers
2. Update Nginx upstream:
   ```nginx
   upstream hodlxxi_app {
       server 10.0.1.10:5000;
       server 10.0.1.11:5000;
       server 10.0.1.12:5000;
   }
   ```
3. Use Redis for shared session storage
4. Use PostgreSQL replication

---

## 📚 Additional Resources

**Documentation:**
- `PRODUCTION_STATUS.md` - Complete production readiness assessment
- `DEPLOY_DATABASE.md` - Database deployment guide
- `app/PRODUCTION_DEPLOYMENT.md` - Full deployment guide (Option B)

**Scripts:**
- `deploy-production.sh` - Master deployment script
- `security-hardening.sh` - Security configuration
- `setup-automated-backups.sh` - Backup configuration
- `nginx-hodlxxi.conf` - Nginx configuration

**Logs:**
- Application: `journalctl -u app -f`
- Nginx: `/var/log/nginx/hodlxxi-*.log`
- Backups: `/var/log/hodlxxi/backup.log`
- System: `journalctl -f`

---

## 🎯 Summary

After completing this deployment, you'll have:

✅ **Security:**
- HTTPS encryption with TLS 1.2/1.3
- Firewall protecting all ports
- Fail2ban blocking brute-force attacks
- Non-root application user
- Hardened systemd service

✅ **Reliability:**
- Automated daily backups (30-day retention)
- Service auto-restart on failure
- SSL auto-renewal

✅ **Performance:**
- Nginx reverse proxy with caching
- HTTP/2 support
- Rate limiting
- Connection pooling

✅ **Operations:**
- Health check endpoint
- Structured logging
- Easy backup/restore
- Service monitoring

**Your HODLXXI application is now production-ready! 🎉**

---

## 🆘 Support

If you encounter issues:

1. Check logs: `sudo journalctl -u app -n 100`
2. Review this guide's troubleshooting section
3. Check service status: `sudo systemctl status app nginx`
4. Test endpoints manually with curl

For emergencies:
- Rollback firewall: `sudo ufw disable`
- Stop services: `sudo systemctl stop nginx`
- Restore backup: `sudo /usr/local/bin/hodlxxi-restore.sh <backup-file>`

---

**Version:** 1.0
**Last Updated:** 2025-11-02
**Deployment Target:** hodlxxi.com (213.111.146.201)
