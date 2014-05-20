package Net::GitHub::V3::Users;

use Moo;

our $VERSION = '0.54';
our $AUTHORITY = 'cpan:FAYLAND';

use URI::Escape;

with 'Net::GitHub::V3::Query';

sub show {
    my ( $self, $user ) = @_;

    my $u = $user ? "/users/" . uri_escape($user) : '/user';
    return $self->query($u);
}

sub update {
    my $self = shift;
    my $data = @_ % 2 ? shift @_ : { @_ };

    return $self->query('PATCH', '/user', $data);
}

sub add_email {
    (shift)->query( 'POST', '/user/emails', [ @_ ] );
}
sub remove_email {
    (shift)->query( 'DELETE', '/user/emails', [ @_ ] );
}
sub followers {
    my ($self, $user) = @_;

    my $u = $user ? "/users/" . uri_escape($user) . '/followers' : '/user/followers';
    return $self->query($u);
}
sub following {
    my ($self, $user) = @_;

    my $u = $user ? "/users/" . uri_escape($user) . '/following' : '/user/following';
    return $self->query($u);
}

sub contributions {
    my ( $self, $user ) = @_;
    my $path = "/users/" . uri_escape($user) . "/contributions_calendar_data";
    my $domain
        = $self->api_url eq 'https://api.github.com'
        ? 'https://github.com'
        : $self->api_url;
    return $self->query( $domain . $path );
}

## build methods on fly
my %__methods = (

    emails => { url => "/user/emails" },

    is_following => { url => "/user/following/%s", check_status => 204 },
    follow => { url => "/user/following/%s", method => 'PUT', check_status => 204 },
    unfollow => { url => "/user/following/%s", method => 'DELETE', check_status => 204 },

    keys => { url => "/user/keys" },
    key  => { url => "/user/keys/%s" },
    create_key => { url => "/user/keys", method => 'POST', args => 1 },
    update_key => { url => "/user/keys/%s", method => 'PATCH', args => 1 },
    delete_key => { url => "/user/keys/%s", method => 'DELETE', check_status => 204 },
);
__build_methods(__PACKAGE__, %__methods);

no Moo;

1;
__END__

=head1 NAME

Net::GitHub::V3::Users - GitHub Users API

=head1 SYNOPSIS

    use Net::GitHub::V3;

    my $gh = Net::GitHub::V3->new; # read L<Net::GitHub::V3> to set right authentication info
    my $user = $gh->user;

=head1 DESCRIPTION

=head2 METHODS

=head3 Users

L<http://developer.github.com/v3/users/>

=over 4

=item show

    my $uinfo = $user->show(); # /user
    my $uinfo = $user->show( 'nothingmuch' ); # /users/:user

=item update

    $user->update(
        bio  => 'another Perl programmer and Father',
    );

=back

=head3 Emails

L<http://developer.github.com/v3/users/emails/>

=over 4

=item emails

=item add_email

=item remove_email

    $user->add_email( 'another@email.com' );
    $user->add_email( 'batch1@email.com', 'batch2@email.com' );
    my $emails = $user->emails;
    $user->remove_email( 'another@email.com' );
    $user->remove_email( 'batch1@email.com', 'batch2@email.com' );

=back

=head3 Followers

L<http://developer.github.com/v3/users/followers/>

=over 4

=item followers

=item following

    my $followers = $user->followers;
    my $followers = $user->followers($user);
    my $following = $user->following;
    my $following = $user->following($user);

=item is_following

    my $is_following = $user->is_following($user);

=item follow

=item unfollow

    $user->follow( 'nothingmuch' );
    $user->unfollow( 'nothingmuch' );

=back

=head3 Keys

L<http://developer.github.com/v3/users/keys/>

=over 4

=item keys

=item key

=item create_key

=item update_key

=item delete_key

    my $keys = $user->keys;
    my $key  = $user->key($key_id); # get key
    $user->create_key({
        title => 'title',
        key   => $key
    });
    $user->update_key($key_id, {
        title => $title,
        key   => $key
    });
    $user->delete_key($key_id);

=item contributions

    my $contributions = $user->contributions($username);
    # $contributions = ( ..., ['2013/09/22', 3], [ '2013/09/23', 2 ] )

Unpublished GitHub API used to build the 'Public contributions' graph on a
users' profile page.  The data structure is a list of 365 arrayrefs, one per day.
Each array has two elements, the date in YYYY/MM/DD format is the first element,
the second is the number of contrubtions for that day.stree .

=back

=head1 AUTHOR & COPYRIGHT & LICENSE

Refer L<Net::GitHub>
