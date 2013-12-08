# tab size: 4
# tab type: space
# Based on Virtualmin Framed Theme

# Global state for wrapper
$WRAPPER_OPEN = 0;
$COLUMNS_WRAPPER_OPEN = 0;
%tinfo = &get_theme_info($current_theme);
$VERSION = ( $tinfo{'version'} ? $tinfo{'version'} : 20121208 );
$VERSION =~ s/\.//g;

# functions
sub nw_script_exists {
    my ($file) = @_;
    if ( -f "$root_directory/$current_theme/unauthenticated/$file" ) {
        return 1;
    }
    return 0;
}

sub nw_js_src {
    my ($file) = @_;
    my @files = split(/ /, $file);
    my $fs;
    foreach $fs (@files) {
        print "<script type='text/javascript' src='$gconfig{'webprefix'}/unauthenticated/".$fs."?".$VERSION."'></script>" if ( nw_script_exists($fs) );
    }
}

sub nw_css_src {
    my ($file) = @_;
    my @files = split(/ /, $file);
    my $fs;
    foreach $fs (@files) {
        print "<link rel='stylesheet' type='text/css' href='$gconfig{'webprefix'}/unauthenticated/".$fs."?".$VERSION."'>" if ( nw_script_exists($fs) );
    }
}

sub nw_scripts {
    my ($type) = @_;
    if ( $ENV{SCRIPT_NAME} ) {
        $script = $ENV{SCRIPT_NAME};
        $script =~ s/^\///g;
        $script =~ s/\/$//g;
        $script =~ s/\.cgi$//g;
        $script =~ s/\//_/g;
        $script =~ s/\_index$//g;

        &nw_css_src("$script.css") if ( $type eq "css" );
        &nw_js_src("$script.js") if ( $type eq "js" );

    }
}

# theme_ui_post_header([subtext])
# Returns HTML to appear directly after a standard header() call
sub theme_ui_post_header {
    my ($text) = @_;
    my $rv;
    $rv .= "<div class='ui_post_header'>$text</div>" if (defined($text));
    #$rv .= "<div class='section'>";
    $rv .= "<p>" if (!defined($text));
    return $rv;
}

# theme_ui_pre_footer()
# Returns HTML to appear directly before a standard footer() call
sub theme_ui_pre_footer {
    my $rv;
    $rv .= "</div><p>";
    return $rv;
}

# ui_print_footer(args...)
# Print HTML for a footer with the pre-footer line. Args are the same as those
# passed to footer()
sub theme_ui_print_footer {
    local @args = @_;
    print &ui_pre_footer();
    &footer(@args);
}

sub theme_icons_table {
    my ($i, $need_tr);
    my $cols = $_[3] ? $_[3] : 4;
    my $per = int(100.0 / $cols);
    print "<div class='wrapper'>";
    print "<table id='main' width=100% cellpadding=5 class='icons_table'>";
    for($i=0; $i<@{$_[0]}; $i++) {
        if ($i%$cols == 0) { print "<tr>"; }
        print "<td width='$per'% align=center valign=top>";
        &generate_icon($_[2]->[$i], $_[1]->[$i], $_[0]->[$i],
            $_[4], $_[5], $_[6], $_[7]->[$i], $_[8]->[$i]);
        print "</td>";
        if ($i%$cols == $cols-1) { print "</tr>"; }
    }
    while($i++%$cols) { print "<td width='$per%'></td>"; $need_tr++; }
    print "</tr>" if ($need_tr);
    print "</table>";
    print "</div>";
}

