# Install Nginx if not already installed
class nginx {
  package { 'nginx':
    ensure => installed,
  }
}

# Create necessary directories
file { ['/data/web_static/releases', '/data/web_static/shared', '/data/web_static/releases/test']:
  ensure => 'directory',
  mode   => '0755',
}

# Create a fake HTML file for testing purposes
file { '/data/web_static/releases/test/index.html':
  content => '<html><head><title>Test Page</title></head><body>This is a test page.</body></html>',
  mode    => '0644',
}

# Create symbolic link to the current release
file { '/data/web_static/current':
  ensure => 'link',
  target => '/data/web_static/releases/test',
}

# Change ownership of the /data/ folder to ubuntu user and group
file { '/data':
  ensure  => 'directory',
  owner   => 'ubuntu',
  group   => 'ubuntu',
  recurse => true,
}

# Update Nginx configuration
class nginx::config {
  file { '/etc/nginx/sites-available/default':
    content => "server {\n\tlisten 80 default_server;\n\tlisten [::]:80 default_server;\n\t\n\troot /var/www/html;\n\tindex index.html index.htm index.nginx-debian.html;\n\n\tserver_name _;\n\t\n\tlocation /hbnb_static {\n\t\talias /data/web_static/current/;\n\t}\n}\n",
  }
}

# Restart Nginx
class nginx::service {
  service { 'nginx':
    ensure  => 'running',
    enable  => true,
    require => Class['nginx::config'],
  }
}

class { 'nginx': }
class { 'nginx::config': }
class { 'nginx::service': }


