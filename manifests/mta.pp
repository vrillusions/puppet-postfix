#
# == Class: postfix::mta
#
# This class configures a minimal MTA, listening on
# $postfix_smtp_listen (default to localhost) and delivering mail to
# $postfix_mydestination (default to $fqdn).
#
# A valid relay host is required ($postfix_relayhost) for outbound email.
#
# transport & virtual maps get configured and can be populated with
# postfix::transport and postfix::virtual
#
# Parameters:
# - *$postfix_relayhost*
# - *$postfix_mydestination*
# - every global variable which works for class 'postfix' will work here.
#
# Example usage:
#
#   node 'toto.example.com' {
#     class {'postfix::mta':
#       postfix_relayhost     => 'mail.example.com',
#       postfix_smtp_listen   => '0.0.0.0',
#       postfix_mydestination => '$myorigin, myapp.example.com',
#     }
#
#     postfix::transport { 'myapp.example.com':
#       ensure => present,
#       destination => 'local:',
#     }
#   }
#
class postfix::mta (
    $postfix_relayhost,
    $postfix_mydestination = $postfix::params::postfix_mydestination,
    $postfix_mynetworks    = $postfix::params::postfix_mynetworks,
    $root_mail_recipient   = $postfix::params::root_mail_recipient,
  ) inherits postfix::params {

  class {'postfix':
    root_mail_recipient   => $root_mail_recipient,
  }

  postfix::config {
    'mydestination':       value => $postfix_mydestination;
    'mynetworks':          value => $postfix_mynetworks;
    'relayhost':           value => $postfix_relayhost;
    'virtual_alias_maps':  value => 'hash:/etc/postfix/virtual';
    'transport_maps':      value => 'hash:/etc/postfix/transport';
  }

  postfix::hash { '/etc/postfix/virtual':
    ensure => present,
  }

  postfix::hash { '/etc/postfix/transport':
    ensure => present,
  }

}
