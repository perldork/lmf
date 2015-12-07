package LogAction;

    use strict;

    sub new {

        my $class = shift;

        # undef initialized values are required

        my $self = {
                file => undef,
                pattern => undef,
                threshold => 0,
                duration => 0,
                within => '10s',
                trigger => undef,
                release => '',
                message => '',
                name => undef,
        };

        return bless $self, $class;

    }

    sub file { 

        if (defined $_[1]) {
            die "Can't read from file $_[1]: $!" unless -r $_[1];
            $_[0]->{'file'} = $_[1];
        }

        return $_[0]->{'file'};

    }

    sub pattern { 

        defined($_[1]) ? $_[0]->{'pattern'} = $_[1] : return $_[0]->{'pattern'};

    }

    sub threshold { 

        if (defined $_[1]) {

            die "Threshold must be numeric!" unless $_[1] =~ /^\d+$/;
            $_[0]->{'threshold'} = $_[1];

        }

        return $_[0]->{'threshold'};

    }

    sub duration { 

        if (defined $_[1]) {

            if (! defined(convert_time_spec($_[1]))) {
                die "Invalid time spec for duration: $_[1]";
            }

            $_[0]->{'duration'} = $_[1];

        }

        return convert_time_spec($_[0]->{'duration'});

    }

    sub within { 

        if (defined $_[1]) {

            if (! defined(convert_time_spec($_[1]))) {
                die "Invalid time spec for within: $_[1]";
            }

            $_[0]->{'within'} = $_[1];

        }

        return convert_time_spec($_[0]->{'within'});

    }

    sub trigger { 

        if (defined $_[1]) {

            my $cmd = $_[1];
            $cmd =~ s/ .*//;
            die "Trigger $cmd not readable" unless -r $cmd;
            die "Trigger $cmd not executable" unless -x $cmd;
            $_[0]->{'trigger'} = $_[1];

        }

        return $_[0]->{'trigger'};

    }

    sub release { 

        if (defined $_[1]) {

            my $cmd = $_[1];
            $cmd =~ s/ .*//;

            die "Release $cmd not readable" unless -r $cmd;
            die "Release $cmd not executable" unless -x $cmd;

            $_[0]->{'release'} = $_[1];

        }

        return $_[0]->{'release'};

    }

    sub message { 
        defined($_[1]) ? $_[0]->{'message'} = $_[1] : return $_[0]->{'message'};
    }

    sub name { 
        defined($_[1]) ? $_[0]->{'name'} = $_[1] : return $_[0]->{'name'};
    }

    sub convert_time_spec {

        my $spec = shift;

        my ($time, $unit) = ($spec =~ m/(\d+)([DdHhMmSs])/);

        if ($time == 0) {
            return 0;
        }

        if (! $time) {
            return undef;
        }

        if (! $unit) {
            return $time;
        }

        $unit = lc($unit);

        return $time if $unit eq 's';
        return ($time * 60) if $unit eq 'm';
        return ($time * 3600) if $unit eq 'h';
        return ($time * 86400) if $unit eq 'd';

        return undef;

    }

    sub validate {
        my $self = shift;

        die "Missing duration" unless defined($self->{'duration'});
        die "Missing file" unless defined($self->{'file'});
        die "Missing pattern" unless defined($self->{'pattern'});
        die "Missing name" unless defined($self->{'name'});
        die "Missing trigger" unless defined($self->{'trigger'});

    }

1;
