package Package::intl;

use strict;
use warnings;

use base qw(PackagePHPProvided);

our $VERSION = '0.0';

sub packagename {
	return "intl";
}

sub subpath_for_check {
	return "lib/php/extensions/no-debug-non-zts-20090626/intl.so";
}

sub make_flags {
	return '';
}

sub php_dso_extension_names {
	my $self = shift @_;
	return qw(intl);
}

sub package_filelist {
	my $self = shift @_;
	return $self->php_dso_extension_paths(), qw(
		php.d/50-extension-intl.ini
		lib/libintl*.dylib
	);
}

sub build_arch_pre {
	my $self = shift @_;
	$self->shell($self->install_prefix() . "/bin/phpize");

}


sub configure_flags {
	my $self = shift @_;
	return join " ", (
		$self->SUPER::configure_flags(@_),
		'--enable-intl --with-apxs --prefix=/usr/local/php5 --with-icu-dir=/usr/local/php5 --with-php-config=' . $self->install_prefix() . '/bin/php-config'
	);
}

1;
