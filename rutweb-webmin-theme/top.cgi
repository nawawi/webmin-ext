#!/usr/bin/perl
# Show the top-side menu of Webmin modules

BEGIN { push(@INC, ".."); };
use WebminCore;
&init_config();
&ReadParse();
%text = &load_language($current_theme);
%gaccess = &get_module_acl(undef, "");

# Work out what modules and categories we have
@cats = &get_visible_modules_categories();
@modules = map { @{$_->{'modules'}} } @cats;
&popup_header('main');
print "aa";
&popup_footer();
