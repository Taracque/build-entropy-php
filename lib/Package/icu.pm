package Package::icu;

use strict;
use warnings;

use base qw(Package);

our $VERSION = '4.8.1';

sub base_url {
	return "http://netcologne.dl.sourceforge.net/project/icu/ICU4C/$VERSION/";
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

sub build_configure {
	my $self = shift @_;

	my $cflags = $self->cflags();
	my $ldflags = $self->ldflags();
	my $cxxflags = $self->compiler_archflags();
	my $archflags = $self->compiler_archflags();
	my $cc = $self->cc();

	my $prefix = $self->config()->prefix();
	$self->shell("MACOSX_DEPLOYMENT_TARGET=" . $self->config()->target_os() . " CFLAGS=\"" . $cflags . "\" LDFLAGS='" . $ldflags ."' CXXFLAGS='" . $cxxflags . "' CC='" . $cc . " " . $archflags . "' CPP='cpp' ./runConfigureICU MacOSX  --disable-samples --enable-static " . $self->configure_flags());
}

sub make_command {
	my $self = shift @_;
	my $cflags = $self->cflags();
	return "MACOSX_DEPLOYMENT_TARGET=" . $self->config()->target_os() . " EXTRACFLAGS=\"" . $cflags . "\" ENABLE_RPATH=\"YES\" make";
}

sub php_extension_configure_flags {

	my $self = shift @_;
	my (%args) = @_;
	
	return "--with-icu-dir=" . $self->config()->prefix();
}

1;
