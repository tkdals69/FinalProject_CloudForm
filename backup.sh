#!/bin/bash
set -e

BACKUP_FILE="/tmp/jenkins-backup.tar.gz"
S3_BUCKET="s3://jenkins-backup-bucket2"

# Jenkins quiet-down (빌드 멈춤)
java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 quiet-down || true

sudo chmod -R a+rX /var/lib/jenkins

# 백업 생성 (해당 파일 온프레미스도 저장 할 예정)
tar -czvf $BACKUP_FILE /var/lib/jenkins /usr/share/maven /usr/lib/jvm/java-17-amazon-corretto.x86_64

scp -i ~/.ssh/id_rsa \
  -o ProxyJump=ec2-user@10.0.37.234 \
  /opt/backup/jenkins-backup.tar.gz \
  ec2-user@52.78.109.213:/opt/backup/

sudo chmod -R o-rX /var/lib/jenkins

# 빌드 재개
java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 cancel-quiet-down || true

# 정리
rm -f $BACKUP_FILE
echo "[INFO] 백업 완료 및 임시 파일 삭제"

