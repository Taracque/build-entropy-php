package PackagePHPProvided;

use strict;
use warnings;
use base qw(PackageBase);


our $VERSION = '1.0';

sub is_unpacked {
	return 1;
}

sub is_downloaded {
	return 1;
}

sub is_installed {
	return 0;
}

sub build_configure {
	my $self = shift @_;

	my $cflags = $self->cflags();
	my $ldflags = $self->ldflags();
	my $cxxflags = $self->compiler_archflags();
	my $archflags = $self->compiler_archflags();
	my $cc = $self->cc();

	my $prefix = $self->config()->prefix();
	$self->shell("MACOSX_DEPLOYMENT_TARGET=" . $self->config()->target_os() . " CFLAGS=\"" . $cflags . "\" LDFLAGS='" . $ldflags . "' CXXFLAGS='" . $cxxflags . "' CC='" . $cc . "' ./configure " . $self->configure_flags());

}

sub build {
	my $self = shift @_;
	return unless ($self->SUPER::build(@_));
	my (%args) = @_;

	$self->cd_packagesrcdir();
	$self->build_arch_pre();
	$self->build_configure();

	my $make_command = $self->make_command();
	$self->shell($make_command);
}

sub install {

	my $self = shift @_;
	return undef unless ($self->SUPER::install(@_));
	
	$self->cd_packagesrcdir();
	$self->shell("make install");

}

sub packagesrcdir {
	my $self = shift @_;
	return $self->config()->srcdir() . "/php-" . $self->config()->version() . "/ext/" . $self->packagename();
}

1;
