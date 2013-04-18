package Package::xdebug;

use strict;
use warnings;

use base qw(PackageSplice);

our $VERSION = '2.2.2';

sub base_url {
	return "http://www.xdebug.org/files";
}

sub packagename {
	return "xdebug-" . $VERSION;
}

sub filename {
	my ($self) = shift;
	return $self->packagename() . ".tgz";
}

sub subpath_for_check {
	return "modules/xdebug.so";
}

sub make_flags {
	return '';
}

sub is_installed {
	my $self = shift @_;
	return undef;
}

sub php_zend_extension_names {
	my $self = shift @_;
	return qw(xdebug);
}

sub package_filelist {
	my $self = shift @_;
	return $self->php_zend_extension_paths(), qw(
		php.d/50-extension-xdebug.ini
	);
}

sub build_arch_pre {
	my $self = shift @_;
#	$self->cd_srcdir();
	$self->shell($self->install_prefix() . "/bin/phpize");

}


sub configure_flags {
	my $self = shift @_;
	return join " ", (
		$self->SUPER::configure_flags(@_),
		'--enable-xdebug --with-php-config=' . $self->install_prefix() . '/bin/php-config'
	);
}


1;
