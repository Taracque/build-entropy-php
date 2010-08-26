package Package::aspell;

use strict;
use warnings;

use base qw(Package);

our $VERSION = '0.60.6';

sub base_url {
	return "ftp://ftp.gnu.org/gnu/aspell";
}

sub packagename {
	return "aspell-" . $VERSION;
}

sub subpath_for_check {
	return "lib/libaspell.dylib";
}

sub make_command {
	my $self = shift @_;
	my $cflags = $self->cflags();
	return qq(MACOSX_DEPLOYMENT_TARGET=10.6 EXTRACFLAGS="$cflags" make);
}

sub php_extension_configure_flags {

	my $self = shift @_;
	my (%args) = @_;
	
	return "--with-pspell=" . $self->config()->prefix();
}

1;