sub theme_generate_icon {
    my $w = !defined($_[4]) ? "width=48" : $_[4] ? "width=$_[4]" : "";
    my $h = !defined($_[5]) ? "height=48" : $_[5] ? "height=$_[5]" : "";
    if ($tconfig{'noicons'}) {
        if ($_[2]) {
            print "$_[6]<a href=\"$_[2]\" $_[3]>$_[1]</a>$_[7]";
        } else {
            print "$_[6]$_[1]$_[7]";
        }
    } elsif ($_[2]) {
        print "<table><tr><td width=48 height=48>",
              "<a href=\"$_[2]\" $_[3]><img src=\"".$_[0]."?$VERSION\" alt=\"\" border=0 ",
              "$w $h></a></td></tr></table>";
        print "$_[6]<a href=\"$_[2]\" $_[3]>$_[1]</a>$_[7]";
    } else {
        print "<table><tr><td width=48 height=48>",
              "<img src=\"".$_[0]."?$VERSION\" alt=\"\" border=0 $w $h>",
              "</td></tr></table>$_[6]$_[1]$_[7]";
    }
}


sub theme_post_change_modules {
    print "<script type='text/javascript'>window.parent.frames[1].location = window.parent.frames[1].location;</script>";
}


sub theme_prehead {
    &nw_css_src("reset.css reset-fonts-base.css style.css others.css");

    if ($ENV{'HTTP_USER_AGENT'} =~ /msie/i) {
        print "<!--[if IE]>";
        print "<style type=\"text/css\">";
        print "table.formsection, table.ui_table, table.loginform { border-collapse: collapse; }";
        print "</style>";
        print "<![endif]-->";
    }

    &nw_scripts("css");

    if ($ENV{'HTTP_USER_AGENT'} =~ /Chrome/) {
        print "<style type='text/css'>";
	    print "textarea/*,pre*/ { font-size:120%; }";
        print "</style>";
    }

    print "<script type='text/javascript'>";
    print "var VERSION='".$VERSION."',rowsel = new Array();";
    print "</script>";
    &nw_js_src("sorttable.js jquery.js placeholder.js behavior.js");
    &nw_scripts("js");
}

sub theme_popup_prehead {
    return &theme_prehead();
}

# ui_table_start(heading, [tabletags], [cols], [&default-tds], [right-heading])
# A table with a heading and table inside
sub theme_ui_table_start {
    my ($heading, $tabletags, $cols, $tds, $rightheading) = @_;
    if (! $tabletags =~ /width/) { $tabletages .= " width=100%"; }
    if (defined($main::ui_table_cols)) {
        # Push on stack, for nested call
        push(@main::ui_table_cols_stack, $main::ui_table_cols);
        push(@main::ui_table_pos_stack, $main::ui_table_pos);
        push(@main::ui_table_default_tds_stack, $main::ui_table_default_tds);
    }
    my $rv;
    my $colspan = 1;

    if (!$WRAPPER_OPEN) {
        $rv .= "<table class='shrinkwrapper'".($tabletags ? " ".$tabletags : "").">";
        $rv .= "<tr><td>";
    }
    $WRAPPER_OPEN++;
    $rv .= "<table class='ui_table'".($tabletags ? " ".$tabletags : "").">";
    if (defined($heading) || defined($rightheading)) {
        $rv .= "<thead><tr>";
        if (defined($heading)) {
            $rv .= "<td><b>$heading</b></td>"
        }
        if (defined($rightheading)) {
            $rv .= "<td align=right>$rightheading</td>";
            $colspan++;
        }
        $rv .= "</tr></thead>";
    }
    $rv .= "<tbody> <tr class='ui_table_body'><td colspan='$colspan'>".
            "<table width='100%'>";
    $main::ui_table_cols = $cols || 4;
    $main::ui_table_pos = 0;
    $main::ui_table_default_tds = $tds;
    return $rv;
}

