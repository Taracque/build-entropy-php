package Package::libpng;

use strict;
use warnings;

use base qw(Package);

our $VERSION = '1.4.3';


sub base_url {
#	return "http://switch.dl.sourceforge.net/sourceforge/libpng";
	return "ftp://ftp.simplesystems.org/pub/png/src";
}

sub packagename {
	return "libpng-$VERSION";
}


sub subpath_for_check {
	return "lib/libpng.dylib";
}


sub configure_flags {
	my $self = shift @_;
	return $self->SUPER::configure_flags(@_) . " --without-x";
}


sub php_extension_configure_flags {
	my $self = shift @_;
	my (%args) = @_;
	return "--with-png-dir=" . $self->config()->prefix();
}



1;