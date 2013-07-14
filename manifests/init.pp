class xl2tpd (
	$min_dynamic_ip = '192.168.254.10',
	$max_dynamic_ip = '192.168.254.250',
	$tunnel_ip      = '192.168.254.1',
	$dns_servers	= [ '8.8.4.4', '8.8.8.8' ],
) {

	package { 'xl2tpd':
		ensure => installed,
	}

	concat { '/etc/ppp/chap-secrets':
		owner => 'root',
		group => 'root',
		mode  => 0640,
	}

	concat::fragment { 'chap-secrets preamble':
		target  => '/etc/ppp/chap-secrets',
		order   => '00',
		content => "; secrets go here\n",
	}

	define user (
		$password,
	) {
		concat::fragment { "chap-secrets user $name":
			target  => '/etc/ppp/chap-secrets',
			order   => 10,
			content => template('xl2tpd/chap-secret.erb'),
		}
	}

	file { '/etc/xl2tpd/xl2tpd.conf':
		owner   => 'root',
		group   => 'root',
		mode    => 0644,
		content => template('xl2tpd/xl2tpd.conf.erb'),
	}

	file { '/etc/ppp/options.xl2tpd':
		owner   => 'root',
		group   => 'root',
		mode    => 0644,
		content => template('xl2tpd/options.xl2tpd.erb'),
	}

	service { 'xl2tpd':
		ensure    => running,
		subscribe => File['/etc/xl2tpd/xl2tpd.conf'],
	}

}