# ui_table_row(label, value, [cols], [&td-tags])
# Returns HTML for a row in a table started by ui_table_start, with a 1-column
# label and 1+ column value.
sub theme_ui_table_row {
    my ($label, $value, $cols, $tds) = @_;
    $cols ||= 1;
    $tds ||= $main::ui_table_default_tds;
    my $rv;
    if ($main::ui_table_pos+$cols+1 > $main::ui_table_cols &&
        $main::ui_table_pos != 0) {
        # If the requested number of cols won't fit in the number
        # remaining, start a new row
        $rv .= "</tr>";
        $main::ui_table_pos = 0;
    }
    $rv .= "<tr class='ui_form_pair'>" if ($main::ui_table_pos%$main::ui_table_cols == 0);
    $rv .= "<td class='ui_form_label'".($tds->[0] ? " ".$tds->[0] : "")."><b>$label</b></td>" if (defined($label));
    $rv .= "<td class='ui_form_value' colspan='$cols'".($tds->[1] ? " ".$tds->[1] : "").">$value</td>";
    $main::ui_table_pos += $cols+(defined($label) ? 1 : 0);
    if ($main::ui_table_pos%$main::ui_table_cols == 0) {
        $rv .= "</tr>";
        $main::ui_table_pos = 0;
    }
    return $rv;
}

# ui_table_end()
# The end of a table started by ui_table_start
sub theme_ui_table_end {
    my $rv;
    if ($main::ui_table_cols == 4 && $main::ui_table_pos) {
        # Add an empty block to balance the table
        $rv .= &ui_table_row(" ", " ");
    }
    if (@main::ui_table_cols_stack) {
        $main::ui_table_cols = pop(@main::ui_table_cols_stack);
        $main::ui_table_pos = pop(@main::ui_table_pos_stack);
        $main::ui_table_default_tds = pop(@main::ui_table_default_tds_stack);
    } else {
        $main::ui_table_cols = undef;
        $main::ui_table_pos = undef;
        $main::ui_table_default_tds = undef;
    }
    $rv .= "</tbody></table></td></tr></table>";
    if ($WRAPPER_OPEN==1) {
        #$rv .= "</div>";
        $rv .= "</td></tr>";
        $rv .= "</table>";
    }
    $WRAPPER_OPEN--;
    return $rv;
}

# theme_ui_tabs_start(&tabs, name, selected, show-border)
# Render a row of tabs from which one can be selected. Each tab is an array
# ref containing a name, title and link.
sub theme_ui_tabs_start {
    my ($tabs, $name, $sel, $border) = @_;
    my $rv;
    if (!$main::ui_hidden_start_donejs++) {
        $rv .= &ui_hidden_javascript();
    }

    # Build list of tab titles and names
    my $tabnames = "[".join(",", map { "\"".&quote_escape($_->[0])."\"" } @$tabs)."]";
    my $tabtitles = "[".join(",", map { "\"".&quote_escape($_->[1])."\"" } @$tabs)."]";
    $rv .= "<script type='text/javascript'>";
    $rv .= "document.${name}_tabnames = $tabnames;";
    $rv .= "document.${name}_tabtitles = $tabtitles;";
    $rv .= "</script>";

    # Output the tabs
    my $imgdir = "$gconfig{'webprefix'}/images";
    $rv .= &ui_hidden($name, $sel)."";
    $rv .= "<div class='ui_tabs'><table border=0 cellpadding=0 cellspacing=0 class='ui_tabs'>";
    $rv .= "<tr>";
    foreach my $t (@$tabs) {
        my $tabid = "tab_".$t->[0];
        $rv .= "<td id=${tabid} class='ui_tab'>";
        $rv .= "<table cellpadding=0 cellspacing=0 border=0><tr>";
        if ($t->[0] eq $sel) {
            # Selected tab
            $rv .= "<td class='tabSelected' nowrap>$t->[1]</td>";
        } else {
            # Other tab (which has a link)
            $rv .= "<td class='tabUnselected' nowrap>".
                   "<a href='$t->[2]' ".
                   "onClick='return select_tab(\"$name\", \"$t->[0]\")'>".
                   "$t->[1]</a></td>";
            $rv .= "</td>";
		}
        $rv .= "</tr></table>";
        $rv .= "</td>";
    }
    $rv .= "</table></div>";

    $main::ui_tabs_selected = $sel;
    return $rv;
}

sub theme_ui_tabs_end {
    return;
}

