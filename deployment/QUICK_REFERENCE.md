# HODLXXI Production - Quick Reference Card

## 🚀 One-Command Deployment

```bash
cd /srv/chat && git pull origin claude/audit-production-readiness-011CUhkaP74L7sLirhV5Mnds && cd deployment && sudo bash deploy-production.sh
```

---

## 📋 Pre-Deployment Checklist

- [ ] DNS configured: `hodlxxi.com` → `213.111.146.201`
- [ ] SSH access as root
- [ ] Application currently running
- [ ] PostgreSQL working
- [ ] Redis working
- [ ] Port 80 accessible

---

## 🔧 Common Commands

### Service Management
```bash
# Status
sudo systemctl status app nginx postgresql redis-server

# Restart
sudo systemctl restart app nginx

# Logs
sudo journalctl -u app -f
sudo tail -f /var/log/nginx/hodlxxi-error.log
```

### Backup & Restore
```bash
# Manual backup
sudo /usr/local/bin/hodlxxi-backup.sh

# List backups
ls -lh /backup/hodlxxi/

# Restore
sudo /usr/local/bin/hodlxxi-restore.sh /backup/hodlxxi/hodlxxi_db_YYYYMMDD_HHMMSS.sql.gz
```

### SSL Certificate
```bash
# Check certificate
sudo certbot certificates

# Renew
sudo certbot renew

# Test renewal
sudo certbot renew --dry-run
```

### Firewall
```bash
# Status
sudo ufw status verbose

# Allow port
sudo ufw allow 8333/tcp

# Deny port
sudo ufw deny 8333/tcp
```

### Fail2ban
```bash
# Status
sudo fail2ban-client status
sudo fail2ban-client status sshd

# Unban IP
sudo fail2ban-client set sshd unbanip 1.2.3.4
```

---

## 🧪 Testing Endpoints

```bash
# Health check
curl https://hodlxxi.com/health

# OAuth status
curl https://hodlxxi.com/oauthx/status | jq

# Test OAuth registration
curl -X POST https://hodlxxi.com/oauth/register \
    -H 'Content-Type: application/json' \
    -d '{"redirect_uris":["http://localhost:3000/callback"]}' | jq
```

---

## 🚨 Emergency Procedures

### Application Won't Start
```bash
# Check logs
sudo journalctl -u app -n 100 --no-pager

# Fix permissions
sudo chown -R hodlxxi:hodlxxi /srv/chat
sudo systemctl restart app
```

### Nginx Shows 502
```bash
# Check app is running
sudo systemctl status app
curl http://127.0.0.1:5000/health

# Restart
sudo systemctl restart app nginx
```

### Locked Out by Firewall
```bash
# Via VPS console:
sudo ufw disable
sudo ufw allow 22/tcp
sudo ufw enable
```

### Database Issues
```bash
# Check status
sudo systemctl status postgresql
sudo -u postgres psql -c "SELECT version();"

# Restart
sudo systemctl restart postgresql
```

### Restore from Backup
```bash
# 1. Stop app
sudo systemctl stop app

# 2. List backups
ls -lh /backup/hodlxxi/

# 3. Restore
sudo /usr/local/bin/hodlxxi-restore.sh /backup/hodlxxi/hodlxxi_db_YYYYMMDD_HHMMSS.sql.gz

# 4. Start app
sudo systemctl start app
```

---

## 📊 Monitoring

### Check System Resources
```bash
# CPU/Memory
htop

# Disk space
df -h

# Check backup size
du -sh /backup/hodlxxi/

# Database size
sudo -u postgres psql -c "\l+ hodlxxi"
```

### Check Application Health
```bash
# Process count
ps aux | grep gunicorn | wc -l

# Open connections
sudo netstat -tnp | grep :5000

# Redis info
redis-cli -a RedisSecure2025! INFO | grep connected_clients
```

---

## 📁 Important Locations

| Item | Location |
|------|----------|
| Application | `/srv/chat` |
| Virtual Env | `/srv/chat/venv` |
| Nginx Config | `/etc/nginx/sites-available/hodlxxi` |
| App Logs | `journalctl -u app` |
| Nginx Logs | `/var/log/nginx/hodlxxi-*.log` |
| Backups | `/backup/hodlxxi/` |
| SSL Certs | `/etc/letsencrypt/live/hodlxxi.com/` |
| Backup Script | `/usr/local/bin/hodlxxi-backup.sh` |
| Restore Script | `/usr/local/bin/hodlxxi-restore.sh` |

---

## 🔐 Security Settings

| Feature | Status | Details |
|---------|--------|---------|
| HTTPS | ✅ | TLS 1.2, 1.3 |
| Firewall | ✅ | UFW (22, 80, 443) |
| Fail2ban | ✅ | SSH + Nginx |
| App User | ✅ | hodlxxi (non-root) |
| Rate Limiting | ✅ | 100/min API, 20/min auth |
| Auto Backups | ✅ | Daily 2:00 AM |
| SSL Auto-Renew | ✅ | Twice daily check |

---

## 🌐 Production URLs

| Endpoint | URL |
|----------|-----|
| Main Site | https://hodlxxi.com |
| Health Check | https://hodlxxi.com/health |
| OAuth Status | https://hodlxxi.com/oauthx/status |
| OAuth Docs | https://hodlxxi.com/oauthx/docs |
| Discovery | https://hodlxxi.com/.well-known/openid-configuration |

---

## 📞 Quick Diagnostics

Run this to get full status:
```bash
cat << 'EOF' | sudo bash
echo "=== HODLXXI System Status ==="
echo ""
echo "Services:"
systemctl is-active app && echo "  ✓ App" || echo "  ✗ App"
systemctl is-active nginx && echo "  ✓ Nginx" || echo "  ✗ Nginx"
systemctl is-active postgresql && echo "  ✓ PostgreSQL" || echo "  ✗ PostgreSQL"
systemctl is-active redis-server && echo "  ✓ Redis" || echo "  ✗ Redis"
echo ""
echo "Disk:"
df -h / | tail -1
echo ""
echo "Memory:"
free -h | grep Mem:
echo ""
echo "Backups:"
ls -lh /backup/hodlxxi/ | tail -3
echo ""
echo "SSL:"
certbot certificates 2>/dev/null | grep Expiry || echo "  No certificate"
echo ""
echo "Firewall:"
ufw status | grep Status:
EOF
```

---

**Print this page and keep it handy for quick reference!**
