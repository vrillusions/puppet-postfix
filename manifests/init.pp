#
# == Class: postfix
#
# This class provides a basic setup of postfix with local and remote
# delivery and an SMTP server listening on the loopback interface.
#
# Parameters:
# - *$postfix_smtp_listen*: address on which the smtp service will listen to.
#      defaults to 127.0.0.1
# - *$root_mail_recipient*: who will recieve root's emails. defaults to 'nobody'
#
# Example usage:
#
#   node 'toto.example.com' {
#     class {'postfix':
#       postfix_smtp_listen => '192.168.1.10',
#     }
#   }
#
class postfix(
    $postfix_seltype         = $postfix::params::postfix_seltype,
    $postfix_smtp_listen     = $postfix::params::postfix_smtp_listen,
    $root_mail_recipient     = $postfix::params::root_mail_recipient,
    $postfix_use_amavisd     = $postfix::params::postfix_use_amavisd,
    $postfix_use_dovecot_lda = $postfix::params::postfix_use_dovecot_lda,
    $postfix_use_schleuder   = $postfix::params::postfix_use_schleuder,
    $postfix_use_sympa       = $postfix::params::postfix_use_sympa,
    $postfix_mail_user       = $postfix::params::postfix_mail_user,
    $mailx_package           = $postfix::params::mailx_package,
    $master_os_template      = $postfix::params::master_os_template
  ) inherits postfix::params {

  package { 'postfix':
    ensure => installed,
  }

  package { 'mailx':
    ensure => installed,
    name   => $mailx_package,
  }

  service { 'postfix':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    restart   => '/etc/init.d/postfix reload',
    require   => Package['postfix'],
  }

  file { '/etc/mailname':
    ensure  => present,
    content => "$::fqdn\n",
    seltype => $postfix_seltype,
  }

  # Aliases
  file { '/etc/aliases':
    ensure  => present,
    content => '# file managed by puppet\n',
    replace => false,
    seltype => $postfix_seltype,
    notify  => Exec['newaliases'],
  }

  # Aliases
  exec { 'newaliases':
    command     => '/usr/bin/newaliases',
    refreshonly => true,
    require     => Package['postfix'],
    subscribe   => File['/etc/aliases'],
  }

  # Config files
  file { '/etc/postfix/master.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $master_os_template,
    seltype => $postfix_seltype,
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  # Config files
  file { '/etc/postfix/main.cf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/postfix/main.cf',
    replace => false,
    seltype => $postfix_seltype,
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  # Default configuration parameters
  $myorigin = $valid_fqdn ? {
    ''      => $::fqdn,
    default => $valid_fqdn,
  }
  postfix::config {
    'myorigin':         value => $myorigin;
    'alias_maps':       value => 'hash:/etc/aliases';
    'inet_interfaces':  value => 'all';
  }

  case $::operatingsystem {
    RedHat, CentOS: {
      postfix::config {
        'sendmail_path':    value => '/usr/sbin/sendmail.postfix';
        'newaliases_path':  value => '/usr/bin/newaliases.postfix';
        'mailq_path':       value => '/usr/bin/mailq.postfix';
      }
    }
    default: {}
  }

  mailalias {'root':
    recipient => $root_mail_recipient,
    notify    => Exec['newaliases'],
  }
}
