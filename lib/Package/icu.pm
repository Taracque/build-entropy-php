package Package::icu;

use strict;
use warnings;

use base qw(PackageSplice);

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

sub make_flags {
	return '';
}

sub build_arch {
	my $self = shift @_;
	my (%args) = @_;

	$self->{current_arch} = $args{arch};
	my $cflags = $self->cflags();
	my $ldflags = $self->ldflags();

	$self->cd_packagesrcdir();
#	$self->shell("MACOSX_DEPLOYMENT_TARGET=" . $self->config()->target_os() . " CFLAGS=\"" . $cflags . "\" LDFLAGS='" . $ldflags ."' CXXFLAGS='" . $cxxflags . "' CC='" . $cc . " " . $archflags . "' CPP='cpp' ./runConfigureICU MacOSX --with-library-bits=32 --disable-samples --enable-static " . $self->configure_flags());
	if ($args{arch} eq 'x86_64') {
		$self->shell("MACOSX_DEPLOYMENT_TARGET=" . $self->config()->target_os() . " CFLAGS='$cflags' LDFLAGS='$ldflags' CC='cc -arch $args{arch} -DENTROPY_CH_RELEASE=" . $self->config()->release() . "' CXX='c++ -arch $args{arch}' CPP='cpp' ./runConfigureICU MacOSX --with-library-bits=64 --disable-samples --enable-static " . $self->configure_flags(arch => $args{arch}));
	} else {
		$self->shell("MACOSX_DEPLOYMENT_TARGET=" . $self->config()->target_os() . " CFLAGS='$cflags' LDFLAGS='$ldflags' CC='cc -arch $args{arch} -DENTROPY_CH_RELEASE=" . $self->config()->release() . "' CXX='c++ -arch $args{arch}' CPP='cpp' ./runConfigureICU MacOSX --with-library-bits=32 --disable-samples --enable-static " . $self->configure_flags(arch => $args{arch}));
	}
	$self->build_arch_make(%args);
}

sub build_arch_make {
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