# theme_ui_columns_start(&headings, [width-percent], [noborder], [&tdtags], [title])
# Returns HTML for a multi-column table, with the given headings
sub theme_ui_columns_start {
    my ($heads, $width, $noborder, $tdtags, $title) = @_;
    my ($href) = grep { $_ =~ /<a\s+href/i } @$heads;
    my $rv;
    $theme_ui_columns_row_toggle = 0;
    if (!$noborder && !$COLUMNS_WRAPPER_OPEN) {
        $rv .= "<table class='wrapper' width="
	         . ($width ? $width : "100")
	         . "%>";
        $rv .= "<tr><td>";
    }
    if (!$noborder) {
        $COLUMNS_WRAPPER_OPEN++;
    }
    my @classes;
    push(@classes, "ui_table") if (!$noborder);
    push(@classes, "sortable") if (!$href);
    push(@classes, "ui_columns");
    $rv .= "<table".(@classes ? " class='".join(" ", @classes)."'" : "").
        (defined($width) ? " width=$width%" : "").">";

    if ($title) {
        $rv .= "<thead><tr".($tb ? " ".$tb : "")." class='ui_columns_heading'>".
	           "<td colspan=".scalar(@$heads)."><b>$title</b></td>".
	           "</tr></thead><tbody>";
    }

    $rv .= "<thead><tr".($tb ? " ".$tb : "")." class='ui_columns_heads'>";
    my $i;
    for($i=0; $i<@$heads; $i++) {
        $rv .= "<td".( $tdtags->[$i] ? " ".$tdtags->[$i] : "")."><b>".
                ($heads->[$i] eq "" ? "<br>" : $heads->[$i])."</b></td>";
    }
    $rv .= "</tr></thead><tbody>";
    $theme_ui_columns_count++;
    return $rv;
}

# theme_ui_columns_row(&columns, &tdtags)
# Returns HTML for a row in a multi-column table
sub theme_ui_columns_row {
    $theme_ui_columns_row_toggle = $theme_ui_columns_row_toggle ? '0' : '1';
    my ($cols, $tdtags) = @_;
    my $rv;
    $rv .= "<tr class='ui_columns_row row$theme_ui_columns_row_toggle'>";
    my $i;
    for($i=0; $i<@$cols; $i++) {
        $rv .= "<td ".$tdtags->[$i].">".
                ($cols->[$i] !~ /\S/ ? "<br>" : $cols->[$i])."</td>";
    }
    $rv .= "</tr>";
    return $rv;
}

# theme_ui_columns_end()
# Returns HTML to end a table started by ui_columns_start
sub theme_ui_columns_end {
    my $rv;
    $rv = "</tbody></table>";
    if ($COLUMNS_WRAPPER_OPEN == 1) { # Last wrapper
        $rv .= "</td></tr></table>";
    }
    $COLUMNS_WRAPPER_OPEN--;
    return $rv;
}

# theme_ui_grid_table(&elements, columns, [width-percent], [tds], [tabletags],
#   [title])
# Given a list of HTML elements, formats them into a table with the given
# number of columns. However, themes are free to override this to use fewer
# columns where space is limited.
sub theme_ui_grid_table {
    my ($elements, $cols, $width, $tds, $tabletags, $title) = @_;
    return "" if (!@$elements);
	
    my $rv = "<table class='wrapper' " 
            . ($width ? " width=$width%" : " width=100%")
            . ($tabletags ? " ".$tabletags : "")
            . "><tr><td>";
    $rv .= "<table class='ui_table ui_grid_table'"
         . ($width ? " width=$width%" : "")
         . ($tabletags ? " ".$tabletags : "")
         . ">";
    if ($title) {
        $rv .= "<thead><tr class='ui_grid_heading'> ".
               "<td colspan=$cols><b>$title</b></td></tr></thead>";
    }
    $rv .= "<tbody>";
    my $i;
    for($i=0; $i<@$elements; $i++) {
        $rv .= "<tr class='ui_grid_row'>" if ($i%$cols == 0);
        $rv .= "<td ".$tds->[$i%$cols]." valign=top class='ui_grid_cell'>".
            $elements->[$i]."</td>";
        $rv .= "</tr>" if ($i%$cols == $cols-1);
    }

    if ($i%$cols) {
        while($i%$cols) {
            $rv .= "<td ".$tds->[$i%$cols]." class='ui_grid_cell'><br></td>";
            $i++;
        }
        $rv .= "</tr>";
    }
    $rv .= "</table>";
    $rv .= "</tbody>";
    $rv .= "</td></tr></table>"; # wrapper
    return $rv;
}

