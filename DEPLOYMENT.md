# OpenWebUI VPS Deployment Guide

## Step-by-Step Setup Instructions

### Prerequisites
- VPS with SSH access
- Docker installed on VPS
- PostgreSQL installed on VPS (already available)
- Kamal installed locally (`gem install kamal`)
- GitHub Container Registry access

---

## STEP 1: Prepare Your VPS

### 1.1 SSH into your VPS
```bash
ssh -i /path/to/key ubuntu@your.vps.ip.address
```

### 1.2 Update system packages
```bash
sudo apt update && sudo apt upgrade -y
```

### 1.3 Install Docker (if not already installed)
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
```

### 1.4 Install Docker Compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 1.5 Verify PostgreSQL is running
```bash
sudo systemctl status postgresql
```

---

## STEP 2: Create PostgreSQL Database

### 2.1 Connect to PostgreSQL
```bash
sudo -u postgres psql
```

### 2.2 Create database and user
```sql
CREATE DATABASE openwebui;
CREATE USER openwebui WITH PASSWORD 'your_secure_password';
ALTER ROLE openwebui SET client_encoding TO 'utf8';
ALTER ROLE openwebui SET default_transaction_isolation TO 'read committed';
ALTER ROLE openwebui SET default_transaction_deferrable TO on;
ALTER ROLE openwebui SET default_transaction_level TO 'read committed';
GRANT ALL PRIVILEGES ON DATABASE openwebui TO openwebui;
ALTER DATABASE openwebui OWNER TO openwebui;
\q
```

### 2.3 Verify database connection
```bash
psql -U openwebui -d openwebui -h localhost -c "\l"
```

---

## STEP 3: Create Deployment Directories

### 3.1 Create data directory on VPS
```bash
sudo mkdir -p /data/openwebui
sudo chown ubuntu:ubuntu /data/openwebui
sudo chmod 755 /data/openwebui
```

### 3.2 Create Docker data volumes path
```bash
sudo mkdir -p /var/lib/docker/volumes/openwebui_data/_data
sudo chown ubuntu:ubuntu /var/lib/docker/volumes/openwebui_data/_data
```

---

## STEP 4: Configure Environment Variables

### 4.1 Create .env file

**On your LOCAL machine** (not on VPS):

```bash
cp .env.example .env
```

### 4.2 Fill in your .env file

Edit `.env` with your specific values:

```bash
# VPS Configuration
VPS_IP_ADDRESS=your.actual.vps.ip
VPS_SSH_USER=ubuntu
VPS_SSH_KEY_PATH=/path/to/your/private/key

# Database
DB_USER=openwebui
DB_PASSWORD=your_secure_password  # MUST match what you set in PostgreSQL
DB_NAME=openwebui
DB_HOST=your.actual.vps.ip
DB_PORT=5432

# OpenWebUI
OPENWEBUI_PORT=8080
WEBUI_SECRET_KEY=$(openssl rand -hex 32)  # Generate with: openssl rand -hex 32

# GitHub Container Registry
GITHUB_USERNAME=your_github_username
KAMAL_REGISTRY_PASSWORD=ghp_your_github_personal_access_token
```

### 4.3 Generate a secure secret key
```bash
openssl rand -hex 32
```
Copy the output and paste it into WEBUI_SECRET_KEY in your .env file.

---

## STEP 5: Configure Kamal

### 5.1 Update config/deploy.yml

Replace placeholders with your actual values:

```yaml
servers:
  web:
    hosts:
      - YOUR.VPS.IP.ADDRESS  # e.g., 192.168.1.100
    user: ubuntu  # or your VPS user
```

### 5.2 Set environment variables for Kamal

```bash
export VPS_IP_ADDRESS="your.vps.ip.address"
export VPS_SSH_USER="ubuntu"
export DB_USER="openwebui"
export DB_PASSWORD="your_secure_password"
export DB_NAME="openwebui"
export WEBUI_SECRET_KEY="$(openssl rand -hex 32)"
export KAMAL_REGISTRY_PASSWORD="your_github_token"
```

---

## STEP 6: Deploy with Kamal

### 6.1 Install Kamal locally (if not installed)
```bash
gem install kamal
```

### 6.2 Test SSH connection
```bash
kamal server exec 'uname -a'
```

### 6.3 Deploy OpenWebUI
```bash
kamal deploy
```

### 6.4 Monitor deployment
```bash
kamal logs -f
```

### 6.5 Check container status
```bash
kamal status
```

---

## STEP 7: Verify Deployment

### 7.1 Check if OpenWebUI is running
```bash
curl -I http://your.vps.ip.address:8080
```

You should see:
```
HTTP/1.1 200 OK
```

### 7.2 Access OpenWebUI in browser

Open your browser and navigate to:
```
http://your.vps.ip.address:8080
```

### 7.3 Check container logs
```bash
kamal logs
```

### 7.4 Verify database connection
```bash
kamal exec 'psql -U openwebui -d openwebui -h <VPS_IP> -c "SELECT version();"'
```

---

## STEP 8: Optional - Add SSL/TLS with Nginx

### 8.1 Install Nginx on VPS
```bash
sudo apt install nginx -y
```

### 8.2 Create Nginx configuration
```bash
sudo nano /etc/nginx/sites-available/openwebui
```

Add:
```nginx
server {
    listen 80;
    server_name your.domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### 8.3 Enable and restart Nginx
```bash
sudo ln -s /etc/nginx/sites-available/openwebui /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 8.4 Install SSL with Certbot
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your.domain.com
```

---

## STEP 9: Common Management Commands

### Restart OpenWebUI
```bash
kamal reboot
```

### Update OpenWebUI to latest version
```bash
kamal redeploy
```

### Stop OpenWebUI
```bash
kamal stop
```

### Remove deployment
```bash
kamal remove
```

### View logs in real-time
```bash
kamal logs -f
```

### Execute commands in container
```bash
kamal exec 'ps aux'
```

---

## Troubleshooting

### Database connection fails
```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Verify credentials
psql -U openwebui -d openwebui -h localhost -c "\l"
```

### Container won't start
```bash
# Check logs
kamal logs

# Verify Docker image is pulled
docker images | grep open-webui
```

### Port already in use
```bash
# Find process using port 8080
sudo lsof -i :8080

# Kill process
sudo kill -9 <PID>
```

### Low disk space
```bash
df -h
docker system prune -a
```

---

## Security Best Practices

1. **Change default credentials**: Set strong password for OpenWebUI admin account
2. **Use firewall**: Restrict port access to only needed IPs
3. **Enable SSL/TLS**: Use self-signed or Let's Encrypt certificates
4. **Regular backups**: Backup PostgreSQL database regularly
5. **Update Docker image**: Keep OpenWebUI image updated

---

## Next Steps

1. Configure LLM providers (OpenAI, Ollama, etc.)
2. Add users and manage permissions
3. Set up monitoring and alerts
4. Configure automated backups for database
