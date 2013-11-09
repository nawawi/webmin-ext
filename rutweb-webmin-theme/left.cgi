#!/usr/bin/perl
# Show the left-side menu of Webmin modules

BEGIN { push(@INC, ".."); };
use WebminCore;
&init_config();
&ReadParse();
%text = &load_language($current_theme);
%gaccess = &get_module_acl(undef, "");

# Work out what modules and categories we have
@cats = &get_visible_modules_categories();
@modules = map { @{$_->{'modules'}} } @cats;
&popup_header('left');

# Show login
print "<div class='wrapper'>\n";
print "<table id='main' width='100%'><tbody><tr><td>\n";
print &text('left_login', $remote_user),"<br>\n";
print "<hr>\n";

if ($gconfig{"notabs_${base_remote_user}"} == 2 ||
    $gconfig{"notabs_${base_remote_user}"} == 0 && $gconfig{'notabs'} || @modules <= 1) {
    # Show all modules in one list
    foreach $minfo (@modules) {
        $target = $minfo->{'noframe'} ? "_top" : "right";
        print "<a target=$target href=$minfo->{'dir'}/>$minfo->{'desc'}</a><br>\n";
    }
} else {
    # Show all modules under categories
    foreach $c (@cats) {
        # Show category opener, plus modules under it
        &print_category_opener(
            $c->{'code'},
            $in{$c->{'code'}} ? 1 : 0,
            $c->{'unused'} ? "<font color=#888888>$c->{'desc'}</font>" : $c->{'desc'}
        );
        $cls = $in{$c->{'code'}} ? "itemshown" : "itemhidden";
        print "<div class='$cls' id='$c->{'code'}'>";
        foreach my $minfo (@{$c->{'modules'}}) {
            &print_category_link("$minfo->{'dir'}/",
                $minfo->{'desc'},
                undef,
                undef,
                $minfo->{'noframe'} ? "_top" : "",
            );
        }
        print "</div>\n";
    }
}

# Show module/help search form
if ( -r "$root_directory/webmin_search.cgi" && $gaccess{'webminsearch'} ) {
    print "<hr/>";
    print "<form action=webmin_search.cgi target=right>\n";
    print &ui_textbox("search", undef, 20, undef, undef, "placeholder='$text{'search'}' style='width:100%;'");
}

print "<div class='leftlink'><hr></div>\n";

# Show current module's log search, if logging
if ($gconfig{'log'} && &foreign_available("webminlog")) {
    print "<div class='linkwithicon'><img src='images/logs.png'>\n";
    print "<div class='aftericon'><a target=right href='webminlog/' onClick='show_logs(); return false;'>$text{'left_logs'}</a></div></div>\n";
}

# Show info link
print "<div class='linkwithicon'><img src='images/gohome.png'>\n";
print "<div class='aftericon'><a target=right href='right.cgi?open=system&open=status'>$text{'left_home'}</a></div></div>\n";

# Show feedback link, but only if a custom email is set
%gaccess = &get_module_acl(undef, "");
if (&get_product_name() eq 'webmin' &&
    !$ENV{'ANONYMOUS_USER'} &&
    $gconfig{'nofeedbackcc'} != 2 &&
    $gaccess{'feedback'} &&
    $gconfig{'feedback_to'} ||
    &get_product_name() eq 'usermin' &&
    !$ENV{'ANONYMOUS_USER'} &&
        $gconfig{'feedback'}
) {
    print "<div class='linkwithicon'><img src='images/mail-small.png'>\n";
    print "<div class='aftericon'><a target=right href='feedback_form.cgi'>$text{'left_feedback'}</a></div></div>\n";
}

# Show refesh modules link, for master admin
if (&foreign_available("webmin")) {
    print "<div class='linkwithicon'><img src='images/refresh-small.png'>\n";
    print "<div class='aftericon'><a target=right href='webmin/refresh_modules.cgi'>$text{'main_refreshmods'}</a></div></div>\n";
}

# Show logout link
&get_miniserv_config(\%miniserv);
if ($miniserv{'logout'} && !$ENV{'SSL_USER'} && !$ENV{'LOCAL_USER'} &&
        $ENV{'HTTP_USER_AGENT'} !~ /webmin/i) {
        print "<div class='linkwithicon'><img src='images/quit.png'>\n";
    if ($main::session_id) {
        print "<div class='aftericon'><a target=_top href='session_login.cgi?logout=1'>$text{'main_logout'}</a></div>";
    } else {
        print "<div class='aftericon'><a target=_top href='switch_user.cgi'>$text{'main_switch'}</a></div>";
    }
    print "</div>\n";
}

# Show link back to original Webmin server
if ($ENV{'HTTP_WEBMIN_SERVERS'}) {
    print "<div class='linkwithicon'><img src=images/webmin-small.gif>\n";
    print "<div class='aftericon'><a target=_top href='$ENV{'HTTP_WEBMIN_SERVERS'}'>$text{'header_servers'}</a></div>";
}

print "</td></tr></tbody></table>\n";
print "</div>\n";
&popup_footer();

# print_category_opener(name, &allcats, label)
# Prints out an open/close twistie for some category
sub print_category_opener {
    my ($c, $status, $label) = @_;
    $label = $c eq "others" ? $text{'left_others'} : $label;
    local $img = $status ? "red-open.gif" : "red-closed.gif";

    # Show link to close or open category
    print "<div class='linkwithicon'>";
    print "<a href=\"javascript:toggleview('$c','toggle$c')\" id='toggle$c'><img border='0' src='images/$img' alt='[+]'></a>\n";
    print "<div class='aftericon'><a href=\"javascript:toggleview('$c','toggle$c')\" id='toggle$c'><font color=#000000>$label</font></a></div></div>\n";
}


sub print_category_link {
    my ($link, $label, $image, $noimage, $target) = @_;
    $target ||= "right";
    print "<div class='linkindented'><a target=$target href=$link>$label</a></div>\n";
}

