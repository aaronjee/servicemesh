#!/bin/bash
# bookinfo-mirror-images.sh
# Bookinfo 샘플 이미지 다운로드 → Retag → 내부 레지스트리 Push
REGISTRY="bastion.mylab.paas.local:5000"
PROJECT="bookinfo"
IMAGES=(
  "docker.io/istio/examples-bookinfo-productpage-v1:1.20.2"
  "docker.io/istio/examples-bookinfo-details-v1:1.20.2"
  "docker.io/istio/examples-bookinfo-ratings-v1:1.20.2"
  "docker.io/istio/examples-bookinfo-ratings-v2:1.20.2"
  "docker.io/istio/examples-bookinfo-reviews-v1:1.20.2"
  "docker.io/istio/examples-bookinfo-reviews-v2:1.20.2"
  "docker.io/istio/examples-bookinfo-reviews-v3:1.20.2"
  "docker.io/istio/examples-bookinfo-mongodb:1.20.2"
  "docker.io/istio/examples-bookinfo-mysqldb:1.20.2"
)
echo "=== Bookinfo 이미지 미러링 시작 (총 ${#IMAGES[@]}개) ==="
echo "    대상: ${REGISTRY}/${PROJECT}/"
echo ""
FAIL=0
for img in "${IMAGES[@]}"; do
  # 이미지 이름 추출: examples-bookinfo-details-v1:1.20.2
  NAME="${img##*/}"
  TARGET="${REGISTRY}/${PROJECT}/${NAME}"
  echo "--- ${NAME} ---"
  # 1. Pull
  echo -n "  [PULL]  "
  if ! podman pull "$img" -q > /dev/null 2>&1; then
    echo "FAIL"; FAIL=$((FAIL + 1)); continue
  fi
  echo "OK"
  # 2. Retag
  echo -n "  [TAG]   "
  if ! podman tag "$img" "$TARGET" 2>/dev/null; then
    echo "FAIL"; FAIL=$((FAIL + 1)); continue
  fi
  echo "${TARGET}"
  # 3. Push
  echo -n "  [PUSH]  "
  if ! podman push "$TARGET" --tls-verify=false -q 2>/dev/null; then
    echo "FAIL"; FAIL=$((FAIL + 1)); continue
  fi
  echo "OK"
  echo ""
done
echo "=== 완료: 성공 $((${#IMAGES[@]} - FAIL))개 / 실패 ${FAIL}개 ==="
echo ""
echo "=== 미러링된 이미지 목록 ==="
for img in "${IMAGES[@]}"; do
  echo "  ${REGISTRY}/${PROJECT}/${img##*/}"
done
