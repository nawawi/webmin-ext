#!/usr/bin/perl
# standard_chooser.cgi
# Display a list of standard modules for installation

require './webmin-lib.pl';
&ui_print_header(undef, );
%text = &load_language($current_theme);
$mods = &list_standard_modules();
if (!ref($mods)) {
	print "<b>",&text('standard_failed', $mods),"</b><p>\n";
	}
else {
    print "<div class='searchsort'><b>".$text{'left_search'}."</b>&nbsp;";
    print &ui_textbox("search", undef, 50, 0, undef,"id='xsort'");
    print '<hr></div>';
	print "<b>$text{'standard_header'}</b><br>\n";
	if ($mods->[0]->[1] > &get_webmin_version()) {
		print &text('standard_warn', $mods->[0]->[1]),"<br>\n";
		}
	print "<script>\n";
	print "function select(f)\n";
	print "{\n";
	print "opener.ifield.value = f;\n";
	print "close();\n";
	print "return false;\n";
	print "}\n";
	print "</script>\n";
	@table = ( );
    $cnt = 0;
	foreach $m (@$mods) {
		my $minfo = { 'os_support' => $m->[3] };
		next if (!&check_os_support($minfo));
		push(@table, [
		 "<a href='' onClick='return select(\"$m->[0]\")'>$m->[0]</a>",
		 &html_escape($m->[4]),
		 ]);
    $cnt++;
		}
	print &ui_columns_table(undef, 100, \@table);
	}
    if ( $cnt >= 10 ) {
        print '<script>jQuery("div.searchsort").show();</script>';
    }
print <<_EOF;
<script type="text/javascript">
jQuery(document).ready(function() {
    jQuery("input#xsort").keyup(function(e) {
        var val = jQuery(this).val();
        if ( val !== '' ) {
            jQuery("tr[class*=row]").hide();
            jQuery("a").each(function() {
                var t = jQuery(this).text().toLowerCase();
                if ( t.match(val.toLowerCase()) ) {
                    jQuery(this).parent().parent().show();
                }
            });
        } else {
            jQuery("tr[class*=row]").show();
        }
    });
});
</script>
_EOF

&ui_print_footer();

