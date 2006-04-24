package Package::php5;

use strict;
use warnings;

use base qw(PackageSplice);

our $RELEASE = 4;




sub base_url {
	return "http://us2.php.net/distributions";
}


sub packagename {
	my $self = shift @_;
	return "php-" . $self->config()->version();
}


sub dependency_names {
	return qw(curl mysql libxml2 libxslt pdflib oracleinstantclient
		imapcclient libjpeg libpng libfreetype iodbc);
}


sub subpath_for_check {
	return "libphp5.so";
}


sub configure_flags {
	my $self = shift @_;
	my %args = @_;
	my $prefix = $self->config()->prefix();

	my @extension_flags = (
		"--with-config-file-scan-dir=$prefix/config",
		'--with-iconv',
		'--with-openssl=/usr',
		'--with-zlib=/usr',
		"--with-gd",
		'--with-zlib-dir=/usr',
		"--with-ldap",
		"--with-xmlrpc",
		"--with-iconv-dir=/usr",
		"--enable-exif",
		"--enable-wddx",
		"--enable-soap",
		"--enable-sqlite-utf8",
		"--enable-ftp",
		"--enable-sockets",
		"--enable-dbx",
		"--enable-dbase",
		"--enable-mbstring",
		"--enable-calendar",
		"--with-bz2=/usr",
	);

	push @extension_flags, $self->dependency_extension_flags(%args);

	return $self->SUPER::configure_flags() . " --with-apxs @extension_flags";
	
}



sub dependency_extension_flags {

	my $self = shift @_;
	my (%args) = @_;

#	my $prefix = $self->config()->prefix();

# 	my $mysql_prefix = $self->config()->mysql_install_prefix();
# 	die "mysql install prefix '$mysql_prefix' does not exist" unless (-d $mysql_prefix);

#	my %map = (
#		curl                => "--with-curl=shared,$prefix",
#		mysql               => "--with-mysql=$mysql_prefix --with-mysqli=$mysql_prefix/bin/mysql_config",
#		libxml2             => "--with-libxml-dir=shared,$prefix",
#		libxslt             => "--with-xsl=shared,$prefix",
#		pdflib              => "--with-pdflib=shared,$prefix",
#		imapcclient         => "--with-imap=../imap-2004g --with-kerberos=/usr --with-imap-ssl=/usr",
#		libjpeg             => "--with-jpeg-dir=$prefix",
#		libpng              => "--with-png-dir=$prefix",
#		libfreetype         => "--with-freetype-dir=$prefix --enable-gd-native-ttf",
#		oracleinstantclient => "--with-oci8=shared,instantclient,$prefix/oracle --with-pdo-oci=shared,instantclient,$prefix/oracle,10.1.0.3",
#	);

	return map {$_->php_extension_configure_flags()} grep {$_->supports_arch($args{arch})} $self->dependencies();

}



sub build_arch_pre {

	my $self = shift @_;
	my (%args) = @_;

	$self->cd('ext');
	$self->shell("rm -rf pdf");
	my $pdflib_extension_tarball = $self->extras_dir() . "/pdflib-2.0.5.tgz";
	die "pdflib extensions tarball '$pdflib_extension_tarball' does not exist" unless (-f $pdflib_extension_tarball);

	$self->shell("tar -xzvf $pdflib_extension_tarball");
	$self->shell("mv pdflib-2.*.* pdf; rm package.xml");

	$self->cd_packagesrcdir();
	$self->shell("aclocal");
	$self->shell("./buildconf --force");
	$self->shell({fatal => 0}, "ranlib " . $self->install_prefix() . "/lib/*.a");
	$self->shell({fatal => 0}, "ranlib " . $self->install_tmp_prefix() . "/lib/*.a");

}





sub make_install_arch {

	my $self = shift @_;
	my (%args) = @_;

	my $install_override = $self->make_install_override_list(prefix => $args{prefix});

	$self->shell($self->make_command() . " $install_override install-$_") foreach qw(cli pear build headers programs modules);
	$self->shell("cp libs/libphp5.so $args{prefix}");

}



sub install {

	my $self = shift @_;

	$self->SUPER::install(@_);
	
	my $extrasdir = $self->extras_dir();
	my $prefix = $self->config()->prefix();


#	$self->install_cleanup();

	$self->cd_packagesrcdir();
	$self->shell({silent => 0}, "cat $extrasdir/dist/entropy-php.conf | sed -e 's!{prefix}!$prefix!g' > $prefix/entropy-php.conf");
	$self->shell({silent => 0}, "cat $extrasdir/dist/resources/activate-entropy-php.py | sed -e 's!{prefix}!$prefix!g' > $prefix/bin/activate-entropy-php.py");
	$self->shell({silent => 0}, "cp php.ini-recommended $prefix/lib/");
	$self->shell({silent => 0}, "test -d $prefix/php.d || mkdir $prefix/php.d");

	$self->create_dso_ini_files();

}



sub create_dso_ini_files {

	my $self = shift @_;

	my @dso_names = grep {$_} map {$_->php_dso_extension_names()} $self->dependencies();
	my $prefix = $self->config()->prefix();
	$self->shell({silent => 0}, "echo 'extension=$_' > $prefix/php.d/extension-$_.ini") foreach (@dso_names);

}



sub install_cleanup {

	my $self = shift @_;

	my $prefix = $self->config()->prefix();

	$self->shell({fatal => 0}, "rm $prefix/lib/php/extensions/*/*.a");

}




sub create_package {

	my $self = shift @_;

	return unless ($self->SUPER::create_package(@_));
	
	return undef;

}




sub create_distimage {

	my $self = shift @_;

	$self->install();

	$self->create_package();

}


sub unpack {

	my $self = shift @_;

	$self->SUPER::unpack();

	my $patchfile = $self->extras_path('php-entropy.patch');
	my $mingtarball = $self->extras_path('ming.tar.gz');
	
	$self->cd_packagesrcdir();
	$self->shell("grep -q ENTROPY_CH ext/standard/info.c || patch -p1 < $patchfile");
	$self->cd("ext");
	$self->shell("tar -xzf $mingtarball");

}


sub cflags {

	my $self = shift @_;
	
	return $self->SUPER::cflags(@_) . " -DENTROPY_CH_RELEASE=" . $self->config()->release();

}




sub package_filelist {

	my $self = shift @_;

	return qw(
		entropy-php.conf libphp5.so etc lib/libxml2*.dylib lib/libpng12*.dylib
		lib/libfreetype*.dylib bin/php* bin/activate-*
	);
	
}





sub create_package {

	my $self = shift @_;

	$self->SUPER::create_package(@_);


	# metapackage	
}


sub pkg_filename {
	my $self = shift @_;
	my $version = $self->config()->version() . '-' . $self->config()->release();
	return "entropy-php-$version.pkg";
}









1;
