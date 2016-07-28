package Plack::Session;
use strict;
use warnings;

our $VERSION   = '0.30';
our $AUTHORITY = 'cpan:STEVAN';

use Plack::Util::Accessor qw( session options );

sub new {
    my ($class, $env) = @_;
    bless {
        session => $env->{'psgix.session'},
        options => $env->{'psgix.session.options'},
    }, $class;
}

sub id {
    my $self = shift;
    $self->options->{id};
}

## Data Managment

sub dump {
    my $self = shift;
    $self->session;
}

sub get {
    my ($self, $key) = @_;
    $self->session->{$key};
}

sub set {
    my ($self, $key, $value) = @_;
    delete $self->options->{no_store};
    $self->session->{$key} = $value;
}

sub remove {
    my ($self, $key) = @_;
    delete $self->options->{no_store};
    delete $self->session->{$key};
}

sub keys {
    my $self = shift;
    keys %{$self->session};
}

## Lifecycle Management

sub change_id {
    my $self = shift;
    $self->options->{change_id} = 1;
}

sub no_store {
    my $self = shift;
    $self->options->{no_store} = 1;
}

sub late_store {
    my $self = shift;
    $self->options->{late_store} = 1;
}

sub expire {
    my $self = shift;
    for my $key ($self->keys) {
        delete $self->session->{$key};
    }
    $self->options->{expire} = 1;
}

1;

__END__

=pod

=head1 NAME

Plack::Session - Middleware for session management

=head1 SYNOPSIS

  # Use with Middleware::Session
  enable "Session";

  # later in your app
  use Plack::Session;
  my $app = sub {
      my $env = shift;
      my $session = Plack::Session->new($env);

      $session->id;
      $session->get($key);
      $session->set($key, $value);
      $session->remove($key);
      $session->keys;

      $session->expire;
  };

=head1 DESCRIPTION

This is the core session object, you probably want to look
at L<Plack::Middleware::Session>, unless you are writing your
own session middleware component.

=head1 METHODS

=over 4

=item B<new ( $env )>

The constructor takes a PSGI request env hash reference.

=item B<id>

This is the accessor for the session id.

=back

=head2 Session Data Management

These methods allows you to read and write the session data like
Perl's normal hash.

=over 4

=item B<get ( $key )>

=item B<set ( $key, $value )>

=item B<remove ( $key )>

=item B<keys>

=item B<session>, B<dump>

=back

=head2 Session Lifecycle Management

=over 4

=item B<change_id>

This method can be called to re-generate the current session id.
This feature is useful for preventing session fixation attack.

SEE ALSO: L<Plack::Middleware::Session/"change_id">

=item B<no_store>

This method can be called to no store the current session.

SEE ALSO: L<Plack::Middleware::Session/"no_store">

=item B<late_store>

This method can be called to late store the current session.

SEE ALSO: L<Plack::Middleware::Session/"late_store">

=item B<expire>

This method can be called to expire the current session id.

SEE ALSO: L<Plack::Middleware::Session/"expire">

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2009, 2010 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