# theme_ui_hidden_table_start(heading, [tabletags], [cols], name, status,
#                             [&default-tds], [rightheading])
# A table with a heading and table inside, and which is collapsible
sub theme_ui_hidden_table_start {
    my ($heading, $tabletags, $cols, $name, $status, $tds, $rightheading) = @_;
    my $rv;
    if (!$main::ui_hidden_start_donejs++) {
        $rv .= &ui_hidden_javascript();
    }
    my $divid = "hiddendiv_$name";
    my $openerid = "hiddenopener_$name";
    my $defimg = $status ? "open.gif" : "closed.gif";
    $defimg .= "?".$VERSION;
    my $defclass = $status ? 'opener_shown' : 'opener_hidden';
    my $text = defined($tconfig{'cs_text'}) ? $tconfig{'cs_text'} :
               defined($gconfig{'cs_text'}) ? $gconfig{'cs_text'} : "000000";

    if (!$WRAPPER_OPEN) { # If we're not already inside of a wrapper, wrap it
        $rv .= "<table class='shrinkwrapper'".($tabletags ? " ".$tabletags : "").">";
        $rv .= "<tr><td>";
    }

    $WRAPPER_OPEN++;
    my $colspan = 1;
    $rv .= "<table class='ui_table'".($tabletags ? " ".$tabletags : "").">";
    if (defined($heading) || defined($rightheading)) {
        $rv .= "<thead><tr>";
        if (defined($heading)) {
            $rv .= "<td><a href=\"javascript:hidden_opener('$divid', '$openerid')\" id='$openerid'><img border=0 src='$gconfig{'webprefix'}/images/$defimg'></a><a href=\"javascript:hidden_opener('$divid', '$openerid')\" class='ui-hidden-table-title'><b>$heading</b></a></td>";
        }
        if (defined($rightheading)) {
            $rv .= "<td align=right>$rightheading</td>";
            $colspan++;
        }
        $rv .= "</tr> </thead>";
    }
    $rv .= "<tbody><tr> <td colspan=$colspan><div class='$defclass' id='$divid'><table width=100%>";
    $main::ui_table_cols = $cols || 4;
    $main::ui_table_pos = 0;
    $main::ui_table_default_tds = $tds;
    return $rv;
}

# ui_hidden_table_end(name)
# Returns HTML for the end of table with hiding, as started by
# ui_hidden_table_start
sub theme_ui_hidden_table_end {
    my ($name) = @_;
    my $rv = "</table></div></td></tr></tbody></table>";
    if ( $WRAPPER_OPEN == 1 ) {
        $WRAPPER_OPEN--;
        $rv .= "</td></tr></table>";
    } elsif ($WRAPPER_OPEN) { 
        $WRAPPER_OPEN--;
    }
    return $rv;
}

# theme_select_all_link(field, form, text)
# Adds support for row highlighting to the normal select all
sub theme_select_all_link {
    my ($field, $form, $text) = @_;
    $form = int($form);
    $text ||= $text{'ui_selall'};
    return "<a class='select_all' href='#' onClick='f = document.forms[$form]; ff = f.$field; ff.checked = true; r = document.getElementById(\"row_\"+ff.id); if (r) { r.className = \"mainsel\" }; for(i=0; i<f.$field.length; i++) { ff = f.${field}[i]; if (!ff.disabled) { ff.checked = true; r = document.getElementById(\"row_\"+ff.id); if (r) { r.className = \"mainsel\" } } } return false'>$text</a>";
}

