# ex: syntax=puppet si ts=4 sw=4 et

class xl2tpd (
    $package_name,
    $version,
    $service_name,
    $ppp_package_name,
    $ppp_version,
    $min_dynamic_ip = '192.168.254.10',
    $max_dynamic_ip = '192.168.254.250',
    $tunnel_ip      = '192.168.254.1',
    $tunnel_network = '192.168.254.0/24',
    $dns_servers    = [ '8.8.4.4', '8.8.8.8' ],
    $listen_addr = undef,
    $debug = false,
) {
    File {
        ensure => present,
        owner => 'root',
        group => 'root',
        mode  => '0644',
    }
    
    package { 'ppp':
        name => $ppp_package_name,
        ensure => $ppp_version,
    }

    package { 'xl2tpd':
        name   => $package_name,
        ensure => $version,
    }

    file { '/etc/xl2tpd/xl2tpd.conf':
        content => template('xl2tpd/xl2tpd.conf.erb'),
        require => Package['xl2tpd'],
    }

    file { '/etc/ppp/options.xl2tpd':
        content => template('xl2tpd/options.xl2tpd.erb'),
        require => [Package['xl2tpd'], Package['ppp']],
    }

    file { '/etc/ppp/pap-secrets':
        ensure  => 'present',
        path    => '/etc/ppp/pap-secrets',
        source  => 'puppet:///modules/xl2tpd/pap-secrets',
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        require => Package['ppp'],
    }

    service { 'xl2tpd':
        name       => $service_name,
        ensure     => running,
        pattern    => '/usr/sbin/xl2tpd',
        hasstatus  => false,
        hasrestart => true,
        subscribe  => File['/etc/xl2tpd/xl2tpd.conf', '/etc/ppp/options.xl2tpd'],
    }
}
