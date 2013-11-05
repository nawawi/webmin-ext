#!/usr/bin/perl
# user_chooser.cgi
# This CGI generated the HTML for choosing a user or list of users.

BEGIN { push(@INC, ".."); };
use WebminCore;

$trust_unknown_referers = 1;
&init_config();
if (&get_product_name() eq 'usermin') {
	&switch_to_remote_user();
	}
&ReadParse(undef, undef, 2);
%text = &load_language($current_theme);
%access = &get_module_acl();

if ($in{'multi'}) {
	# selecting multiple users.
	if ($in{'frame'} == 0) {
		# base frame
		&PrintHeader();
		print "<script>\n";
		@ul = split(/\s+/, $in{'user'});
		$len = @ul;
		print "sel = new Array($len);\n";
		print "selr = new Array($len);\n";
		for($i=0; $i<$len; $i++) {
			print "sel[$i] = \"".
			      &quote_escape($ul[$i], '"')."\";\n";
			@uinfo = getpwnam($ul[$i]);
			if (@uinfo) {
				print "selr[$i] = \"".
				      &quote_escape($uinfo[6])."\";\n";
				}
			else {
				print "selr[$i] = \"???\";\n";
				}
			}
		print "</script>\n";
		print "<title>$text{'users_title1'}</title>\n";
## awie start
        print '<script>window.resizeTo(600,400);</script>';
## awie end
		print "<frameset cols='50%,50%'>\n";
		print "<frame src=\"user_chooser.cgi?frame=1&multi=1\">\n";
		print "<frameset rows='*,50' frameborder=no>\n";
		print " <frame src=\"user_chooser.cgi?frame=2&multi=1\">\n";
		print " <frame src=\"user_chooser.cgi?frame=3&multi=1\" scrolling=no>\n";
		print "</frameset>\n";
		print "</frameset>\n";
		}
	elsif ($in{'frame'} == 1) {
		# list of all users to choose from
		&popup_header();
		print "<script>\n";
		print "function adduser(u, r)\n";
		print "{\n";
		print "top.sel[top.sel.length] = u\n";
		print "top.selr[top.selr.length] = r\n";
		print "top.frames[1].location = top.frames[1].location\n";
		print "return false;\n";
		print "}\n";
		print "</script>\n";
## awie start
        print "<div class='searchsort'><b>".$text{'left_search'}."</b>&nbsp;";
        print &ui_textbox("search", undef, 20, 0, undef,"id='xsort'");
        print '<hr></div>';
## awie end
		print "<font size=+1>$text{'users_all'}</font>\n";
		print "<table width=100%>\n";
## awie start
        my $scnt = 0;
## awie end
		foreach $u (&get_users_list()) {
			if ($in{'user'} eq $u->[0]) { print "<tr class='xrow' $cb>\n"; }
			else { print "<tr class='xrow'>\n"; }
			$u->[6] =~ s/'/&#39;/g;
			print "<td width=20%><a href=\"\" onClick='return adduser(\"$u->[0]\", \"$u->[6]\")'>$u->[0]</a></td>\n";
			print "<td>$u->[6]</td> </tr>\n";
## awie start
            $scnt++;
## awie end
			}
		print "</table>\n";
## awie start
    if ( $scnt >= 10 ) {
        print '<script>jQuery("div.searchsort").show();</script>';
    }
print <<_EOF;
<script type="text/javascript">
jQuery(document).ready(function() {
    jQuery("input#xsort").keyup(function(e) {
        var val = jQuery(this).val();
        if ( val !== '' ) {
            jQuery("tr[class=xrow]").hide();
            jQuery("a").each(function() {
                var t = jQuery(this).text().toLowerCase();
                if ( t.match(val.toLowerCase()) ) {
                    jQuery(this).parent().parent().show();
                }
            });
        } else {
            jQuery("tr[class=xrow]").show();
        }
    });
});
</script>
_EOF
## awie end
		&popup_footer();
		}
	elsif ($in{'frame'} == 2) {
		# show chosen users
		&popup_header();
		print "<font size=+1>$text{'users_sel'}</font>\n";
		print <<'EOF';
<table width=100%>
<script>
function sub(j)
{
sel2 = new Array(); selr2 = new Array();
for(k=0,l=0; k<top.sel.length; k++) {
	if (k != j) {
		sel2[l] = top.sel[k];
		selr2[l] = top.selr[k];
		l++;
		}
	}
top.sel = sel2; top.selr = selr2;
top.frames[1].location = top.frames[1].location;
return false;
}
for(i=0; i<top.sel.length; i++) {
	document.write("<tr>\n");
	document.write("<td><a href=\"\" onClick='return sub("+i+")'>"+top.sel[i]+"</a></td>\n");
	document.write("<td>"+top.selr[i]+"</td>\n");
	}
</script>
</table>
EOF
		&popup_footer();
		}
	elsif ($in{'frame'} == 3) {
		# output OK and Cancel buttons
		&popup_header();
		print "<script>\n";
		print "function qjoin(l)\n";
		print "{\n";
		print "rv = \"\";\n";
		print "for(i=0; i<l.length; i++) {\n";
		print "    if (rv != '') rv += ' ';\n";
		print "    if (l[i].indexOf(' ') < 0) rv += l[i];\n";
		print "    else rv += '\"'+l[i]+'\"'\n";
		print "    }\n";
		print "return rv;\n";
		print "}\n";
		print "</script>\n";
		print "<form>\n";
		print "<input type=button value=\"$text{'users_ok'}\" ",
		      "onClick='top.opener.ifield.value = qjoin(top.sel); ",
		      "top.close()'>\n";
		print "<input type=button value=\"$text{'users_cancel'}\" ",
		      "onClick='top.close()'>\n";
		print "&nbsp;&nbsp;<input type=button value=\"$text{'users_clear'}\" onClick='top.sel = new Array(); top.selr = new Array(); top.frames[1].location = top.frames[1].location'>\n";
		print "</form>\n";
		&popup_footer();
		}
	}
