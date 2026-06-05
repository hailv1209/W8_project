#!/bin/bash
set -e

# Logging
exec > >(tee /var/log/userdata.log)
exec 2>&1

echo "========================================="
echo "Starting XBrain K8s Challenge Setup"
echo "Time: $(date)"
echo "========================================="

# Update system
echo "[1/7] Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install dependencies
echo "[2/7] Installing dependencies..."
apt-get install -y \
    curl \
    wget \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    conntrack

# Install Docker
echo "[3/7] Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker

# Install kubectl
echo "[4/7] Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install minikube
echo "[5/7] Installing minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Start minikube as ubuntu user
echo "[6/7] Starting minikube cluster..."
su - ubuntu -c 'minikube start --driver=docker --cpus=2 --memory=2048 --ports=30080:30080'

# Wait for cluster to be ready
su - ubuntu -c 'kubectl wait --for=condition=Ready nodes --all --timeout=300s'

# Deploy app files
echo "[7/7] Creating and deploying app..."

# Create HTML page with new orange design
cat > /home/ubuntu/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xbrain x AWS Accelerator & Internship Program</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;600;700;800;900&display=swap"
        rel="stylesheet">
    <style>
        /* =============================================
           Xbrain x AWS Accelerator — Styles
           ============================================= */

        :root {
            --orange-primary: #F2913D;
            --orange-light: #F2B885;
            --orange-dark: #F27830;
            --red-accent: #D95323;
            --gray-bg: #F2F2F2;
            --white: #FFFFFF;
            --dark: #1a1a1a;
        }

        *,
        *::before,
        *::after {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Montserrat', sans-serif;
            background-color: var(--gray-bg);
            color: var(--dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* =============================================
           HERO SECTION
           ============================================= */

        .hero {
            position: relative;
            flex: 1;
            min-height: calc(100vh - 100px);
            background: linear-gradient(135deg, #F2913D 0%, #F27830 40%, #D95323 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            padding: 60px 40px;
        }

        .hero::before {
            content: '';
            position: absolute;
            inset: 0;
            background:
                radial-gradient(circle at 20% 80%, rgba(242, 120, 48, 0.6) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(242, 184, 133, 0.4) 0%, transparent 50%),
                radial-gradient(circle at 50% 50%, rgba(217, 83, 35, 0.2) 0%, transparent 70%);
            pointer-events: none;
        }

        .hero::after {
            content: '';
            position: absolute;
            inset: 0;
            background-image:
                radial-gradient(circle, rgba(255, 255, 255, 0.08) 1px, transparent 1px);
            background-size: 32px 32px;
            pointer-events: none;
        }

        .hero-content {
            position: relative;
            z-index: 2;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            gap: 40px;
            max-width: 800px;
        }

        .main-title {
            font-size: clamp(2rem, 5vw, 3.5rem);
            font-weight: 800;
            color: var(--white);
            line-height: 1.25;
            letter-spacing: -0.02em;
            text-shadow: 0 2px 20px rgba(0, 0, 0, 0.15);
        }

        .main-title .and-symbol {
            color: var(--orange-light);
            font-size: 1.1em;
        }

        .sub-title {
            font-size: clamp(1.2rem, 3vw, 1.8rem);
            font-weight: 600;
            color: rgba(255, 255, 255, 0.92);
            letter-spacing: 0.2em;
            text-transform: uppercase;
            position: relative;
            padding: 0 24px;
        }

        .sub-title::before,
        .sub-title::after {
            content: '';
            position: absolute;
            top: 50%;
            width: 16px;
            height: 2px;
            background: rgba(255, 255, 255, 0.6);
            border-radius: 1px;
        }

        .sub-title::before {
            left: 0;
        }

        .sub-title::after {
            right: 0;
        }

        /* =============================================
           FOOTER
           ============================================= */

        .footer {
            background-color: var(--dark);
            height: 100px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 60px;
            flex-shrink: 0;
        }

        .footer-brand {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            gap: 4px;
        }

        .footer-logo {
            line-height: 0;
        }

        .footer-logo svg {
            display: block;
        }

        .footer-text {
            font-size: 0.7rem;
            font-weight: 500;
            color: rgba(255, 255, 255, 0.4);
            letter-spacing: 0.12em;
            text-transform: uppercase;
        }

        /* =============================================
           CLOCK
           ============================================= */

        .clock-wrapper {
            display: flex;
            align-items: center;
        }

        .clock {
            text-align: right;
        }

        .clock-date {
            font-size: 0.7rem;
            font-weight: 600;
            color: rgba(242, 145, 61, 0.8);
            letter-spacing: 0.1em;
            text-transform: uppercase;
            margin-bottom: 2px;
        }

        .clock-time {
            font-size: 1.6rem;
            font-weight: 700;
            color: #ffffff;
            letter-spacing: 0.05em;
            font-variant-numeric: tabular-nums;
            line-height: 1;
        }

        /* =============================================
           RESPONSIVE
           ============================================= */

        @media (max-width: 768px) {
            .hero {
                flex-direction: column;
                text-align: center;
                padding: 40px 24px 48px;
            }

            .footer {
                flex-direction: column;
                height: auto;
                padding: 24px 24px 20px;
                gap: 20px;
                text-align: center;
            }

            .footer-brand {
                align-items: center;
            }

            .clock {
                text-align: center;
            }
        }

        @media (max-width: 480px) {
            .main-title {
                font-size: 1.6rem;
            }

            .sub-title {
                font-size: 1rem;
            }
        }
    </style>
</head>

<body>

    <header class="hero">
        <div class="hero-content">
            <h1 class="main-title">
                Xbrain <span class="and-symbol">&</span> AWS Accelerator<br>&amp; Internship Program
            </h1>
            <p class="sub-title">we are XBuilders</p>
        </div>
    </header>

    <footer class="footer">
        <div class="footer-brand">
            <div class="footer-logo">
                <svg viewBox="0 0 120 40" xmlns="http://www.w3.org/2000/svg" width="120" height="40">
                    <circle cx="20" cy="20" r="16" fill="#F2913D" />
                    <text x="20" y="25" font-family="Montserrat, sans-serif" font-size="12" font-weight="800"
                        fill="white" text-anchor="middle">X</text>
                    <text x="52" y="25" font-family="Montserrat, sans-serif" font-size="13" font-weight="700"
                        fill="#F2913D">BRAIN</text>
                </svg>
            </div>
            <p class="footer-text">Powered by Xbrain &amp; AWS</p>
        </div>
        <div class="clock-wrapper">
            <div class="clock">
                <div class="clock-date" id="clockDate"></div>
                <div class="clock-time" id="clockTime"></div>
            </div>
        </div>
    </footer>

    <script>
        function updateClock() {
            const now = new Date();

            document.getElementById('clockDate').textContent =
                now.toLocaleDateString('en-US', {
                    timeZone: 'Asia/Ho_Chi_Minh',
                    weekday: 'long',
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                }).toUpperCase();

            document.getElementById('clockTime').textContent =
                now.toLocaleTimeString('en-US', {
                    timeZone: 'Asia/Ho_Chi_Minh',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: false
                });
        }

        updateClock();
        setInterval(updateClock, 1000);
    </script>

</body>

</html>
HTMLEOF

chown ubuntu:ubuntu /home/ubuntu/index.html

# Create Dockerfile
cat > /home/ubuntu/Dockerfile << 'DOCKEREOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DOCKEREOF

chown ubuntu:ubuntu /home/ubuntu/Dockerfile

# Create K8s manifests
cat > /home/ubuntu/k8s-app.yaml << 'K8SEOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: xbrain-app
  labels:
    app: xbrain
spec:
  replicas: 2
  selector:
    matchLabels:
      app: xbrain
  template:
    metadata:
      labels:
        app: xbrain
    spec:
      containers:
      - name: nginx
        image: xbrain-app:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: xbrain-service
  labels:
    app: xbrain
spec:
  type: NodePort
  selector:
    app: xbrain
  ports:
  - port: 80
    targetPort: 80
    nodePort: ${K8S_APP_PORT}
    protocol: TCP
    name: http
K8SEOF

chown ubuntu:ubuntu /home/ubuntu/k8s-app.yaml

# Build Docker image and deploy
echo "Building Docker image..."
su - ubuntu -c 'cd ~ && docker build -t xbrain-app:latest .'

echo "Loading image into minikube..."
su - ubuntu -c 'minikube image load xbrain-app:latest'

echo "Deploying to Kubernetes..."
su - ubuntu -c 'kubectl apply -f ~/k8s-app.yaml'

echo "Waiting for deployment to be ready..."
su - ubuntu -c 'kubectl wait --for=condition=available --timeout=300s deployment/xbrain-app'

# ============================================
# CRITICAL FIX: Setup port forwarding from minikube to host
# ============================================
echo "Setting up port forwarding service..."

# Create systemd service for port forwarding
cat > /etc/systemd/system/k8s-port-forward.service << 'SERVICEEOF'
[Unit]
Description=Kubernetes Port Forward Service
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=ubuntu
Environment="HOME=/home/ubuntu"
ExecStart=/usr/local/bin/kubectl port-forward --address=0.0.0.0 service/xbrain-service ${K8S_APP_PORT}:80
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICEEOF

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable k8s-port-forward.service
systemctl start k8s-port-forward.service

# Wait for port to be listening
echo "Waiting for port ${K8S_APP_PORT} to be available..."
max_wait=60
elapsed=0
while ! netstat -tuln | grep -q ":${K8S_APP_PORT}"; do
    if [ $elapsed -ge $max_wait ]; then
        echo "WARNING: Port ${K8S_APP_PORT} did not become available within $max_wait seconds"
        break
    fi
    sleep 2
    elapsed=$((elapsed + 2))
done

echo "Port forwarding service status:"
systemctl status k8s-port-forward.service --no-pager

echo "========================================="
echo "Setup completed successfully!"
echo "Time: $(date)"
echo "========================================="
echo ""
echo "Cluster Status:"
su - ubuntu -c 'kubectl get nodes'
echo ""
echo "Pods:"
su - ubuntu -c 'kubectl get pods'
echo ""
echo "Services:"
su - ubuntu -c 'kubectl get svc'
echo ""
echo "Port Forwarding Status:"
systemctl status k8s-port-forward.service --no-pager | head -10
echo ""
echo "Listening Ports:"
netstat -tuln | grep :${K8S_APP_PORT} || echo "Port ${K8S_APP_PORT} not found"
echo "========================================="
