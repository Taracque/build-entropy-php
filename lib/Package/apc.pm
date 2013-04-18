package Package::apc;

use strict;
use warnings;

use base qw(PackageSplice);

our $VERSION = '3.1.13';

sub base_url {
	return "http://pecl.php.net/get";
}

sub packagename {
	return "APC-" . $VERSION;
}

sub filename {
	return "APC-$VERSION.tar";
}

sub subpath_for_check {
	return "lib/php/extensions/no-debug-non-zts-20090626/apc.so";
}

sub make_flags {
	return '';
}

sub is_installed {
	my $self = shift @_;
	return undef;
}


sub php_dso_extension_names {
	my $self = shift @_;
	return qw(apc);
}

sub package_filelist {
	my $self = shift @_;
	return $self->php_dso_extension_paths(), qw(
		php.d/50-extension-apc.ini
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
		'--enable-apc --with-apxs --enable-apc-spinlocks --disable-apc-pthreadmutex --with-php-config=' . $self->install_prefix() . '/bin/php-config'
	);
}


1;
