server {
    listen xLISTEN_PORTx;
    server_name _default;
    xWHITELISTx
    location /kubeprobe {
      return 200;
    }
    location / {
      proxy_pass xPROXY_PASSx;
    }
}
