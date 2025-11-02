# Deploy to VPS - Step-by-Step Instructions

**Target VPS:** 213.111.146.201 (hodlxxi.com)
**Current Status:** ✅ Database persistence deployed and working
**Next Step:** Production hardening with SSL/TLS and security

---

## ⚠️ CRITICAL: DNS Configuration Required

Before running the deployment, **verify DNS is configured**:

```bash
# On your VPS, run:
dig hodlxxi.com +short
```

**Expected result:** `213.111.146.201`

If not configured:
1. Go to your domain registrar (Namecheap, GoDaddy, Cloudflare, etc.)
2. Add A record: `hodlxxi.com` → `213.111.146.201`
3. Add A record: `www.hodlxxi.com` → `213.111.146.201`
4. Wait 5-60 minutes for DNS propagation
5. Verify with `dig hodlxxi.com` again

---

## 🚀 Option 1: Automated Deployment (RECOMMENDED)

### Connect to Your VPS

```bash
ssh root@213.111.146.201
```

### Run One-Command Deployment

```bash
cd /srv/chat
git pull origin claude/audit-production-readiness-011CUhkaP74L7sLirhV5Mnds
cd deployment
sudo bash deploy-production.sh
```

**What this does:**
1. ✅ Installs Nginx and Certbot
2. ✅ Obtains SSL certificate from Let's Encrypt
3. ✅ Configures reverse proxy with security headers
4. ✅ Enables UFW firewall (ports 22, 80, 443)
5. ✅ Installs Fail2ban for brute-force protection
6. ✅ Creates dedicated `hodlxxi` user
7. ✅ Hardens systemd service
8. ✅ Sets up automated daily backups
9. ✅ Restarts application with new configuration

**Estimated time:** 10-15 minutes

---

## 🔧 Option 2: Manual Step-by-Step Deployment

If you prefer to run each step manually:

### Step 1: Pull Latest Code

```bash
cd /srv/chat
git pull origin claude/audit-production-readiness-011CUhkaP74L7sLirhV5Mnds
```

### Step 2: Review Nginx Configuration

```bash
cat deployment/nginx-hodlxxi.conf
# Verify domain name and settings
```

### Step 3: Run Security Hardening

```bash
cd deployment
sudo bash security-hardening.sh
```

This will:
- Configure UFW firewall
- Install Fail2ban
- Create hodlxxi user
- Secure file permissions
- Update systemd service

### Step 4: Install Nginx

```bash
sudo apt update
sudo apt install -y nginx certbot python3-certbot-nginx
```

### Step 5: Deploy Nginx Configuration

```bash
sudo cp nginx-hodlxxi.conf /etc/nginx/sites-available/hodlxxi
sudo ln -s /etc/nginx/sites-available/hodlxxi /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo mkdir -p /var/www/certbot
```

### Step 6: Obtain SSL Certificate

```bash
sudo systemctl stop nginx
sudo certbot certonly --nginx \
    -d hodlxxi.com \
    -d www.hodlxxi.com \
    --non-interactive \
    --agree-tos \
    --email admin@hodlxxi.com
```

### Step 7: Start Nginx

```bash
sudo nginx -t
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Step 8: Set Up Automated Backups

```bash
sudo bash setup-automated-backups.sh
```

### Step 9: Restart Application

```bash
sudo systemctl daemon-reload
sudo systemctl restart app
```

---

## ✅ Verification

### Test All Endpoints

```bash
# Test local application
curl http://127.0.0.1:5000/health

# Test through Nginx HTTP (should redirect)
curl -I http://hodlxxi.com/health

# Test through Nginx HTTPS (should work)
curl https://hodlxxi.com/health

# Test OAuth status
curl https://hodlxxi.com/oauthx/status | jq
```

### Check Services

```bash
sudo systemctl status app nginx postgresql redis-server fail2ban
```

### Check Firewall

```bash
sudo ufw status verbose
```

### Check SSL Certificate

```bash
sudo certbot certificates
```

---

## 🎯 Expected Results

After successful deployment:

### Working HTTPS URLs
- ✅ https://hodlxxi.com
- ✅ https://hodlxxi.com/health
- ✅ https://hodlxxi.com/oauthx/status
- ✅ https://hodlxxi.com/.well-known/openid-configuration

### Security Features
- ✅ SSL/TLS with TLS 1.2 and 1.3
- ✅ HTTP to HTTPS redirect
- ✅ Security headers (HSTS, CSP, X-Frame-Options, etc.)
- ✅ Firewall blocking all ports except 22, 80, 443
- ✅ Fail2ban protecting SSH and Nginx
- ✅ Application running as non-root user

### Automated Operations
- ✅ Daily backups at 2:00 AM
- ✅ SSL certificate auto-renewal (twice daily check)
- ✅ Service auto-restart on failure

---

## 🚨 Troubleshooting

### Issue: SSL Certificate Fails

**Error:** "Failed to obtain certificate"

**Solution:**
```bash
# Check DNS
dig hodlxxi.com +short
# Should return: 213.111.146.201

