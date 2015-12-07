package Configuration;

    $Configuration::VERSION = '0.4';

    use strict;
    use Config::IniFiles;
    use IO::File;
    use LWP::UserAgent;

    sub new {

        my $class = shift;
        my $dirspec = shift || die "Missing configuration directory!";

        my $self = { dirspec => $dirspec };
        $self->{'cf'} = load_configuration($dirspec);
        return bless $self, $class;
    }

    sub cf {

        if ($_[1]) {
            $_[0]->{'cf]'} = $_[1];
        }

        return $_[0]->{'cf'};

    }

    sub reload {
        
        my $self = shift;
        $self->{'cf'} = load_configuration($self->{'dirspec'});

    }

    sub load_configuration {

        my $dirspec = shift;

        my $fh;

        if (-d $dirspec) {
            $fh = create_file_from_config_snippets($dirspec);
        } elsif ($dirspec =~ m#https?://#i) {
            $fh = create_file_from_lwp($dirspec);
        }

        return Config::IniFiles->new('-file'    => $fh, 
                                     '-default' => 'main');

    }

    sub create_file_from_lwp {

        my $uri = shift;

        my ($url, $user, $pass) = split(',', $uri);

        {
            package MyAgent;

                use strict;
                use base qw(LWP::UserAgent);

                sub get_basic_credentials {
                    return ($user, $pass);
                }

            1;
        }

        my $response = MyAgent->new()->get($url);

        if (! $response->is_success()) {
            die $response->status_line();
        }

        my $base = ($url =~ m!(.*)/!)[0];
        my $index = $response->decoded_content();

        my $output = IO::File::new_tmpfile();

        while ($index =~ m/(\S+)/g) {

            my $inifile = "$base/$1";

            $response = MyAgent->new()->get($inifile);

            if (! $response->is_success()) {
                die $response->status_line();
            }

            $output->print($response->decoded_content());

        }

        $output->seek(0, 0);

        return $output;

    }

    sub create_file_from_config_snippets {

        my $dir = shift;

        local(*DIR);

        opendir(DIR, $dir) 
            || die "Can't read from configuration directory $dir: $!\n";

        my $output = IO::File::new_tmpfile();

        local(*CONF);

        while (my $file = readdir(DIR)) {

            next unless $file =~ /\.conf$/;

            local($/) = undef;

            my $in = "$dir/$file";
            open(CONF, "< $in")
                || die "Can't read configuration fragment $in: $!\n";
            my $content = <CONF>;
            close(CONF);

            $output->print("$content\n\n");
            
        }

        close(DIR);

        #  Rewind to beginning of file;
        $output->seek(0, 0);

        return $output;
    }

1;

if ( __FILE__ eq $0 ) {

    my $c = Configuration->new('http://wwd-hosting.net/test/index.html,max,test123');
    for my $section (grep(!/^(?:main|action-queue)/, $c->cf()->Sections())) {
        print "$section\n";
    }

}

1;