# theme_select_invert_link(field, form, text)
# Adds support for row highlighting to the normal invert selection
sub theme_select_invert_link {
    my ($field, $form, $text) = @_;
    $form = int($form);
    $text ||= $text{'ui_selinv'};
    return "<a class='select_invert' href='#' onClick='f = document.forms[$form]; ff = f.$field; ff.checked = !f.$field.checked; r = document.getElementById(\"row_\"+ff.id); if (r) { r.className = ff.checked ? \"mainsel\" : \"mainbody\" }; for(i=0; i<f.$field.length; i++) { ff = f.${field}[i]; if (!ff.disabled) { ff.checked = !ff.checked; r = document.getElementById(\"row_\"+ff.id); if (r) { r.className = ff.checked ? \"mainsel\" : \"mainbody row\"+((i+1)%2) } } } return false'>$text</a>";
}

sub theme_select_rows_link {
    my ($field, $form, $text, $rows) = @_;
    $form = int($form);
    my $js = "var sel = { ".join(",", map { "\"".&quote_escape($_)."\":1" } @$rows)." }; ";
    $js .= "for(var i=0; i<document.forms[$form].${field}.length; i++) { var ff = document.forms[$form].${field}[i]; var r = document.getElementById(\"row_\"+ff.id); ff.checked = sel[ff.value]; if (r) { r.className = ff.checked ? \"mainsel\" : \"mainbody row\"+((i+1)%2) } } ";
    $js .= "return false;";
    return "<a class='select_rows' href='#' onClick='$js'>$text</a>";
}

sub theme_ui_checked_columns_row {
    $theme_ui_columns_row_toggle = $theme_ui_columns_row_toggle ? '0' : '1';
    my ($cols, $tdtags, $checkname, $checkvalue, $checked, $disabled, $tags) = @_;
    my $rv;
    my $cbid = &quote_escape(quotemeta("${checkname}_${checkvalue}"));
    my $rid = &quote_escape(quotemeta("row_${checkname}_${checkvalue}"));
    my $ridtr = &quote_escape("row_${checkname}_${checkvalue}");
    my $mycb = $cb;
    if ($checked) {
        $mycb =~ s/mainbody/mainsel/g;
    }
    $mycb =~ s/class='/class='row$theme_ui_columns_row_toggle ui_checked_columns /;
    $rv .= "<tr id=\"$ridtr\" $mycb onMouseOver=\"this.className = document.getElementById('$cbid').checked ? 'mainhighsel' : 'mainhigh'\" onMouseOut=\"this.className = document.getElementById('$cbid').checked ? 'mainsel' : 'mainbody row$theme_ui_columns_row_toggle'\">";
    $rv .= "<td class='ui_checked_checkbox' ".$tdtags->[0].">".
            &ui_checkbox($checkname, $checkvalue, undef, $checked, $tags." "."onClick=\"document.getElementById('$rid').className = this.checked ? 'mainhighsel' : 'mainhigh';\"", $disabled).
            "</td>";
    my $i;
    for($i=0; $i<@$cols; $i++) {
        $rv .= "<td ".$tdtags->[$i+1].">";
        if ($cols->[$i] !~ /<a\s+href|<input|<select|<textarea|<span|<p|<br/) {
            $rv .= "<label for=\"".
            &quote_escape("${checkname}_${checkvalue}")."\">";
        }
        $rv .= ($cols->[$i] !~ /\S/ ? "<br>" : $cols->[$i]);
        if ($cols->[$i] !~ /<a\s+href|<input|<select|<textarea|<span|<p|<br/) {
            $rv .= "</label>";
        }
        $rv .= "</td>";
    }
    $rv .= "</tr>";
    return $rv;
}

