cat << EOF | sudo tee /etc/cloud/cloud.cfg.d/99-datasources.cfg
datasource_list: [ NoCloud, None ]
EOF