else {
	# selecting just one user .. display a list of all users to choose from
	&popup_header($text{'users_title2'});
	print "<script>\n";
	print "function select(f)\n";
	print "{\n";
	print "top.opener.ifield.value = f;\n";
	print "top.close();\n";
	print "return false;\n";
	print "}\n";
	print "</script>\n";
## awie start
    print '<script>window.resizeTo(300,300);</script>';
    print "<div class='searchsort'><b>".$text{'left_search'}."</b>&nbsp;";
    print &ui_textbox("search", undef, 20, 0, undef,"id='xsort'");
    print '<hr></div>';
## awie end
	print "<table width=100%>\n";
## awie start
    my $scnt = 0;
## awie end
	foreach $u (&get_users_list()) {
		if ($in{'user'} eq $u->[0]) { print "<tr class='xrow' $cb>\n"; }
		else { print "<tr class='xrow'>\n"; }
		print "<td width=20%><a href=\"\" onClick='return select(\"$u->[0]\")'>$u->[0]</a></td>\n";
		print "<td>$u->[6]</td> </tr>\n";
## awie start
        $scnt++;
## awie end
		}
	print "</table>\n";
## awie start
    if ( $scnt >= 10 ) {
        print '<script>jQuery("div.searchsort").show();</script>';
    }
print <<_EOF;
<script type="text/javascript">
jQuery(document).ready(function() {
    jQuery("input#xsort").keyup(function(e) {
        var val = jQuery(this).val();
        if ( val !== '' ) {
            jQuery("tr[class=xrow]").hide();
            jQuery("a").each(function() {
                var t = jQuery(this).text().toLowerCase();
                if ( t.match(val.toLowerCase()) ) {
                    jQuery(this).parent().parent().show();
                }
            });
        } else {
            jQuery("tr[class=xrow]").show();
        }
    });
});
</script>
_EOF
## awie end
	&popup_footer();
	}

sub get_users_list
{
local(@uinfo, @users, %ucan, %found);
if ($access{'uedit_mode'} == 2 || $access{'uedit_mode'} == 3) {
	map { $ucan{$_}++ } split(/\s+/, $access{'uedit'});
	}
setpwent();
while(@uinfo = getpwent()) {
	if ($access{'uedit_mode'} == 5 && $access{'uedit'} !~ /^\d+$/) {
		# Get group for matching by group name
		@ginfo = getgrgid($uinfo[3]);
		}
	if ($access{'uedit_mode'} == 0 ||
	    $access{'uedit_mode'} == 2 && $ucan{$uinfo[0]} ||
	    $access{'uedit_mode'} == 3 && !$ucan{$uinfo[0]} ||
	    $access{'uedit_mode'} == 4 &&
		(!$access{'uedit'} || $uinfo[2] >= $access{'uedit'}) &&
		(!$access{'uedit2'} || $uinfo[2] <= $access{'uedit2'}) ||
	    $access{'uedit_mode'} == 5 &&
	     ($access{'uedit'} =~ /^\d+$/ && $uinfo[3] == $access{'uedit'} ||
	      $ginfo[0] eq $access{'uedit'})) {
		push(@users, [ @uinfo ]) if (!$found{$uinfo[0]}++);
		}
	}
endpwent() if ($gconfig{'os_type'} ne 'hpux');
return sort { $a->[0] cmp $b->[0] } @users;
}

