#== Definition: postfix::hash
#
#Creates postfix hashed "map" files. It will create "${name}", and then build
#"${name}.db" using the "postmap" command. The map file can then be referred to
#using postfix::config.
#
#Parameters:
#- *name*: the name of the map file.
#- *ensure*: present/absent, defaults to present.
#- *source*: file source.
#
#Requires:
#- Class["postfix"]
#
#Example usage:
#
#  node "toto.example.com" {
#
#    include postfix
#
#    postfix::hash { "/etc/postfix/virtual":
#      ensure => present,
#    }
#    postfix::config { "virtual_alias_maps":
#      value => "hash:/etc/postfix/virtual"
#    }
#  }
#
define postfix::hash ($ensure='present', $source=false, $content=false) {

  File {
    mode    => '0600',
    owner   => root,
    group   => root,
    seltype => $postfix::params::postfix_seltype,
  }

  if $source != false {
    file {$name:
      ensure  => $ensure,
      source  => $source,
      require => Package['postfix'],
    }
  } else {
    if $content != false {
      file {$name:
        ensure  => $ensure,
        content => $content,
        require => Package['postfix'],
      }
    } else {
      file {$name:
        ensure  => $ensure,
        require => Package['postfix'],
      }
    }
  }

  file {"${name}.db":
    ensure  => $ensure,
    require => [File[$name], Exec["generate ${name}.db"]],
  }

  exec {"generate ${name}.db":
    command     => "postmap ${name}",
    #creates    => "${name}.db", # this prevents postmap from being run !
    subscribe   => File[$name],
    refreshonly => true,
    require     => Package['postfix'],
  }
}