sub theme_ui_radio_columns_row {
    my ($cols, $tdtags, $checkname, $checkvalue, $checked) = @_;
    my $rv;
    my $cbid = &quote_escape(quotemeta("${checkname}_${checkvalue}"));
    my $rid = &quote_escape(quotemeta("row_${checkname}_${checkvalue}"));
    my $ridtr = &quote_escape("row_${checkname}_${checkvalue}");
    my $mycb = $cb;
    if ($checked) {
        $mycb =~ s/mainbody/mainsel/g;
    }

    $mycb =~ s/class='/class='ui_radio_columns /;
    $rv .= "<tr $mycb id=\"$ridtr\" onMouseOver=\"this.className = document.getElementById('$cbid').checked ? 'mainhighsel' : 'mainhigh'\" onMouseOut=\"this.className = document.getElementById('$cbid').checked ? 'mainsel' : 'mainbody'\">";
    $rv .= "<td ".$tdtags->[0]." class='ui_radio_radio'>".
            &ui_oneradio($checkname, $checkvalue, undef, $checked, "onClick=\"for(i=0; i<form.$checkname.length; i++) { ff = form.${checkname}[i]; r = document.getElementById('row_'+ff.id); if (r) { r.className = 'mainbody' } } document.getElementById('$rid').className = this.checked ? 'mainhighsel' : 'mainhigh';\"").
            "</td>";
    my $i;
    for($i=0; $i<@$cols; $i++) {
        $rv .= "<td ".$tdtags->[$i+1].">";
        if ($cols->[$i] !~ /<a\s+href|<input|<select|<textarea|<span|<p|<br/) {
            $rv .= "<label for=\"".
                    &quote_escape("${checkname}_${checkvalue}")."\">";
        }
        $rv .= ($cols->[$i] !~ /\S/ ? "<br>" : $cols->[$i]);
        if ($cols->[$i] !~ /<a\s+href|<input|<select|<textarea|<span|<p|<br/) {
            $rv .= "</label>";
        }
        $rv .= "</td>";
    }
    $rv .= "</tr>";
    return $rv;
}

# theme_ui_nav_link(direction, url, disabled)
# Returns an arrow icon linking to provided url
sub theme_ui_nav_link {
    my ($direction, $url, $disabled) = @_;
    my $alt = $direction eq "left" ? '<-' : '->';
    if ($disabled) {
        return "<img class='ui_nav_link' alt=\"$alt\" align=\"middle\""
                . "src=\"$gconfig{'webprefix'}/images/$direction-grey.gif?".$VERSION."\">";
    } else {
        return "<a class='ui_nav_link' href=\"$url\"><img class='ui_nav_link' alt=\"$alt\" align=\"top\""
        . "src=\"$gconfig{'webprefix'}/images/$direction.gif?".$VERSION."\"></a>";
    }
}

