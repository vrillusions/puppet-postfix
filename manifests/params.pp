# Parameters and their defaults
#
class postfix::params {
  # selinux labels differ from one distribution to another
  case $::operatingsystem {

    RedHat, CentOS: {
      case $::lsbmajdistrelease {
        '4':     { $postfix_seltype = 'etc_t' }
        '5','6': { $postfix_seltype = 'postfix_etc_t' }
        default: { $postfix_seltype = undef }
      }
    }

    default: {
      $postfix_seltype = undef
    }
  }

  # Default value for various options
  $postfix_smtp_listen = '127.0.0.1'
  $root_mail_recipient = 'nobody'
  $postfix_use_amavisd = 'no'
  $postfix_use_dovecot_lda = 'no'
  $postfix_use_schleuder = 'no'
  $postfix_use_sympa = 'no'
  $postfix_mail_user = 'vmail'

  case $::operatingsystem {
    /RedHat|CentOS|Fedora/: {
      $mailx_package = 'mailx'
    }

    /Debian|kFreeBSD/: {
      $mailx_package = $::lsbdistcodename ? {
        /lenny|etch|sarge/ => 'mailx',
        default            => 'bsd-mailx',
      }
    }

    'Ubuntu': {
      if (versioncmp('10', $::lsbmajdistrelease) > 0) {
        $mailx_package = 'mailx'
      } else {
        $mailx_package = 'bsd-mailx'
      }
    }
  }

  $master_os_template = $::operatingsystem ? {
    /RedHat|CentOS/          => template('postfix/master.cf.redhat.erb', 'postfix/master.cf.common.erb'),
    /Debian|Ubuntu|kFreeBSD/ => template('postfix/master.cf.debian.erb', 'postfix/master.cf.common.erb'),
  }

  $postfix_mydestination = '$myorigin'
  $postfix_mynetworks = "127.0.0.0/8" 
  
}