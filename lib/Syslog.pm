package Syslog;

    use Sys::Syslog;
    use strict;

    sub new {
    
        my $class = shift;

        my $prog = $_[0] || die "Missing program name!";
        my $facility = $_[1] || die "Missing facility!";

        my $self = {
            prog => $prog,
            facility => $facility,
            show_debug => 0
        };
    
        Sys::Syslog::openlog($self->{'prog'}, 'pid', $self->{'facility'});

        return bless $self, $class;

    }

    sub show_debug {
        $_[1] ? $_[0]->{'show_debug'} = $_[1] : return $_[0]->{'show_debug'};
    }

    sub log {

        my $self = shift;
        my $priority = shift;
        my $message = shift;

        Sys::Syslog::syslog($priority, "%s - %s", uc($priority), $message);

    }

    sub info { $_[0]->log('info', $_[1]); }
    sub notice { $_[0]->log('notice', $_[1]); }
    sub warning { $_[0]->log('warning', $_[1]); }
    sub err { $_[0]->log('err', $_[1]); }
    sub crit { $_[0]->log('crit', $_[1]); }
    sub alert { $_[0]->log('alert', $_[1]); }
    sub emerg { $_[0]->log('emerg', $_[1]); }
    sub debug { $_[0]->log('debug', $_[1]) if $_[0]->{'show_debug'} == 1; }

    sub abort {

         my $self = shift;
         my $error = shift;

         $self->err($error);
         die $error;

    }

    sub DESTROY {
        Sys::Syslog::closelog();
    }


if ($0 =~ __FILE__) {
    my $log = Syslog->new('test', 'local7');
    $log->info("test");
    $log->err("Error test");
}

1;
