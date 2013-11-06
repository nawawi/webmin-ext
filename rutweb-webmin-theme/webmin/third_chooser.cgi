#!/usr/bin/perl
# third_chooser.cgi
# Display a list of third-party modules for installation

$trust_unknown_referers = 1;
require './webmin-lib.pl';
&popup_header($text{'third_title'});
%text = &load_language($current_theme);
$mods = &list_third_modules();
if (!ref($mods)) {
	print "<b>",&text('third_failed', $mods),"</b><p>\n";
	}
else {
    print "<div class='searchsort'>";
    print &ui_textbox("search", undef, 50, 0, undef,"id='xsort' style='width:100%;' placeholder='$text{'lookup_sort'}'");
    print '<hr></div>';
	print "<b>$text{'third_header'}</b><br>\n";
	print "<script>\n";
	print "function select(f)\n";
	print "{\n";
	print "opener.ifield.value = f;\n";
	print "close();\n";
	print "return false;\n";
	print "}\n";
	print "</script>\n";
	@table = ( );
    $scnt = 0;
	foreach $m (@$mods) {
		push(@table, [
		 "<a href='' onClick='return select(\"$m->[2]\")'>$m->[0]</a>",
		 $m->[1] eq "NONE" ? "" : &html_escape($m->[1]),
		 $m->[3],
		 ]);
            $scnt++;
		}
	print &ui_columns_table(undef, 100, \@table);
	}
    if ( $scnt >= 10 ) {
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
&popup_footer();

