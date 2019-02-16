#role :app, %w{deploy_user@<public-ip-of-your-ec2-instance>}
server 'ec2-18-219-152-157.us-east-2.compute.amazonaws.com', user: 'deploy_user', roles: %w{web app db}

