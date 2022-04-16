server {
    listen xSTATUS_PORTx;
    server_name _default;
    location /kubeprobe {
      return 200;
    }
}
