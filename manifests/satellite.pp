#
# == Class: postfix::satellite
#
# This class configures all local email (cron, mdadm, etc) to be forwarded
# to $root_mail_recipient, using $postfix_relayhost as a relay.
#
# $valid_fqdn can be set to override $fqdn in the case where the FQDN is
# not recognized as valid by the destination server.
#
# Parameters:
# - *valid_fqdn*
# - every global variable which works for class 'postfix' will work here.
#
# Requires:
# - postfix_relayhost
#
# Example usage:
#
#   node 'toto.local.lan' {
#     class {'postfix::satellite':
#       postfix_relayhost   => 'mail.example.com',
#       valid_fqdn          => 'toto.example.com',
#       root_mail_recipient => 'the.sysadmin@example.com',
#     }
#   }
#
class postfix::satellite (
    $postfix_relayhost,
    $valid_fqdn            = '',
    $root_mail_recipient   = $postfix::params::root_mail_recipient,
    $postfix_mydestination = $postfix::params::postfix_mydestination,
    $postfix_mynetworks    = $postfix::params::postfix_mynetworks,
  ) inherits postfix::params {

  # If $valid_fqdn exists, use it to override $fqdn
  if ($valid_fqdn == '') {
    $real_valid_fqdn = $::fqdn
  } else {
    $real_valid_fqdn = $valid_fqdn
    $fqdn = $valid_fqdn
  }  
  
  class {'postfix::mta':
    postfix_relayhost     => $postfix_relayhost,
    postfix_mydestination => $postfix_mydestination, 
    postfix_mynetworks    => $postfix_mynetworks,
    root_mail_recipient   => $root_mail_recipient,
  }

  postfix::virtual { "@${valid_fqdn}":
    ensure      => present,
    destination => 'root',
  }
}