# theme_footer([page, name]+, [noendbody])
# Output a footer for returning to some page
sub theme_footer {
    my $i;
    my $count = 0;
    my %module_info = get_module_info(get_module_name());
    for($i=0; $i+1<@_; $i+=2) {
        local $url = $_[$i];
        if ($url ne '/' || !$tconfig{'noindex'}) {
            if ($url eq '/') {
                $url = "/?cat=$module_info{'category'}";
            } elsif ($url eq '' && get_module_name()) {
                $url = "/".get_module_name()."/".
                        $module_info{'index_link'};
            } elsif ($url =~ /^\?/ && get_module_name()) {
                $url = "/".get_module_name()."/$url";
            }
            $url =~ s/\/\?cat=$/\/right.cgi/g;
            $url = "$gconfig{'webprefix'}$url" if ($url =~ /^\//);
            if ($count++ == 0) {
                print theme_ui_nav_link("left", $url);
            } else {
                print "&nbsp;|";
            }
            print "&nbsp;<a href=\"$url\">",&text('main_return', $_[$i+1]),"</a>";
        }
    }
    print "<br>";
    if (!$_[$i]) {
        print "</body></html>";
    }
}


# theme_ui_hidden_javascript()
# Returns <script> and <style> sections for hiding functions and CSS
sub theme_ui_hidden_javascript {
    my $rv;
    my $imgdir = "$gconfig{'webprefix'}/images";

return <<EOF;
<style type='text/css'>.opener_shown {display:inline}.opener_hidden {display:none}</style>
<script type='text/javascript'>
function hidden_opener(divid, openerid) {
    var divobj = document.getElementById(divid);
    var openerobj = document.getElementById(openerid);
    if (divobj.className == 'opener_shown') {
        divobj.className = 'opener_hidden';
        openerobj.innerHTML = '<img border=0 src=$imgdir/closed.gif?$VERSION>';
    } else {
        divobj.className = 'opener_shown';
        openerobj.innerHTML = '<img border=0 src=$imgdir/open.gif?$VERSION>';
    }
}

/* Show a tab */
function select_tab(name, tabname, form) {
    var tabnames = document[name+'_tabnames'];
    var tabtitles = document[name+'_tabtitles'];
    for(var i=0; i<tabnames.length; i++) {
        var tabobj = document.getElementById('tab_'+tabnames[i]);
        var divobj = document.getElementById('div_'+tabnames[i]);
        var title = tabtitles[i];
        if (tabnames[i] == tabname) {
            /* Selected table */
            tabobj.innerHTML = '<table cellpadding=0 cellspacing=0><tr><td class=\\'tabSelected\\' nowrap>'+title+'</td></tr></table>';
            divobj.className = 'opener_shown';
        } else {
            /* Non-selected tab */
            tabobj.innerHTML = '<table cellpadding=0 cellspacing=0><tr><td class=\\'tabUnselected\\' nowrap><a href=\\'\\' onClick=\\'return select_tab("'+name+'", "'+tabnames[i]+'")\\'>'+title+'</a></td></tr></table>';
            divobj.className = 'opener_hidden';
        }
    }
    if (document.forms[0] && document.forms[0][name]) {
        document.forms[0][name].value = tabname;
    }
    return false;
}
</script>
EOF
}

# just replace -> and <- with &lArr; and &rArr; ascii character
sub theme_ui_multi_select {
    my ($name, $values, $opts, $size, $missing, $dis,
        $opts_title, $vals_title, $width) = @_;
    my $rv;
    my %already = map { $_->[0], $_ } @$values;
    my $leftover = [ grep { !$already{$_->[0]} } @$opts ];
    if ($missing) {
        my %optsalready = map { $_->[0], $_ } @$opts;
        push(@$opts, grep { !$optsalready{$_->[0]} } @$values);
    }
    if (!defined($width)) {
        $width = "200";
    }
    my $wstyle = $width ? "style='width:$width'" : "";

    if (!$main::ui_multi_select_donejs++) {
        $rv .= &ui_multi_select_javascript();
    }
    $rv .= "<table cellpadding=0 cellspacing=0 class='ui_multi_select'>";
    if (defined($opts_title)) {
        $rv .= "<tr class='ui_multi_select_heads'> ".
               "<td><b>$opts_title</b></td> ".
               "<td></td> <td><b>$vals_title</b></td> </tr>";
    }
    $rv .= "<tr class='ui_multi_select_row'>";
    $rv .= "<td style='padding-right:4px;'>".&ui_select($name."_opts", [ ], $leftover,
            $size, 1, 0, $dis, $wstyle)."</td>";
    $rv .= "<td style='padding:0px;'>".&ui_button("&rArr;", $name."_add", $dis,
            "onClick='multi_select_move(\"$name\", form, 1)'")."<br/>".
            &ui_button("&lArr;", $name."_remove", $dis,
            "onClick='multi_select_move(\"$name\", form, 0)'")."</td>";

    $rv .= "<td style='padding-left:4px;'>".&ui_select($name."_vals", [ ], $values,
            $size, 1, 0, $dis, $wstyle)."</td>";
    $rv .= "</tr></table>";
    $rv .= &ui_hidden($name, join("", map { $_->[0] } @$values));
    return $rv;
}

1;

