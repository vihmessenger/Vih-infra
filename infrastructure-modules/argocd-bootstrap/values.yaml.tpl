server:
  service:
    type: ${server_service_type}
%{ if enable_ingress ~}
  ingress:
    enabled: true
    controller: aws
    ingressClassName: alb
    hostname: ${ingress_hostname}
    path: /
    pathType: Prefix
    tls: false
    annotations:
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/target-type: ip
      alb.ingress.kubernetes.io/certificate-arn: ${ingress_certificate_arn}
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
      alb.ingress.kubernetes.io/ssl-redirect: "443"
      alb.ingress.kubernetes.io/healthcheck-path: /healthz
    aws:
      serviceType: ClusterIP
%{ endif ~}

configs:
%{ if enable_ingress ~}
  cm:
    url: https://${ingress_hostname}
%{ endif ~}
  params:
    server.insecure: "true"
