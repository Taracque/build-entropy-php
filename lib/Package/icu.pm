package Package::icu;

use strict;
use warnings;

use base qw(Package);

our $VERSION = '4.6.1';

sub base_url {
	return "http://download.icu-project.org/files/icu4c/" . $VERSION . "/";
}


sub packagename {
	return "icu/source";
}

sub filename {
	my $self = shift @_;
	my $vers = $VERSION;
	$vers =~ s/\./_/g;
	return "icu4c-" . $vers . "-src.tgz";
}

sub subpath_for_check {
	return "lib/libicui18n.dylib";
}

sub make_command {
	my $self = shift @_;
	my $cflags = $self->cflags();
	return qq(MACOSX_DEPLOYMENT_TARGET=10.6 EXTRACFLAGS="$cflags" make);
}

sub php_extension_configure_flags {

	my $self = shift @_;
	my (%args) = @_;
	
	return "--with-icu-dir=" . $self->config()->prefix();
}

sub patchfiles {
	my $self = shift @_;
	return qw(icu-config.patch);
}

1;
