#!/usr/bin/perl
# session_login.cgi
# Display the login form used in session login mode

BEGIN { push(@INC, ".."); };
use WebminCore;
$pragma_no_cache = 1;
#$ENV{'MINISERV_INTERNAL'} || die "Can only be called by miniserv.pl";
&init_config();
&ReadParse();
if ($gconfig{'loginbanner'} && $ENV{'HTTP_COOKIE'} !~ /banner=1/ &&
    !$in{'logout'} && !$in{'failed'} && !$in{'timed_out'}) {
	# Show pre-login HTML page
	print "Set-Cookie: banner=1; path=/\r\n";
	&PrintHeader();
	$url = $in{'page'};
	open(BANNER, $gconfig{'loginbanner'});
	while(<BANNER>) {
		s/LOGINURL/$url/g;
		print;
		}
	close(BANNER);
	return;
	}
$sec = uc($ENV{'HTTPS'}) eq 'ON' ? "; secure" : "";
&get_miniserv_config(\%miniserv);
$sidname = $miniserv{'sidname'} || "sid";
print "Set-Cookie: banner=0; path=/$sec\r\n" if ($gconfig{'loginbanner'});
print "Set-Cookie: $sidname=x; path=/$sec\r\n" if ($in{'logout'});
print "Set-Cookie: testing=1; path=/$sec\r\n";
$title = $text{'session_header'};
if ($gconfig{'showhost'}) {
        $title = &get_display_hostname()." : ".$title;
	}
&ui_print_unbuffered_header(
	undef, undef, undef, undef, undef, 1, 1, undef,
	"<title>$title</title>",
	"onLoad='document.forms[0].pass.value = \"\"; ".
	"document.forms[0].user.focus()'");

if ($tconfig{'inframe'}) {
	# Framed themes lose original page
	$in{'page'} = "/";
	}

print "<center>\n";
# Webmin logo
if (&get_product_name() eq 'webmin') {
    print "<a href=http://www.webmin.com/ target=_new>";
    print "<img src='$gconfig{'webprefix'}/images/webmin-blue.png' border=0 width='320' height='79'>";
    print "</a><p/><hr/>";
}

my $stext = "";

if (defined($in{'failed'})) {
    if ($in{'twofactor_msg'}) {
        $stext = "<h3>",&text('session_twofailed',
            &html_escape($in{'twofactor_msg'})),"</h3><p></p>\n";
    } else {
        $stext = "<h3>$text{'session_failed'}</h3><p></p>\n";
    }
} elsif ($in{'logout'}) {
	$stext = "<h3>$text{'session_logout'}</h3><p></p>\n";
} elsif ($in{'timed_out'}) {
    $stext = "<h3>",&text('session_timed_out', int($in{'timed_out'}/60)),"</h3><p></p>\n";
}

if ($text{'session_prefix'}) {
    $stext .="A $text{'session_prefix'}\n";
}

print &ui_form_start("$gconfig{'webprefix'}/session_login.cgi", "post");
print &ui_hidden("page", $in{'page'});
print &ui_table_start(undef, "width='450' class='loginform'", 2);

# Login message
if ($gconfig{'realname'}) {
	$host = &get_display_hostname();
	}
else {
	$host = $ENV{'HTTP_HOST'};
	$host =~ s/:\d+//g;
	$host = &html_escape($host);
	}

if ( $stext ne '' ) {
    print &ui_table_row(undef,
          $stext, 1, [ "align=center", "align=center" ]);
}

print &ui_table_row(undef,
      &text($gconfig{'nohostname'} ? 'session_mesg2' : 'session_mesg',
	    "<tt>$host</tt>"), 1, [ "align=center", "align=center" ]);

# Username and password
$tags = $gconfig{'noremember'} ? "autocomplete=off " : "";
$plu = "placeholder='$text{'session_user'}'";
print &ui_table_row(undef,
        &ui_textbox("user", $in{'failed'}, 20, 0, undef, $tags.$plu));

$plu = "placeholder='$text{'session_pass'}'";
print &ui_table_row(undef,
        &ui_password("pass", undef, 20, 0, undef, $tags.$plu));

# Two-factor token, for users that have it
if ($miniserv{'twofactor_provider'}) {
    print &ui_table_row(undef,
        &ui_textbox("twofactor", undef, 20, 0, undef,
            "autocomplete='off' placeholder='$text{'session_twofactor'}'"));
}

# Remember session cookie?
if (!$gconfig{'noremember'}) {
    print &ui_table_row(undef,
        &ui_checkbox("save", 1, $text{'session_save'}, 0));
}

print &ui_table_end(),"\n";
print &ui_submit($text{'session_login'});
#print &ui_reset($text{'session_clear'});
print &ui_form_end();


print "</center>\n";

# Output frame-detection Javascript, if theme uses frames
if ($tconfig{'inframe'}) {
	print <<EOF;
<script>
if (window != window.top) {
	window.top.location = window.location;
	}
</script>
EOF
	}

&ui_print_footer();