# If wrong, wait for DNS propagation and try again
# If correct, check port 80:
sudo ufw allow 80/tcp
sudo netstat -tlnp | grep :80
```

### Issue: Application Won't Start

**Error:** Service fails after restart

**Solution:**
```bash
# Check logs
sudo journalctl -u app -n 50

# Fix permissions
sudo chown -R hodlxxi:hodlxxi /srv/chat
sudo systemctl restart app
```

### Issue: 502 Bad Gateway

**Error:** Nginx shows 502 error

**Solution:**
```bash
# Check application is running
sudo systemctl status app
curl http://127.0.0.1:5000/health

# If not running, check why:
sudo journalctl -u app -n 100
```

### Issue: Locked Out by Firewall

**Prevention:** Script keeps SSH port 22 open by default

**Recovery:** Access via VPS console (DigitalOcean/Linode dashboard):
```bash
sudo ufw disable
sudo ufw allow 22/tcp
sudo ufw enable
```

---

## 📞 Post-Deployment Tasks

### 1. Test OAuth Flow

```bash
# Register a client
curl -X POST https://hodlxxi.com/oauth/register \
    -H 'Content-Type: application/json' \
    -d '{"redirect_uris":["http://localhost:3000/callback"]}' | jq

# Test the complete OAuth flow with the demo script
bash /srv/chat/demo_oauth.sh
```

### 2. Set Up External Monitoring

Sign up for free uptime monitoring:
- **UptimeRobot:** https://uptimerobot.com (free tier)
- Monitor: `https://hodlxxi.com/health` every 5 minutes
- Alert via email on downtime

### 3. Verify Backups

```bash
# Check backup was created
ls -lh /backup/hodlxxi/

# Check backup logs
tail -50 /var/log/hodlxxi/backup.log

# Verify cron job
crontab -u hodlxxi -l
```

### 4. Test Restore Procedure

```bash
# Create test backup
sudo /usr/local/bin/hodlxxi-backup.sh

# Test restore (USE WITH CAUTION - creates test scenario)
# Don't run on production without first backing up!
```

---

## 📊 Monitoring Commands

Save these for daily operations:

```bash
# Quick status check
sudo systemctl status app nginx postgresql redis-server

# Check logs
sudo journalctl -u app -f

# Check resource usage
htop

# Check disk space
df -h

# Check backups
ls -lh /backup/hodlxxi/ | tail -5

# Check SSL expiry
sudo certbot certificates
```

---

## 🎉 Success Criteria

Your deployment is complete when:

- [ ] `curl https://hodlxxi.com/health` returns `{"status":"ok"}`
- [ ] Browser shows **secure connection** (padlock icon)
- [ ] No certificate warnings
- [ ] `sudo systemctl status app` shows **active (running)**
- [ ] `sudo ufw status` shows **active** with ports 22, 80, 443
- [ ] `ls /backup/hodlxxi/` shows backup files
- [ ] `crontab -u hodlxxi -l` shows backup cron job
- [ ] OAuth flow works: `curl https://hodlxxi.com/oauthx/status`

---

## 📚 Documentation

After deployment, review:
- `deployment/README.md` - Full deployment guide
- `deployment/QUICK_REFERENCE.md` - Command reference card
- `PRODUCTION_STATUS.md` - Production readiness assessment
- `DEPLOY_DATABASE.md` - Database deployment details

---

## 🆘 Need Help?

If deployment fails:

1. **Check the logs:**
   ```bash
   sudo journalctl -u app -n 100 --no-pager
   sudo tail -50 /var/log/nginx/hodlxxi-error.log
   ```

2. **Review deployment script output** - It shows detailed progress

3. **Verify prerequisites:**
   - DNS configured
   - Ports 80/443 accessible
   - Application was running before deployment

4. **Rollback if needed:**
   ```bash
   sudo systemctl stop nginx
   sudo ufw disable
   sudo systemctl restart app
   ```

---

**Ready to deploy? Run:**

```bash
ssh root@213.111.146.201
cd /srv/chat && git pull origin claude/audit-production-readiness-011CUhkaP74L7sLirhV5Mnds && cd deployment && sudo bash deploy-production.sh
```

**Good luck! 🚀**
