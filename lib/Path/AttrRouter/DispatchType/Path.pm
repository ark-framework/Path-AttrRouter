package Path::AttrRouter::DispatchType::Path;
use Any::Moose;

has name => (
    is      => 'rw',
    isa     => 'Str',
    default => 'Path',
);

has paths => (
    is      => 'rw',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub { {} },
);

no Any::Moose;

sub match {
    my ($self, $path, $args, $captures) = @_;

    $path = '/' if !defined $path || !length $path;

    for my $action (@{ $self->paths->{$path} || [] }) {
        return $action if $action->match_args($args);
    }

    return;
}

sub register {
    my ($self, $action) = @_;

    my @register_paths = @{ $action->attributes->{Path} || [] }
        or return;

    for my $path (@register_paths) {
        $self->register_path( $path => $action );
    }

    1;
}

sub register_path {
    my ($self, $path, $action) = @_;

    $path =~ s!^/!!;
    $path = '/' unless length $path;

    my $actions  = $self->paths->{ $path } ||= [];
    my $num_args = $action->num_args;

    unless (@$actions) {
        push @$actions, $action;
        return;
    }

    if (defined $num_args) {
        my $p;
        for ($p = 0; $p < @$actions; ++$p) {
            last unless defined $actions->[$p]->num_args;
            last if $actions->[$p]->num_args <= $num_args;
        }

        unless (defined $p) {
            unshift @$actions, $action;
        }
        else {
            @$actions = (@$actions[0..$p-1], $action, @$actions[$p..$#$actions]);
        }
    }
    else {
        push @$actions, $action;
    }
}

sub used {
    my $self = shift;
    scalar( keys %{ $self->paths } );
}

__PACKAGE__->meta->make_immutable;
