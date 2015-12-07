package LogMatch;

    use strict;

    sub new {

        my $class = shift;

        my $action = shift || die "Missing required action field!";
        my $start = shift || die "Missing required start parameter!";
        my $vars = shift || die "Missing required vars array ref parameter!";

        # undef initialized values are required

        my $self = { action => $action, 
                     start => $start, 
                     vars => $vars,
                     count => 0,
                     in_progress => 0
        };

        return bless $self, $class;

    }

    sub is_equal {
  
        my $self = shift;
        my $other = shift;

        my $our_vars = join('', @{$self->vars()});
        my $their_vars = join('', @{$other->vars()});

        return 0 unless $our_vars eq $their_vars;

        my $our_pattern = $self->action()->pattern();
        my $their_pattern = $other->action()->pattern();

        return 0 unless $our_pattern eq $their_pattern;

        my $our_name = $self->action()->name();
        my $their_name = $other->action()->name();

        return 0 unless $our_name eq $their_name;

        return 1;

    }

    #  Return time interval elapsed for the match threshold to be
    #  breached if all match conditions are met or 0 if conditions
    #  are not met yet.  Return 1 if within is set to no ducation
    #  for the action we are associated with.

    sub is_ready {

        my $self = shift;

        my $action = $self->action();

        my $at_threshold = 0;
        my $total_time = 0;

        if ($self->count() >= $action->threshold()) {

            $at_threshold = 1;

        }

        if ($action->within() <= 0) {

            $total_time = 1 if $at_threshold;

        } else {

            my $interval = time() - $self->start();

            if ($interval <= $action->within()) {

                $total_time = $interval if $at_threshold;

            }
        }

        return $total_time;

    }

    sub is_expired {

        my $self = shift;

        my $within = $self->action()->within();

        if ($within > 0) {

            #  Not expired if within requested time interval
            if ((time() - $self->start()) <= $self->action->within()) {
                return 0;
            }

        } else {

            #  Not expired if no within limit exists and the event has
            #  not been triggered yet.
            if ($self->count() < $self->action()->threshold()) {
                return 0;
            }

        }

        return 1;

    }

    sub increment {

        my $self = shift;
        $self->{'count'}++;

    }

    sub start { 

        defined($_[1]) ? $_[0]->{'start'} = $_[1] : return $_[0]->{'start'};

    }

    sub action { 

        defined($_[1]) ? $_[0]->{'action'} = $_[1] : return $_[0]->{'action'};

    }

    sub vars { 

        defined($_[1]) ? $_[0]->{'vars'} = $_[1] : return $_[0]->{'vars'};

    }

    sub count { 

        defined($_[1]) ? $_[0]->{'count'} = $_[1] : return $_[0]->{'count'};

    }

    sub in_progress { 

        defined($_[1]) ? $_[0]->{'in_progress'} = $_[1] : 
                         return $_[0]->{'in_progress'};

    }

1;
